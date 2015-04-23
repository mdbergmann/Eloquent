//
//  InstallSourceListObject.m
//  Eloquent
//
//  Created by Manfred Bergmann on 10.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <ObjCSword/ObjCSword.h>
#import "InstallSourceListObject.h"

@implementation InstallSourceListObject

/** convenient allocator */
+ (InstallSourceListObject *)installSourceListObjectForType:(InstallSourceListObjectType)type {
    InstallSourceListObject *object = [[InstallSourceListObject alloc] initWithListObjectType:type];
    return object;
}

- (id)initWithListObjectType:(InstallSourceListObjectType)type {
    self = [super init];
    if(self) {
        self.objectType = type;
    }
    return self;
}

@end
