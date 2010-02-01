//
//  SwordTreeEntry.m
//  MacSword2
//
//  Created by Manfred Bergmann on 29.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SwordModuleTreeEntry.h"


@implementation SwordModuleTreeEntry

@synthesize key;
@synthesize content;

- (id)initWithKey:(NSString *)aKey content:(NSArray *)aContent {
    self = [super init];
    if(self) {
        self.key = aKey;
        self.content = aContent;
    }
    
    return self;
}

@end
