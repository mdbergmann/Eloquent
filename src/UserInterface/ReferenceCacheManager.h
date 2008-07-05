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
}

+ (ReferenceCacheManager *)defaultCacheManager;

- (void)addCacheObject:(ReferenceCacheObject *)cacheObject;
- (ReferenceCacheObject *)cacheObjectForReference:(NSString *)ref andModuleName:(NSString *)aName;
- (void)cleanCache;

@end
