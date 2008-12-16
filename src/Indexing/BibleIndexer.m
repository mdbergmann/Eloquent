//
//  BibleIndexer.m
//  Eloquent
//
//  Created by Manfred Bergmann on 31.05.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import "BibleIndexer.h"
#import "SearchResultEntry.h"
#import <AppKit/NSApplication.h>

/** the range for searching */
NSRange searchRange;

@interface BibleIndexer : Indexer {
}

@end

@implementation BibleIndexer

- (id)init {
	MBLOG(MBLOG_DEBUG,@"init of BibleIndexer");
	
	self = [super init];
	if(self == nil) {
		MBLOG(MBLOG_ERR,@"cannot alloc BibleIndexer!");
	}
	
	return self;
}

/**
\brief init Indexer with the given parameters
 if there is no existing index available a new one is created
 */
- (id)initWithModuleName:(NSString *)aModName {	
	self = [self init];
	if(self == nil) {
		MBLOG(MBLOG_ERR,@"cannot alloc BibleIndexer!");
	} else {
		[self setModName:aModName];
		[self setModType:bible];
		[self setModTypeStr:@"Bible"];
        
        searchRange = NSMakeRange(0, 0);
        
        contentIndexRef = NULL;
        
        // open or create content index
        contentIndexRef = [Indexer openOrCreateIndexforModName:aModName textType:[self modTypeStr]];				
        // check if we have a valid index reference
        if(contentIndexRef == NULL) {
            MBLOG(MBLOG_ERR, @"Error on creating or opening content index!");
        }
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	// dealloc object
	[super dealloc];
}

/**
\brief add a text to be indexed to this indexer
 @param[in] aKey the document key (ID)
 @param[in] aText the text to be indexed
 @param[in] type the type of text (see IndexTextType enum values)
 @param[in] aDict a dictionary to be stored in the document
 @return success YES/NO
 */
- (BOOL)addDocument:(NSString *)aKey text:(NSString *)aText textType:(IndexTextType)type storeDict:(NSDictionary *)aDict {
	BOOL ret = NO;

	// get right index ref
    SKIndexRef indexRef = NULL;
    if(type == ContentTextType) {
        indexRef = contentIndexRef;
    }
    
	if(indexRef != NULL) {
		// create doc name
		NSString *docName = [NSString stringWithFormat:@"%@", aKey];
		//MBLOGV(MBLOG_DEBUG, @"creating document with name: %@", docName);
        
		SKDocumentRef docRef = SKDocumentCreate((CFStringRef)@"data", NULL, (CFStringRef)docName);
		if(docRef == NULL) {
			MBLOG(MBLOG_ERR, @"could nor create document!");
		} else {			
			// add Document
			//MBLOGV(MBLOG_DEBUG, @"adding doc with text: %@", aText);
			BOOL success = SKIndexAddDocumentWithText(indexRef, docRef, (CFStringRef)aText, YES);
			if(!success) {
				MBLOG(MBLOG_ERR, @"Could not add document!");
			} else {
                if(aDict != nil) {
                    // set document properties for this document
                    SKIndexSetDocumentProperties(indexRef, docRef, (CFDictionaryRef)aDict);
                }
			}
			
			// release doc
			CFRelease(docRef);
		}		
	}
	
	return ret;
}

/**
\brief search in an this index for the given query and in the given range
 @param[in] query this query to search in
 @param[in] range, pass 0,0 for no range
 @param[in] maxResults the maximum number of results
 @return array of NSDictionaries with search results. 
 the array is autoreleased, the caller has to make sure to retain it if needed.
 */
- (NSArray *)performSearchOperation:(NSString *)query range:(NSRange)range maxResults:(int)maxResults {
    NSMutableArray *array = nil;
    
    [searchLock lock];
    if(contentIndexRef != NULL) {
        // copy range
        searchRange.location = range.location;
        searchRange.length = range.length;
        
        // use 10.4 searching on Tiger and above
        SKSearchRef searchRef = SKSearchCreate(contentIndexRef, (CFStringRef)query, 0);
        if(searchRef != NULL) {
            // create documentids array
            SKDocumentID docIDs[maxResults];
            float scores[maxResults];
            CFIndex foundItems = 0;
            
            Boolean inProgress = YES;
            CFIndex count = kMaxSearchResults;
            while(inProgress == YES) {
                if(maxResults > kMaxSearchResults) {
                    count = kMaxSearchResults;
                    maxResults = maxResults - kMaxSearchResults;
                } else {
                    count = maxResults;
                }
                
                // call find matches
                CFIndex found = 0;
                inProgress = SKSearchFindMatches(
                                                 searchRef,
                                                 count,
                                                 &docIDs[foundItems],
                                                 &scores[foundItems],
                                                 1,
                                                 &found);
                // add to found result
                foundItems += found;
            }
            
            // create array for doc refs
            SKDocumentRef docRefs[foundItems];
            // get all document refs
            SKIndexCopyDocumentRefsForDocumentIDs(
                                                  contentIndexRef,
                                                  foundItems,
                                                  docIDs,
                                                  docRefs);
            
            // prepare result array
            array = [NSMutableArray arrayWithCapacity:foundItems];
            // loop over results
            for(int i = 0;i < foundItems;i++) {
                // prepare search result entry
                SearchResultEntry *searchEntry = nil;

                // get hit
                SKDocumentRef hit = docRefs[i];
                
                // get doc name
                NSString *docName = (NSString *)SKDocumentGetName(hit);
                // check for an existing range
                BOOL addDoc = YES;
                if(range.location > 0) {
                    // calculate begin index and endindex
                    int indexA = range.location;
                    int indexB = indexA + range.length;
                    
                    // get document name
                    NSString *docName = (NSString *)SKDocumentGetName(hit);
                    
                    // extract versekey information
                    addDoc = NO;
                    NSArray *verseKeyInfo = [docName componentsSeparatedByString:@"/"];
                    if([verseKeyInfo count] == 4) {
                        // get book number
                        int bookNum = [(NSString *)[verseKeyInfo objectAtIndex:1] intValue];
                        if(bookNum > 0) {
                            // alright
                            if((bookNum < indexB) && (bookNum >= indexA)) {
                                addDoc = YES;
                            }
                        }
                    } else {
                        MBLOG(MBLOG_ERR, @"have no valid document name!"); 
                    }
                }
                
                // add if in range
                if(addDoc == YES) {
                    NSDictionary *propDict = (NSDictionary *)SKIndexCopyDocumentProperties(contentIndexRef, hit);
                    if(propDict != nil) {
                        searchEntry = [[[SearchResultEntry alloc] initWithDictionary:propDict] autorelease];
                    }

                    // add score
                    [searchEntry addObject:[NSNumber numberWithFloat:scores[i]] forKey:IndexPropDocScore];
                    
                    // add Document Name
                    [searchEntry addObject:docName forKey:IndexPropDocName];
                    
                    // add search entry to array
                    [array addObject:searchEntry];
                }
                
                // dispose the SKDocumentRef object
                CFRelease(hit);
            }
            
            // release Search object
            CFRelease(searchRef);
        } else {
            MBLOG(MBLOG_ERR, @"Could not create SearchRef!");
        }
    }
    [searchLock unlock];
    
    return array;
}

@end
