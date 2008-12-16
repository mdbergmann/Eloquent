//
//  Indexer.m
//  Eloquent
//
//  Created by Manfred Bergmann on 28.05.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import "Indexer.h"
#import "IndexingManager.h"
#import "SearchResultEntry.h"

#import "BibleIndexer.m"
#import "BookIndexer.m"
#import "DictIndexer.m"

@interface Indexer (PrivateAPI)

@end

@implementation Indexer (PrivateAPI)

@end

@implementation Indexer

@synthesize modType;
@synthesize modTypeStr;
@synthesize modName;
@synthesize searchLock;

/**
\brief open or create index for the given parameters
 @return SKIndexRef or NULL on error
 */
+ (SKIndexRef)openOrCreateIndexforModName:(NSString *)aModName textType:(NSString *)aModType {
	// we do not accept nil values
	if(aModName == nil) {
		aModName = @"";
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];	
	// get IndexingManager for basepath
	IndexingManager *im = [IndexingManager sharedManager];
    
    NSString *indexFolder = [im indexFolderPathForModuleName:aModName];
    if([fm fileExistsAtPath:indexFolder] == NO) {
        // create index folder
        [fm createDirectoryAtPath:indexFolder attributes:nil];
    }
    
	// construct index for content
    NSString *indexName = [NSString stringWithFormat:@"%@-%@", aModName, aModType];
	SKIndexRef indexRef = NULL;
	NSString *indexPath = [im indexPathForModuleName:aModName textType:aModType];
	NSURL *indexURL = [NSURL fileURLWithPath:indexPath];
	if([fm fileExistsAtPath:indexPath] == YES) {
		// open index
		indexRef = SKIndexOpenWithURL((CFURLRef)indexURL, (CFStringRef)indexName, NO);
	} else {
        // create properties for indexing
        NSMutableDictionary *props = [NSMutableDictionary dictionary];
        [props setObject:(NSNumber *)kCFBooleanTrue forKey:(NSString *)kSKProximityIndexing];
        
		// create index
		indexRef = SKIndexCreateWithURL((CFURLRef)indexURL, 
										(CFStringRef)indexName, 
										kSKIndexInvertedVector, 
										(CFDictionaryRef)props);
	}
	
	return indexRef;
}

/**
\brief convenient allocator for this class cluster
 */
+ (id)indexerWithModuleName:(NSString *)aModName moduleType:(ModuleType)aModType {
    Indexer *indexer = [[[Indexer alloc] initWithModuleName:aModName moduleType:aModType] autorelease];
    
    return indexer;
}

- (id)init {
	self = [super init];
	if(self == nil) {
		MBLOG(MBLOG_ERR,@"cannot alloc Indexer!");
	} else {
        [self setModName:@""];
        [self setSearchLock:[[NSLock alloc] init]];
    }
	
	return self;
}

/**
\brief init Indexer with the given parameters
 if there is no existing index available a new one is created
 */
- (id)initWithModuleName:(NSString *)aModName moduleType:(ModuleType)aModType {
	Indexer *indexer = nil;
    
    // we currently know 3 module types to index
    switch(aModType) {
        case bible:
        case commentary:
            indexer = [[BibleIndexer alloc] initWithModuleName:aModName];
            break;
        case dictionary:
            indexer = [[DictIndexer alloc] initWithModuleName:aModName];
            break;
        case genbook:
            indexer = [[BookIndexer alloc] initWithModuleName:aModName];
            break;
        case devotional:
            MBLOG(MBLOG_WARN, @"No indexing available for these type of modules!");
            break;
    }

	return indexer;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)finalize {
	// dealloc object
	[super finalize];
}

/**
\brief add a text to be indexed to this indexer.
 This method is abstract and should be overriden by the subclasses

 @param[in] aKey the document key (ID)
 @param[in] aText the text to be indexed
 @param[in] type the type of text (see IndexTextType enum values)
 @param[in] aDict a dictionary to be stored in the document
 @return success YES/NO
 */
- (BOOL)addDocument:(NSString *)aKey text:(NSString *)aText textType:(IndexTextType)type storeDict:(NSDictionary *)aDict {
	return NO;
}

/**
\brief search in an this index for the given query and in the given range
 This method is abstract and should be overriden by the subclasses

 @param[in] query this query to search in
 @param[in] range pointer, maybe nil for no range
 @return array of NSDictionaries with search results
 */
- (NSArray *)performSearchOperation:(NSString *)query range:(NSRange)range maxResults:(int)maxResults {
    
    [searchLock lock];
    NSArray *array = nil;
    [searchLock unlock];
    
    return array;
}

/**
\brief flush the data to file
 */
- (BOOL)flushIndex {
	// flush all indexes
    BOOL content = SKIndexFlush(contentIndexRef);
    if(!content) {
        MBLOG(MBLOG_ERR, @"could not flush content index!");
    }
	
	return content;
}

/**
\brief closes all indexes
 */
- (void)close {
	CFRelease(contentIndexRef);
    // or SKIndexClose(contentIndexRef);
    
    contentIndexRef = NULL;
}

@end
