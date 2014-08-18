//
//  ObjectAssotiationsTest.m
//  Eloquent
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "ObjectAssotiationsTest.h"

@implementation ObjectAssotiationsTest

static char anObjectKey;

- (void)setUp {
    objAsso = [ObjectAssociations associations];
    assoObject = [[NSObject alloc] init];
    anObject = [[NSObject alloc] init];
}

- (void)testAssotiation {
    [objAsso registerObject:anObject forAssotiatedObject:assoObject withKey:&anObjectKey];
    NSObject *obj = [objAsso objectForAssociatedObject:assoObject withKey:&anObjectKey];
    STAssertTrue((obj == anObject), @"");
    STAssertEqualObjects(obj, anObject, @"");
}

@end
