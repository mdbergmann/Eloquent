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
#import "MBThreadedProgressSheetController.h"
#import "utils.h"
#import "SwordModule.h"
#import "SwordBible.h"
#import "SwordDictionary.h"
#import "SwordBook.h"

NSString *MacSwordIndexVersion = @"2.2";

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
    ret = [NSString stringWithCString:ctxt encoding:NSUTF8StringEncoding];

	return ret;
}

- (BOOL)hasIndex {

    BOOL ret = NO;
    
	// get IndexingManager
	IndexingManager *im = [IndexingManager sharedManager]; 
    
	NSString *path = [im indexFolderPathForModuleName:[self name]];
    BOOL isDir;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
		NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"version.plist"]];
		
		if(d) {		
            if([[d objectForKey:@"MacSword Index Version"] isEqualToString: MacSwordIndexVersion]) {
                if([d objectForKey:@"Sword Module Version"] == NULL) {
                    ret = YES;
                }
                
                if([[d objectForKey:@"Sword Module Version"] isEqualToString:[self version]])
                {
                    ret = YES;
                } else {
                    //index out of date remove it
                    [[NSFileManager defaultManager] removeFileAtPath:path handler:nil];                
                }
            } else {
                //index out of date remove it
                [[NSFileManager defaultManager] removeFileAtPath:path handler:nil];            
            }
        }		
	}
    
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
        // key does nmot persist
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

    // prepare progress sheet
    MBThreadedProgressSheetController *ps = [[MBThreadedProgressSheetController alloc] init];
    //[pSheet setSheetWindow:parentWindow];
    [ps setProgressAction:[NSNumber numberWithInt:INDEXING_PROGRESS_ACTION]];
    [ps setMinProgressValue:[NSNumber numberWithDouble:0.0]];
    [ps setShouldKeepTrackOfProgress:[NSNumber numberWithBool:YES]];
    [ps setIsThreaded:[NSNumber numberWithBool:YES]];
    
	// get Indexer
    Indexer *indexer = [Indexer indexerWithModuleName:[self name] 
                                           moduleType:[SwordModule moduleTypeForModuleTypeString:[self typeString]]];
    if(indexer == nil) {
        MBLOG(MBLOG_ERR, @"Could not create Indexer for this module!");
    } else {
        
        // bring up sheet
        [ps performSelectorOnMainThread:@selector(beginSheet) withObject:nil waitUntilDone:YES];
        
        [self indexContentsIntoIndex:indexer progressSheet:ps];
        
        // get ThreadedProgressSheet and see if process has been canceled
        if([ps sheetReturnCode] == CANCELED_END) {
            [indexer close];
            return;                
        }
        
        [indexer flushIndex];
        [indexer close];

        // bring up sheet
        [ps performSelectorOnMainThread:@selector(endSheet) withObject:nil waitUntilDone:YES];
        
        // reposition module back to where it was before we were called
        swModule->setKey(*savekey);
        if (!savekey->Persist()) {
            delete savekey;
        }
        if (searchkey) {
            delete searchkey;
        }
        
        [moduleLock unlock];

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
}

/** abstract method */
- (void)indexContentsIntoIndex:(Indexer *)indexer progressSheet:(MBThreadedProgressSheetController *)ps {    
}

@end

@implementation SwordBible(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer progressSheet:(MBThreadedProgressSheetController *)ps {

	sword::VerseKey *vkcheck = NULL;
	vkcheck = My_SWDYNAMIC_CAST(VerseKey, swModule->getKey());
	long highIndex = (vkcheck) ? 32300 : swModule->getKey()->Index();
	if(!highIndex) {
		highIndex = 1;		// avoid division by zero errors.
	}
    // set max progress value, 100%
    [ps performSelectorOnMainThread:@selector(setMaxProgressValue:) 
                         withObject:[NSNumber numberWithDouble:(double)100.0]
                      waitUntilDone:YES];

	bool savePEA = swModule->isProcessEntryAttributes();
	swModule->processEntryAttributes(true);
	
	char perc = 1;
	while(!swModule->Error()) {        
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		long mindex = 0;
		if (vkcheck) {
			mindex = vkcheck->NewIndex();
		} else {
			mindex = swModule->getKey()->Index();
		}

		// compute percent complete so we can report to our progress callback
		float per = (float)mindex / highIndex;
		// between 5%-98%
		per *= 93;
        per += 5;
		char newperc = (char)per;
		if(newperc > perc) {
			perc = newperc;
            [ps performSelectorOnMainThread:@selector(setProgressValue:) 
                                 withObject:[NSNumber numberWithDouble:(double)perc] 
                              waitUntilDone:YES];
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
		
        // get ThreadedProgressSheet and see if process has been canceled
        if([ps sheetReturnCode] == CANCELED_END) {
            return;                
        }
	}
	
	swModule->processEntryAttributes(savePEA);	
}

@end

@implementation SwordDictionary(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer progressSheet:(MBThreadedProgressSheetController *)ps {
    
	swModule->setSkipConsecutiveLinks(true);
    
    // we start on top
	*swModule = sword::TOP;
	swModule->getRawEntry();
 
	int counter = 0;
    int max = [self entryCount];
    if(max == 0) {
        max = 1;    // avoid division by zero
    }
    // set maximum value
    [ps performSelectorOnMainThread:@selector(setMaxProgressValue:) 
                         withObject:[NSNumber numberWithDouble:(double)max] 
                      waitUntilDone:YES];
	
    while (!swModule->Error()) {

        // this is the content of the 
        const char *content = swModule->StripText();
        
        NSString *keyStr = nil;
        NSString *contentStr = nil;

        if([self isUnicode]) {
            keyStr = fromUTF8(swModule->getKey()->getText());
            contentStr = fromUTF8(content);
        } else {
            keyStr = fromLatin1(swModule->getKey()->getText());
            contentStr = fromLatin1(content);            
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
        
        // set progress
        [ps performSelectorOnMainThread:@selector(setProgressValue:) 
                             withObject:[NSNumber numberWithDouble:(double)counter] 
                          waitUntilDone:YES];

        // get ThreadedProgressSheet and see if process has been canceled
        if([ps sheetReturnCode] == CANCELED_END) {
            return;                
        }
    }
}

@end

@implementation SwordBook(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer progressSheet:(MBThreadedProgressSheetController *)ps {
	sword::TreeKeyIdx *treeKey = dynamic_cast<sword::TreeKeyIdx *>((sword::SWKey *)*(swModule));
	[self indexContents:treeKey intoIndex:indexer progressSheet:ps];
}

- (id)indexContents:(sword::TreeKeyIdx *)treeKey 
          intoIndex:(Indexer *)indexer 
      progressSheet:(MBThreadedProgressSheetController *)ps {
    
	// we need to check for any Unicode names here
	char *treeNodeName = (char *)treeKey->getText();

	NSString *name = @"";
	if([self isUnicode]) {
		name = fromUTF8(treeNodeName);
	} else {
		name = fromLatin1(treeNodeName);	
	}
	
	if(treeKey->hasChildren()) {
		NSMutableArray *c = [NSMutableArray array];
		
		[c addObject:name];
		treeKey->firstChild();
		
		// look over keys
		do {
			*swModule = (long)treeKey;
			char *keyCString = (char *)swModule->getKey()->getText();
			const char *content = swModule->StripText();

            NSString *contentStr = @"";
            NSString *keyStr = @"";
            if([self isUnicode]) {
                keyStr = fromUTF8(keyCString);
                contentStr = fromUTF8(content);
            } else {
                keyStr = fromLatin1(keyCString);
                contentStr = fromLatin1(content);
			}
            
            NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithCapacity:2];
            // additionally save content
            [propDict setObject:contentStr forKey:IndexPropSwordKeyContent];
            [propDict setObject:keyStr forKey:IndexPropSwordKeyString];
            
            // let's add the key also into the searchable content
            NSString *indexContent = [NSString stringWithFormat:@"%@ - %@ - %@", keyStr, name, contentStr];

            // add content with key
            [indexer addDocument:keyStr text:indexContent textType:ContentTextType storeDict:propDict];

			[self indexContents:treeKey intoIndex:indexer progressSheet:ps];
		}
		while(treeKey->nextSibling());
		
		treeKey->parent();
		
		return c;
	}
	
	return name;
}

@end
