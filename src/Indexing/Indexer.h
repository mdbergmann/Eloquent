//
//  Indexer.h
//  Eloquent
//
//  Created by Manfred Bergmann on 28.05.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <CocoLogger/CocoLogger.h>
#import <ObjCSword/SwordModule.h>
#import <AppKit/NSApplication.h>
#import <CoreServices/CoreServices.h>

@protocol IndexCreationProgressing;

#define kMaxSearchResults 1000

typedef enum {
    ReferenceSearchType,
    IndexSearchType,
    ViewSearchType
}SearchType;

typedef enum {
	VerseKeyIndexTextType,
	ContentTextType,
	StrongTextType
}IndexTextType;

@interface Indexer : NSObject  {
    SKIndexRef contentIndexRef;
	ModuleType modType;
    NSString *modTypeStr;
	NSString *modName;
    
    NSLock *accessLock;
    NSInteger accessCounter;
    
    id<IndexCreationProgressing> progressIndicator;
}

@property (readwrite) ModuleType modType;
@property (retain, readwrite) NSString *modTypeStr;
@property (retain, readwrite) NSString *modName;
@property (retain, readwrite) NSLock *accessLock;
@property (readwrite) NSInteger accessCounter;
@property (assign, readwrite) id<IndexCreationProgressing> progressIndicator;

/**
 \brief convenient allocator for this class cluster
 */
+ (id)indexerWithModuleName:(NSString *)aModName moduleType:(ModuleType)aModType;

/**
 \brief init Indexer with the given parameters
 if there is no existing index available a new one is created
 */
- (id)initWithModuleName:(NSString *)aModName moduleType:(ModuleType)aModType;

/**
\brief add a text to be indexed to this indexer
 @param[in] aKey the document key (ID)
 @param[in] aText the text to be indexed
 @param[in] type the type of text (see IndexTextType enum values)
 @param[in] aDict a dictionary to be stored in the document
 @return success YES/NO
 */
- (BOOL)addDocument:(NSString *)aKey text:(NSString *)aText textType:(IndexTextType)type storeDict:(NSDictionary *)aDict;

/**
 \brief search in an this index for the given query and in the given range
 @param[in] query this query to search in
 @param[in] constrains, search constrains
 @param[in] maxResults the maximum number of results
 @return array of NSDictionaries with search results. 
 the array is autoreleased, the caller has to make sure to retain it if needed.
 */
- (NSArray *)performSearchOperation:(NSString *)query constrains:(id)constrains maxResults:(int)maxResults;

/**
 creates a new thread for searching and returnes immediately.
 @param[in] query this query to search in
 @param[in] constrains, search constrains
 @param[in] maxResults the maximum number of results
 @param[in] delegate report to delegate. @selector(searchOperationFinished:) is called with a NSArray of search results
*/
- (void)performThreadedSearchOperation:(NSString *)query constrains:(id)constrains maxResults:(int)maxResults delegate:(id)delegate;

/**
 \brief flush the data to file
 */
- (BOOL)flushIndex;

/**
 \brief closes all indexes
 */
- (void)close;

@end
