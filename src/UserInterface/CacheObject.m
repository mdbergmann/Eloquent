//
//  CacheObject.m
//  Eloquent
//
//  Created by Manfred Bergmann on 17.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "CacheObject.h"


@implementation CacheObject

@synthesize reference;
@synthesize content;
@synthesize count;

- (void)dealloc {
    [reference release];
    [content release];

    [super dealloc];
}

@end
