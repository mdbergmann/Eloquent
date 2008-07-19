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
#import <SwordModule.h>
#import <AppKit/NSApplication.h>
#import <CoreServices/CoreServices.h>

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
	ModuleType modType;
    NSString *modTypeStr;
	NSString *modName;
}

/**
\brief open or create index for the given parameters
 @return SKIndexRef or NULL on error
 */
+ (SKIndexRef)openOrCreateIndexforModName:(NSString *)aModName textType:(NSString *)aModType;

/**
 \brief convenient allocator for this class cluster
 */
+ (id)indexerWithModuleName:(NSString *)aModName moduleType:(ModuleType)aModType;

/**
 \brief init Indexer with the given parameters
 if there is no existing index available a new one is created
 */
- (id)initWithModuleName:(NSString *)aModName moduleType:(ModuleType)aModType;

//----------------------
// getter / setter
//----------------------
- (ModuleType)modType;
- (void)setModType:(ModuleType)value;

- (NSString *)modName;
- (void)setModName:(NSString *)value;

- (NSString *)modTypeStr;
- (void)setModTypeStr:(NSString *)value;

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
 @param[in] range pointer, maybe nil for no range
 @param[in] maxResults the maximum number of results. -1 tell the indexer the check hisself for the maximum number of results
 @return array of NSDictionaries with search results
 */
- (NSArray *)performSearchOperation:(NSString *)query range:(NSRange)range maxResults:(int)maxResults;

/**
 \brief flush the data to file
 */
- (BOOL)flushIndex;

/**
 \brief closes all indexes
 */
- (void)close;

@end
