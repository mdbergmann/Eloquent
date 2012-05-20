//
//  Indexer.m
//  Eloquent
//
//  Created by Manfred Bergmann on 28.05.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import "Indexer.h"
#import "BibleIndexer.m"
#import "BookIndexer.m"
#import "DictIndexer.m"

@interface Indexer ()

- (void)performThreadedSearchOperation:(NSDictionary *)options;

@end


@implementation Indexer

@synthesize modType;
@synthesize modTypeStr;
@synthesize modName;
@synthesize accessLock;
@synthesize accessCounter;
@synthesize progressIndicator;

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
		CocoLog(LEVEL_ERR, @"cannot alloc Indexer!");
	} else {
        [self setModName:@""];
        [self setAccessLock:[[[NSLock alloc] init] autorelease]];
        accessCounter = 0;
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
        case Bible:
        case Commentary:
            indexer = [[[BibleIndexer alloc] initWithModuleName:aModName] autorelease];
            break;
        case Genbook:
            indexer = [[[BookIndexer alloc] initWithModuleName:aModName] autorelease];
            break;
        case Dictionary:
            indexer = [[[DictIndexer alloc] initWithModuleName:aModName] autorelease];
            break;
        case All:
            // do nothing
            break;
    }

	return indexer;
}

- (void)dealloc {
    [modName release];
    [modTypeStr release];
    [accessLock release];

    [super dealloc];
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
 @param[in] constrains, search constrains
 @param[in] maxResults the maximum number of results
 @return array of NSDictionaries with search results. 
 the array is autoreleased, the caller has to make sure to retain it if needed.
 */
- (NSArray *)performSearchOperation:(NSString *)query constrains:(id)constrains maxResults:(int)maxResults {
    return nil;
}

/**
 creates a new thread for searching. returnes immediately.
 @param[in] query this query to search in
 @param[in] constrains, search constrains
 @param[in] maxResults the maximum number of results
 @param[in] delegate report to delegate. @selector(searchOperationFinished:) is called with a NSArray of search results
 */
- (void)performThreadedSearchOperation:(NSString *)query constrains:(id)constrains maxResults:(int)maxResults delegate:(id)delegate {
    
    // create options
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:4];
    if(query) {
        [options setObject:query forKey:@"Query"];    
    }
    if(constrains) {
        [options setObject:constrains forKey:@"Constrains"];
    }
    [options setObject:[NSNumber numberWithInt:maxResults] forKey:@"MaxResults"];
    if(delegate) {
        [options setObject:delegate forKey:@"Delegate"];
    }
    
    [NSThread detachNewThreadSelector:@selector(performThreadedSearchOperation:) toTarget:self withObject:options];
}

/**
 private method
 */
- (void)performThreadedSearchOperation:(NSDictionary *)options {
    
    // get options
    NSString *query = [options objectForKey:@"Query"];
    id constrains = [options objectForKey:@"Constrains"];
    int maxResults = [[options objectForKey:@"MaxResults"] intValue];
    id delegate = [options objectForKey:@"Delegate"];
    
    // perform search
    NSArray *result = [self performSearchOperation:query constrains:constrains maxResults:maxResults];
    
    // notify delegate
    if(delegate) {
        if([delegate respondsToSelector:@selector(searchOperationFinished:)]) {
            [delegate performSelectorOnMainThread:@selector(searchOperationFinished:) withObject:result waitUntilDone:YES];
        }
    }
}

/**
\brief flush the data to file
 */
- (BOOL)flushIndex {
    
    [accessLock lock];
	// flush all indexes
    BOOL content = YES;
    if(contentIndexRef) {
        content = SKIndexFlush(contentIndexRef);
        if(!content) {
            CocoLog(LEVEL_ERR, @"could not flush content index!");
        }        
    }
    [accessLock unlock];
	
	return content;
}

/**
\brief closes all indexes
 */
- (void)close {

    [accessLock lock];
    if(contentIndexRef) {
        CFRelease(contentIndexRef);
    }
    // or SKIndexClose(contentIndexRef);
    [accessLock unlock];
    
    contentIndexRef = NULL;
}

@end
