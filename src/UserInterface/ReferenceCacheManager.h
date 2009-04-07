//
//  ReferenceCacheManager.h
//  MacSword2
//
//  Created by Manfred Bergmann on 04.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ReferenceCacheObject;

@interface ReferenceCacheManager : NSObject {
    NSMutableArray *cache;
    int keepSize;
}

@property (readwrite) int keepSize;

+ (ReferenceCacheManager *)defaultCacheManager;

- (void)addCacheObject:(ReferenceCacheObject *)cacheObject;
- (ReferenceCacheObject *)cacheObjectForReference:(NSString *)ref andModuleName:(NSString *)aName;
- (void)cleanCache;
- (BOOL)contains:(ReferenceCacheObject *)anObject;

@end
