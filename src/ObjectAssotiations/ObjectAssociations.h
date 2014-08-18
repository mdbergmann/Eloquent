//
//  ObjectAssociations.h
//  Eloquent
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#define Associater [ObjectAssociations associations]

@class WindowHostController;

@interface ObjectAssociations : NSObject {
    NSMutableDictionary *associations;
    WindowHostController *__strong currentInitialisationHost;
}

@property (strong, readwrite) WindowHostController *currentInitialisationHost;

+ (ObjectAssociations *)associations;

- (void)registerObject:(id)anObject forAssociatedObject:(id)assoObject withKey:(void *)aKey;
- (void)unregisterForAssociatedObject:(id)assoObject withKey:(void *)aKey;
- (id)objectForAssociatedObject:(id)assoObject withKey:(void *)aKey;

@end
