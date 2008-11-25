//
//  SwordSearching.m
//  MacSword
//
// Copyright 2008 Manfred Bergmann
// Based on code by Will Thimbleby
//

#import "SwordSearching.h"
#import "CocoLogger/CocoLogger.h"
#import "IndexingManager.h"
#import "Indexer.h"
#import "SearchResultEntry.h"
#import "utils.h"
#import "SwordModule.h"
#import "SwordBible.h"
#import "SwordDictionary.h"
#import "SwordBook.h"

NSString *MacSwordIndexVersion = @"2.4";

@implementation SwordModule(Searching)

/**
 generates a path index for the given VerseKey
 */
+ (NSString *)indexOfVerseKey:(sword::VerseKey *)vk {
    int testament = vk->Testament();
    int book = vk->Book();
    
    // testament 2 begins with book 1
    if(testament == 2) {
        book = book + 39;   // 39 is the last book in AT
    }
    
    NSString *index = [NSString stringWithFormat:@"%003i/%003i/%003i/%003i", 
                       testament,
                       book,
                       vk->Chapter(),
                       vk->Verse()];
    
    return index;
}

- (NSString *)textForKey:(NSString *)key {
    
    NSString *ret = @"";
    
	sword::SWKey textkey = toUTF8(key);
	swModule->setKey(textkey);
	
	char *ctxt = (char *)swModule->StripText();
	int clen = strlen(ctxt);
	if(clen > 3 && ctxt[clen-3] == -96) {
		ctxt[clen-3] = 0;
	}
    ret = [NSString stringWithUTF8String:ctxt];

	return ret;
}

- (BOOL)hasIndex {
    BOOL ret = NO;
    
    [indexLock lock];
    // get IndexingManager
    IndexingManager *im = [IndexingManager sharedManager]; 
    NSString *path = [im indexFolderPathForModuleName:[self name]];
    BOOL isDir;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"version.plist"]];
        if(d) {		
            if([[d objectForKey:@"MacSword Index Version"] isEqualToString: MacSwordIndexVersion]) {
                if(([d objectForKey:@"Sword Module Version"] == NULL) ||
                    ([[d objectForKey:@"Sword Module Version"] isEqualToString:[self version]])) {
                    MBLOGV(MBLOG_INFO, @"[SwordSearching -hasIndex] module %@ has valid index", [self name]);
                    ret = YES;
                } else {
                    //index out of date remove it
                    MBLOGV(MBLOG_INFO, @"[SwordSearching -hasIndex] module %@ has no valid index!", [self name]);
                    [[NSFileManager defaultManager] removeFileAtPath:path handler:nil];                
                }
            } else {
                //index out of date remove it
                MBLOGV(MBLOG_INFO, @"[SwordSearching -hasIndex] module %@ has no valid index!", [self name]);
                [[NSFileManager defaultManager] removeFileAtPath:path handler:nil];            
            }
        }		
    }
    [indexLock unlock];
    
	return ret;
}

- (void)createIndex {

	MBLOG(MBLOG_DEBUG, @"[SwordSearching -createIndex]");

	sword::SWKey *savekey = NULL;
	sword::SWKey *searchkey = NULL;
	sword::SWKey textkey;
	
	[moduleLock lock];
	
	// save key information so as not to disrupt original
	// module position
	if (!swModule->getKey()->Persist()) {
        // key does not persist
		savekey = swModule->CreateKey();
		*savekey = *swModule->getKey();
	} else {
		savekey = swModule->getKey();
    }

	searchkey = (swModule->getKey()->Persist()) ? swModule->getKey()->clone() : 0;
	if (searchkey) {
		searchkey->Persist(1);
		swModule->setKey(*searchkey);
	}

	// position module at the beginning
	*swModule = sword::TOP;
    
	// get Indexer
    Indexer *indexer = [Indexer indexerWithModuleName:[self name] 
                                           moduleType:[SwordModule moduleTypeForModuleTypeString:[self typeString]]];
    if(indexer == nil) {
        MBLOG(MBLOG_ERR, @"Could not create Indexer for this module!");
    } else {
        MBLOG(MBLOG_DEBUG, @"[SwordSearching -createIndexAndReportTo:] start indexing...");
        [self indexContentsIntoIndex:indexer];
        [indexer flushIndex];
        [indexer close];
        MBLOG(MBLOG_DEBUG, @"[SwordSearching -createIndexAndReportTo:] stopped indexing");

        // reposition module back to where it was before we were called
        swModule->setKey(*savekey);
        if (!savekey->Persist()) {
            delete savekey;
        }
        if (searchkey) {
            delete searchkey;
        }

        MBLOG(MBLOG_DEBUG, @"end index");
                
        //save version info
        NSString *path = [(IndexingManager *)[IndexingManager sharedManager] indexFolderPathForModuleName:[self name]];        
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                           MacSwordIndexVersion, 
                           @"MacSword Index Version", 
                           [self version], 
                           @"Sword Module Version", nil];
        [d writeToFile:[path stringByAppendingPathComponent:@"version.plist"] atomically:NO];
    }
    
    [moduleLock unlock];
}

/** abstract method */
- (void)indexContentsIntoIndex:(Indexer *)indexer {
}

@end

@implementation SwordBible(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer {

	sword::VerseKey *vkcheck = NULL;
	vkcheck = My_SWDYNAMIC_CAST(VerseKey, swModule->getKey());
	long highIndex = (vkcheck) ? 32300 : swModule->getKey()->Index();
	if(!highIndex) {
		highIndex = 1;		// avoid division by zero errors.
	}

	bool savePEA = swModule->isProcessEntryAttributes();
	swModule->processEntryAttributes(true);
	
	while(!swModule->Error()) {        
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		long mindex = 0;
		if (vkcheck) {
			//mindex = vkcheck->NewIndex();
		} else {
			mindex = swModule->getKey()->Index();
		}

		// get "content" field
		const char *content = swModule->StripText();
		if(content && *content) {
			// build "strong" field
			sword::SWBuf strong;
			sword::AttributeTypeList::iterator words;
			sword::AttributeList::iterator word;
			sword::AttributeValue::iterator strongVal;
			
            // what the heck is going on here
			words = swModule->getEntryAttributes().find("Word");
			if (words != swModule->getEntryAttributes().end()) {
				for (word = words->second.begin();word != words->second.end(); word++) {
					strongVal = word->second.find("Lemma");
					if (strongVal != word->second.end()) {
						// cheeze.  skip empty article tags that weren't assigned to any text
						if (strongVal->second == "G3588") {
							if (word->second.find("Text") == word->second.end())
								continue;	// no text? let's skip
						}
						strong.append(strongVal->second);
						strong.append(' ');
					}
				}
			}
			
			sword::VerseKey *vk = (sword::VerseKey *)swModule->getKey();
			NSString *keyStr = [NSString stringWithUTF8String:vk->getText()];
			NSString *contentStr = [NSString stringWithUTF8String:content];
            NSString *keyIndex = [SwordModule indexOfVerseKey:vk];
            
            NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithCapacity:2];
            if(contentStr == nil) {
                contentStr = @"";
            }

            // additionally save content and key string
            [propDict setObject:contentStr forKey:IndexPropSwordKeyContent];
            [propDict setObject:keyStr forKey:IndexPropSwordKeyString];                
            
            NSMutableString *strongStr = [NSMutableString string];
			if(strong.length() > 0) {
                [strongStr appendString:[NSString stringWithUTF8String:strong.c_str()]];
				[strongStr replaceOccurrencesOfString:@"|x-Strongs:" withString:@" " options:0 range:NSMakeRange(0, [strongStr length])];
                
                // also add to dictionary
                [propDict setObject:strongStr forKey:IndexPropSwordStrongString];
			}
			
            // index combined with strongs
            NSString *indexContent = [NSString stringWithFormat:@"%@ - %@", contentStr, strongStr];
                
            // add to index
            [indexer addDocument:keyIndex text:indexContent textType:ContentTextType storeDict:propDict];
			// release stuff
			[contentStr release];
            
            // release key string
			[keyStr release];
		}
		
		(*swModule)++;
		
		[pool drain];		
	}
	
	swModule->processEntryAttributes(savePEA);	
}

@end

@implementation SwordDictionary(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer {
    
	swModule->setSkipConsecutiveLinks(true);
    
    // we start on top
	*swModule = sword::TOP;
	swModule->getRawEntry();
 
    int counter = 0;
    while (!swModule->Error()) {

        // this is the content of the 
        const char *content = swModule->StripText();
        const char *key = swModule->getKey()->getText();
        
        NSString *keyStr = nil;
        NSString *contentStr = nil;

        if([self isUnicode]) {
            keyStr = [NSString stringWithUTF8String:key];
            contentStr = [NSString stringWithUTF8String:content];
        } else {
            keyStr = [NSString stringWithCString:key encoding:NSISOLatin1StringEncoding];
            contentStr = [NSString stringWithCString:content encoding:NSISOLatin1StringEncoding];
        }
        
        NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithCapacity:1];
        // additionally save content
        [propDict setObject:contentStr forKey:IndexPropSwordKeyContent];
        [propDict setObject:keyStr forKey:IndexPropSwordKeyString];
        
        // let's add the key also into the searchable content
        NSString *indexContent = [NSString stringWithFormat:@"%@ - %@", keyStr, contentStr];
        // add content
        [indexer addDocument:keyStr text:indexContent textType:ContentTextType storeDict:propDict];

        (*swModule)++;
        counter++;        
    }
}

@end

@implementation SwordBook(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer {
    // we start at root
	[self indexContents:nil intoIndex:indexer];
}

- (void)indexContents:(NSString *)treeKey intoIndex:(Indexer *)indexer {
    
    SwordTreeEntry *entry = [(SwordBook *)self treeEntryForKey:treeKey];
    for(NSString *key in [entry content]) {
        
        // get key
        NSArray *stripedAr = [(SwordBook *)self stripedTextForRef:key];
        //NSArray *stripedAr = [(SwordBook *)self renderedTextForRef:key];
        if(stripedAr != nil) {
            // get content
            NSString *stripped = [(NSDictionary *)[stripedAr objectAtIndex:0] objectForKey:SW_OUTPUT_TEXT_KEY];
            // define properties
            NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithCapacity:2];
            // additionally save content
            [propDict setObject:stripped forKey:IndexPropSwordKeyContent];
            [propDict setObject:key forKey:IndexPropSwordKeyString];
            
            // let's add the key also into the searchable content
            NSString *indexContent = [NSString stringWithFormat:@"%@ - %@", key, stripped];
            
            // add content with key
            [indexer addDocument:key text:indexContent textType:ContentTextType storeDict:propDict];            
        }

        // go deeper
        [self indexContents:key intoIndex:indexer];
	}
}

@end
