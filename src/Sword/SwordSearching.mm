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
#import "SwordBibleBook.h"
#import "SwordModuleTextEntry.h"
#import "SwordBibleTextEntry.h"
#import "SwordVerseKey.h"
#import "SwordListKey.h"
#import "SwordManager.h"

NSString *MacSwordIndexVersion = @"2.6";

@implementation SwordModule(Searching)

/**
 generates a path index for the given VerseKey
 */
- (NSString *)indexOfVerseKey:(SwordVerseKey *)vk {
    NSString *index = [NSString stringWithFormat:@"%003i/%003i/%003i/%003i/%@", 
                       [vk testament],
                       [vk book],
                       [vk chapter],
                       [vk verse],
                       [vk osisBookName]];
    
    return index;
}

- (BOOL)hasIndex {
    IndexingManager *im	= [IndexingManager sharedManager]; 
	NSString *modName = [self name];
    NSString *path = [im indexFolderPathForModuleName:modName];
    BOOL ret = NO;
    
    if([im indexExistsForModuleName:[self name]]) {
        NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"version.plist"]];
        if(d) {		
            if([[d objectForKey:@"MacSword Index Version"] isEqualToString:MacSwordIndexVersion]) {
                if(([d objectForKey:@"Sword Module Version"] == NULL) ||
                    ([[d objectForKey:@"Sword Module Version"] isEqualToString:[self version]])) {
                    MBLOGV(MBLOG_INFO, @"[SwordSearching -hasIndex] module %@ has valid index", modName);
                    ret = YES;
                } 
				else {
                    //index out of date remove it
                    MBLOGV(MBLOG_INFO, @"[SwordSearching -hasIndex] module %@ has no valid index!", modName);
                    [im removeIndexForModuleName:modName];
                }
            } 
			else {
                //index out of date remove it
                MBLOGV(MBLOG_INFO, @"[SwordSearching -hasIndex] module %@ has no valid index!", modName);
				[im removeIndexForModuleName:modName];
            }
        }
		else {
			MBLOGV( MBLOG_DEBUG, @"[SwordSearching -hasIndex] version.plist for module %@ was not found.", modName);			
		}
    }
	else {
		MBLOGV( MBLOG_DEBUG, @"[SwordSearching -hasIndex] index for module %@ was not found.", modName);
	}
    
	return ret;
}

/**
 \brief This message is used to force an index rebuild.
 */
- (void)recreateIndex {
	MBLOGV(MBLOG_DEBUG, @"ENTERING -- [SwordSearching -recreateIndex] for module %@", [self name]);
	[self deleteIndex];
	//[self createIndex];
	MBLOG(MBLOG_DEBUG, @"LEAVING  -- [SwordSearching -recreateIndex]");
}

- (void)deleteIndex {
    [indexLock lock];
	if([self hasIndex]) {
		[[IndexingManager sharedManager] removeIndexForModuleName:[self name]];
	}    
    [indexLock unlock];
}

- (void)createIndex {
	MBLOG(MBLOG_DEBUG, @"[SwordSearching -createIndex]");
	
    [indexLock lock];
    
	// get Indexer
    Indexer *indexer = [[IndexingManager sharedManager] indexerForModuleName:[self name] 
                                                                  moduleType:[SwordModule moduleTypeForModuleTypeString:[self typeString]]];
    if(indexer == nil) {
        MBLOG(MBLOG_ERR, @"Could not create Indexer for this module!");
    } else {
        MBLOG(MBLOG_DEBUG, @"[SwordSearching -createIndexAndReportTo:] start indexing...");

        [self indexContentsIntoIndex:indexer];
        [indexer flushIndex];
        [[IndexingManager sharedManager] closeIndexer:indexer];
        
        MBLOG(MBLOG_DEBUG, @"[SwordSearching -createIndexAndReportTo:] stopped indexing");

        //save version info
        NSString *path = [(IndexingManager *)[IndexingManager sharedManager] indexFolderPathForModuleName:[self name]];        
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
                           MacSwordIndexVersion, 
                           @"MacSword Index Version", 
                           [self version], 
                           @"Sword Module Version", nil];
        [d writeToFile:[path stringByAppendingPathComponent:@"version.plist"] atomically:NO];
    }
    
    // notify delegate
    if(delegate) {
        if([delegate respondsToSelector:@selector(indexCreationFinished:)]) {
            [delegate performSelectorOnMainThread:@selector(indexCreationFinished:) withObject:self waitUntilDone:YES];
        }
        
        // remove delegate
        delegate = nil;
    }
    [indexLock unlock];
}

- (void)createIndexThreadedWithDelegate:(id)aDelegate {
	MBLOG(MBLOG_DEBUG, @"[SwordSearching -createIndexThreadedWithDelegate:]");
    
    delegate = aDelegate;
    [NSThread detachNewThreadSelector:@selector(createIndex) toTarget:self withObject:nil];
}

/** abstract method */
- (void)indexContentsIntoIndex:(Indexer *)indexer {
}

@end

@implementation SwordBible(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer {
    
    BOOL savePEA = swModule->isProcessEntryAttributes();

    if([self hasFeature:SWMOD_FEATURE_STRONGS] || [self hasFeature:SWMOD_FEATURE_LEMMA]) {
        swModule->processEntryAttributes(YES);
    }
	
    [moduleLock lock];
    for(SwordBibleBook *bb in [self bookList]) {
        
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        SwordListKey *lk = [SwordListKey listKeyWithRef:[bb osisName] v11n:[self versification]];
        [lk setPersist:NO];
        [lk setPosition:BOTTOM];
        SwordVerseKey *last = [SwordVerseKey verseKeyWithRef:[lk keyText] v11n:[self versification]];
        [lk setPosition:TOP];        
        [self setKey:lk];
        NSString *ref = nil;
        NSString *stripped = nil;
        while(![self error] && ([(SwordVerseKey *)[self getKey] index] <= [last index])) {
            ref = [[self getKey] keyText];
            stripped = [self strippedText];
            
            NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithObject:ref forKey:IndexPropSwordKeyString];
            NSString *keyIndex = [self indexOfVerseKey:[SwordVerseKey verseKeyWithRef:ref v11n:[self versification]]];
            
            NSMutableString *strongStr = nil;
            if(swModule->isProcessEntryAttributes()) {
                // parse entry attributes and look for Lemma (String's numbers)
                sword::SWBuf strong;
                sword::AttributeTypeList::iterator words;
                sword::AttributeList::iterator word;
                sword::AttributeValue::iterator strongVal;
                words = swModule->getEntryAttributes().find("Word");
                if(words != swModule->getEntryAttributes().end()) {
                    for(word = words->second.begin();word != words->second.end(); word++) {
                        strongVal = word->second.find("Lemma");
                        if(strongVal != word->second.end()) {
                            // pass empty "Text" entries
                            if(strongVal->second == "G3588") {
                                if (word->second.find("Text") == word->second.end())
                                    continue;	// no text? let's skip
                            }
                            strong.append(strongVal->second);
                            strong.append(' ');
                        }
                    }
                }
                
                strongStr = [NSMutableString string];
                if(strong.length() > 0) {
                    [strongStr appendString:[NSString stringWithUTF8String:strong.c_str()]];
                    [strongStr replaceOccurrencesOfString:@"|x-Strongs:" withString:@" " options:0 range:NSMakeRange(0, [strongStr length])];
                    // also add to dictionary
                    [properties setObject:strongStr forKey:IndexPropSwordStrongString];
                }                
            }
            
            if((stripped && [stripped length] > 0) || (strongStr && [strongStr length] > 0)) {
                NSString *indexContent = [NSString stringWithFormat:@"%@ - %@", stripped, strongStr];                
                // add to index
                [indexer addDocument:keyIndex text:indexContent textType:ContentTextType storeDict:properties];                
            }
            
            [self incKeyPosition];
        }
        
		[pool drain];        
    }
    [moduleLock unlock];

	swModule->processEntryAttributes(savePEA);	
}

@end

@implementation SwordCommentary(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer {
    
    [moduleLock lock];
    for(SwordBibleBook *bb in [self bookList]) {
        
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

        
        SwordListKey *lk = [SwordListKey listKeyWithRef:[bb osisName] v11n:[self versification]];
        [lk setPersist:NO];
        [lk setPosition:BOTTOM];
        SwordVerseKey *last = [SwordVerseKey verseKeyWithRef:[lk keyText] v11n:[self versification]];
        [lk setPosition:TOP];        
        [self setKey:lk];
        NSString *ref = nil;
        NSString *stripped = nil;
        while(![self error] && ([(SwordVerseKey *)[self getKey] index] <= [last index])) {
            ref = [[self getKey] keyText];
            stripped = [self strippedText];
            
            NSDictionary *properties = [NSDictionary dictionaryWithObject:ref forKey:IndexPropSwordKeyString];
            NSString *keyIndex = [self indexOfVerseKey:[SwordVerseKey verseKeyWithRef:ref v11n:[self versification]]];
            if(stripped && [stripped length] > 0) {
                [indexer addDocument:keyIndex text:stripped textType:ContentTextType storeDict:properties];                
            }
            
            [self incKeyPosition];
        }

		[pool drain];        
    }
    [moduleLock unlock];
}

@end

@implementation SwordDictionary(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer {    

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for(NSString *key in [self allKeys]) {
        // entryForKey does lock
        NSString *entry = [self entryForKey:key];
        
        if(entry != nil) {
            NSDictionary *properties = [NSDictionary dictionaryWithObject:key forKey:IndexPropSwordKeyString];            
            if([entry length] > 0) {
                NSString *indexContent = [NSString stringWithFormat:@"%@ - %@", key, entry];
                [indexer addDocument:key text:indexContent textType:ContentTextType storeDict:properties];                
            }
        }
    }
    [pool drain];        
}

@end

@implementation SwordBook(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer {
    // we start at root
	[self indexContents:nil intoIndex:indexer];
}

- (void)indexContents:(NSString *)treeKey intoIndex:(Indexer *)indexer {
    
    SwordModuleTreeEntry *entry = [(SwordBook *)self treeEntryForKey:treeKey];
    for(NSString *key in [entry content]) {
        
        // get key
        NSArray *strippedArray = [self strippedTextEntriesForRef:key];
        if(strippedArray != nil) {
            // get content
            NSString *stripped = [(SwordModuleTextEntry *)[strippedArray objectAtIndex:0] text];
            // define properties
            NSMutableDictionary *propDict = [NSMutableDictionary dictionaryWithCapacity:2];
            // additionally save content
            //[propDict setObject:stripped forKey:IndexPropSwordKeyContent];
            [propDict setObject:key forKey:IndexPropSwordKeyString];
            
            if([stripped length] > 0) {
                // let's add the key also into the searchable content
                NSString *indexContent = [NSString stringWithFormat:@"%@ - %@", key, stripped];
                
                // add content with key
                [indexer addDocument:key text:indexContent textType:ContentTextType storeDict:propDict];                
            }
        }

        // go deeper
        [self indexContents:key intoIndex:indexer];
	}
}

@end
