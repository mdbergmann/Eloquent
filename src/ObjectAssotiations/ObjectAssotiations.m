//
//  ObjectAssotiations.m
//  MacSword2
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "ObjectAssotiations.h"
#import "WindowHostController.h"

char ModuleListUI;
char BookmarkMgrUI;
char NotesMgrUI;

@interface ObjectAssotiations ()

@property (retain, readwrite) NSMutableDictionary *assotiations;

@end


@implementation ObjectAssotiations

@synthesize assotiations;
@synthesize currentInitialisationHost;

+ (ObjectAssotiations *)assotiations {
    static ObjectAssotiations *instance;
    if(instance == nil) {
        instance = [[ObjectAssotiations alloc] init];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        self.assotiations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerObject:(id)anObject forAssotiatedObject:(id)assoObject withKey:(void *)aKey {
    NSUInteger pointerKey = (NSUInteger)assoObject + (NSUInteger)aKey;
    [assotiations setObject:anObject forKey:[NSNumber numberWithUnsignedInteger:pointerKey]];
}

- (void)unregisterForAssotiatedObject:(id)assoObject withKey:(void *)aKey {
    NSUInteger pointerKey = (NSUInteger)assoObject + (NSUInteger)aKey;
    [assotiations removeObjectForKey:[NSNumber numberWithUnsignedInteger:pointerKey]];
}

- (id)objectForAssotiatedObject:(id)assoObject withKey:(void *)aKey {
    NSUInteger pointerKey = (NSUInteger)assoObject + (NSUInteger)aKey;
    id anObject = [assotiations objectForKey:[NSNumber numberWithUnsignedInteger:pointerKey]];
    return anObject;
}

@end
