//
//  ObjectAssociations.m
//  Eloquent
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "ObjectAssociations.h"
#import "HostableViewController.h"
#import "WindowHostController.h"

char ModuleListUI;
char BookmarkMgrUI;
char NotesMgrUI;

@interface ObjectAssociations ()

@property (retain, readwrite) NSMutableDictionary *associations;

@end


@implementation ObjectAssociations

@synthesize associations;
@synthesize currentInitialisationHost;

+ (ObjectAssociations *)associations {
    static ObjectAssociations *instance = nil;
    if(instance == nil) {
        instance = [[ObjectAssociations alloc] init];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        self.associations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [associations release];

    [super dealloc];
}

- (void)registerObject:(id)anObject forAssociatedObject:(id)assoObject withKey:(void *)aKey {
    NSUInteger pointerKey = (NSUInteger)assoObject + (NSUInteger)aKey;
    [associations setObject:anObject forKey:[NSNumber numberWithUnsignedInteger:pointerKey]];
}

- (void)unregisterForAssociatedObject:(id)assoObject withKey:(void *)aKey {
    NSUInteger pointerKey = (NSUInteger)assoObject + (NSUInteger)aKey;
    [associations removeObjectForKey:[NSNumber numberWithUnsignedInteger:pointerKey]];
}

- (id)objectForAssociatedObject:(id)assoObject withKey:(void *)aKey {
    NSUInteger pointerKey = (NSUInteger)assoObject + (NSUInteger)aKey;
    id anObject = [associations objectForKey:[NSNumber numberWithUnsignedInteger:pointerKey]];
    return anObject;
}

@end
