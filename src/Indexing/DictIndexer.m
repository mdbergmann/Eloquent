//
//  DictIndexer.m
//  Eloquent
//
//  Created by Manfred Bergmann on 31.05.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import "SearchResultEntry.h"
#import "IndexingManager.h"
#import "Indexer.h"

@interface DictIndexer : Indexer {
}

@end

@implementation DictIndexer

- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of DictIndexer");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc DictIndexer!");
	}
	
	return self;
}

/**
\brief init Indexer with the given parameters
 if there is no existing index available a new one is created
 */
- (id)initWithModuleName:(NSString *)aModName {
	CocoLog(LEVEL_DEBUG,@"init of DictIndexer");
	
	self = [self init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc DictIndexer!");
	} else {
		[self setModName:aModName];
		[self setModType:Dictionary];
        [self setModTypeStr:@"Dictionary"];
		
        // open or create content index
        contentIndexRef = [[IndexingManager sharedManager] openOrCreateIndexForModName:aModName textType:[self modTypeStr]];
        // check if we have a valid index reference
        if(contentIndexRef == NULL) {
            CocoLog(LEVEL_ERR, @"Error on creating content index!");
        }
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"dealloc of DictIndexer");
	
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

    [accessLock lock];
	// get right index ref
    SKIndexRef indexRef = NULL;
    if(type == ContentTextType) {
        indexRef = contentIndexRef;
    }
    
	if(indexRef != NULL) {
		// create doc name
		NSString *docName = [NSString stringWithFormat:@"%@", aKey];
		//CocoLog(LEVEL_DEBUG, @"creating document with name: %@", docName);
        
		SKDocumentRef docRef = SKDocumentCreate((CFStringRef)@"data", NULL, (CFStringRef)docName);
		if(docRef == NULL) {
			CocoLog(LEVEL_ERR, @"could nor create document!");
		} else {			
			// add Document
			//CocoLog(LEVEL_DEBUG, @"adding doc with text: %@", aText);
			BOOL success = SKIndexAddDocumentWithText(indexRef, docRef, (CFStringRef)aText, YES);
			if(!success) {
				CocoLog(LEVEL_ERR, @"Could not add document!");
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
    [accessLock unlock];
	
	return ret;
}

/**
\brief search in an this index for the given query and in the given range
 @param[in] query this query to search in
 @param[in] constrains, search constrains
 @param[in] maxResults the maximum number of results
 @return array of NSDictionaries with search results. 
 the array is autoreleased, the caller has to make sure to retain it if needed.
 */
- (NSArray *)performSearchOperation:(NSString *)query constrains:(id)constrains maxResults:(int)maxResults {
    NSMutableArray *array = nil;
    
    [accessLock lock];
    if(contentIndexRef != NULL) {
        SKSearchRef searchRef = SKSearchCreate(contentIndexRef, (CFStringRef)query, 0);
        if(searchRef != NULL) {
            // create document ids array
            SKDocumentID docIDs[maxResults];
            float scores[maxResults];
            CFIndex foundItems = 0;
            
            Boolean inProgress = YES;
            CFIndex count;
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
            array = [NSMutableArray arrayWithCapacity:(NSUInteger)foundItems];
            // loop over results
            for(int i = 0;i < foundItems;i++) {
                // prepare search result entry
                SearchResultEntry *searchEntry = nil;
                
                // get hit
                SKDocumentRef hit = docRefs[i];
                
                // get doc name
                NSString *docName = (NSString *)SKDocumentGetName(hit);
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
                
                // dispose the SKDocumentRef object
                CFRelease(hit);
            }
            
            // release Search object
            CFRelease(searchRef);
        } else {
            CocoLog(LEVEL_ERR, @"Could not create SearchRef!");
        }
    }
    [accessLock unlock];
    
    return array;
}

@end
