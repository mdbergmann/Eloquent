//
//  ReferenceCacheManager.h
//  MacSword2
//
//  Created by Manfred Bergmann on 04.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Indexer.h>

@class ReferenceCacheObject;

@interface ReferenceCacheManager : NSObject {
    NSMutableArray *indexCache;
    NSMutableArray *refCache;
    int keepSize;
}

@property (readwrite) int keepSize;

+ (ReferenceCacheManager *)defaultCacheManager;

- (void)addCacheObject:(ReferenceCacheObject *)cacheObject searchType:(SearchType)aType;
- (ReferenceCacheObject *)cacheObjectForReference:(NSString *)ref forModuleName:(NSString *)aName andSearchType:(SearchType)aType;
- (void)cleanCache;
- (BOOL)contains:(ReferenceCacheObject *)anObject forSearchType:(SearchType)aType;

@end
