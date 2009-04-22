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

#ifdef __cplusplus
#include <swtext.h>
#include <versekey.h>
#include <regex.h>
class sword::SWModule;
#endif

@implementation SwordModuleTest

- (void)testStrippedTextForRef {
    SwordModule *mod = [[SwordManager defaultManager] moduleWithName:@"GerSch"];
    //NSArray *refs = [mod stripedTextForRef:@"1. Mose 2:2"];
    //STAssertNotNil(refs, @"no refs");
    
    SWModule *swmod = [mod swModule];
    sword::VerseKey *vk = sword::VerseKey("1Mo 1:2");
    NSLog(@"start position: %s", vk.getText());
    vk.decrement();
    NSLog(@"decrement position: %s", vk.getText());    
    vk.setVerse(vk.getVerse() + 3);
    NSLog(@"verse + 3: %s", vk.getText());
    
}

@end
