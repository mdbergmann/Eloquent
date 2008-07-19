//
//  ReferenceCacheManager.m
//  MacSword2
//
//  Created by Manfred Bergmann on 04.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ReferenceCacheManager.h"
#import "ReferenceCacheObject.h"

@interface ReferenceCacheManager ( )

@property (retain, readwrite) NSMutableArray *cache;

@end


@implementation ReferenceCacheManager

@synthesize cache;

@synthesize keepSize;

+ (ReferenceCacheManager *)defaultCacheManager {
    static ReferenceCacheManager *instance;
    if(instance == nil) {
        instance = [[ReferenceCacheManager alloc] init];
    }
    
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        keepSize = 10;   // default keepSize
        self.cache = [NSMutableArray arrayWithCapacity:keepSize];
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)addCacheObject:(ReferenceCacheObject *)cacheObject {
    [cache addObject:cacheObject];
    
    // check current size and see if we need to delete some entries
    int diff = [cache count] - keepSize;
    if(diff > 0) {
        // we need to delete some entries
        [cache removeObjectsInRange:NSMakeRange(0, diff - 1)];
    }
}

- (ReferenceCacheObject *)cacheObjectForReference:(NSString *)ref andModuleName:(NSString *)aName {
    ReferenceCacheObject *ret = nil;
    
    for(ReferenceCacheObject *o in cache) {
        if([o.moduleName isEqualToString:aName] && [o.reference isEqualToString:ref]) {
            ret = o;
            break;
        }
    }
     
    return ret;
}

- (void)cleanCache {
    [cache removeAllObjects];
}

@end
