//
//  SwordModuleTest.m
//  MacSword2
//
//  Created by Manfred Bergmann on 14.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SwordModuleTest.h"
#import "SwordManager.h"
#import "SwordModule.h"


@implementation SwordModuleTest

- (void)testStrippedTextForRef {
    SwordModule *mod = [[SwordManager defaultManager] moduleWithName:@"GerSch"];
    NSArray *refs = [mod stripedTextForRef:@"1. Mose 2:2"];
    STAssertNotNil(refs, @"no refs");
}

@end
