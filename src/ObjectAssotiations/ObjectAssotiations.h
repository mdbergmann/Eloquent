//
//  ObjectAssotiations.h
//  MacSword2
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define Assotiater [ObjectAssotiations assotiations]

@class WindowHostController;

@interface ObjectAssotiations : NSObject {
    NSMutableDictionary *assotiations;
    WindowHostController *currentInitialisationHost;
}

@property (readwrite) WindowHostController *currentInitialisationHost;

+ (ObjectAssotiations *)assotiations;

- (void)registerObject:(id)anObject forAssotiatedObject:(id)assoObject withKey:(void *)aKey;
- (void)unregisterForAssotiatedObject:(id)assoObject withKey:(void *)aKey;
- (id)objectForAssotiatedObject:(id)assoObject withKey:(void *)aKey;

@end
