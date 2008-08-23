//
//  OutlineListObject.m
//  MacSword2
//
//  Created by Manfred Bergmann on 10.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "OutlineListObject.h"


@implementation OutlineListObject

@synthesize displayString;
@synthesize listType;
@synthesize listObject;

- (id)initWithType:(int)aType andDisplayString:(NSString *)aString {
    self = [super init];
    if(self) {
        self.listType = aType;
        self.displayString = aString;
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

@end
