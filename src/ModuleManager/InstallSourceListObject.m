//
//  InstallSourceListObject.m
//  Eloquent
//
//  Created by Manfred Bergmann on 10.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "InstallSourceListObject.h"

@implementation InstallSourceListObject

/** convenient allocator */
+ (InstallSourceListObject *)installSourceListObjectForType:(InstallSourceListObjectType)type {
    return [[InstallSourceListObject alloc] initWithListObjectType:type];
}

- (id)initWithListObjectType:(InstallSourceListObjectType)type {
    self = [super init];
    if(self) {
        self.objectType = type;
    }
    return self;
}

@end
