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

@property (retain, readwrite) NSMutableArray *indexCache;
@property (retain, readwrite) NSMutableArray *refCache;

@end


@implementation ReferenceCacheManager

@synthesize indexCache;
@synthesize refCache;
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
        self.indexCache = [NSMutableArray arrayWithCapacity:keepSize];
        self.refCache = [NSMutableArray arrayWithCapacity:keepSize];
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)addCacheObject:(ReferenceCacheObject *)cacheObject searchType:(SearchType)aType {
    
    NSMutableArray *arr = refCache;
    if(aType == IndexSearchType) {
        arr = indexCache;
    }

    if(![self contains:cacheObject forSearchType:aType]) {
        [arr addObject:cacheObject];
        
        // check current size and see if we need to delete some entries
        int diff = [arr count] - keepSize;
        if(diff > 0) {
            // we need to delete some entries
            [arr removeObjectsInRange:NSMakeRange(0, diff - 1)];
        }        
    }
}

- (ReferenceCacheObject *)cacheObjectForReference:(NSString *)ref forModuleName:(NSString *)aName andSearchType:(SearchType)aType {
    ReferenceCacheObject *ret = nil;
    
    NSMutableArray *arr = refCache;
    if(aType == IndexSearchType) {
        arr = indexCache;
    }
    
    for(ReferenceCacheObject *o in arr) {
        if([o.moduleName isEqualToString:aName] && [o.reference isEqualToString:ref]) {
            ret = o;
            break;
        }
    }
     
    return ret;
}

- (void)cleanCache {
    [indexCache removeAllObjects];
    [refCache removeAllObjects];
}

- (BOOL)contains:(ReferenceCacheObject *)anObject forSearchType:(SearchType)aType {
    BOOL ret = NO;
    
    NSMutableArray *arr = refCache;
    if(aType == IndexSearchType) {
        arr = indexCache;
    }

    for(ReferenceCacheObject *obj in arr) {
        if([[obj reference] isEqualToString:[anObject reference]]) {
            ret = YES;
            break;
        }
    }
    
    return ret;
}
       
@end
