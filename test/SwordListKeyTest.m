//
//  SwordListKeyTest.m
//  MacSword2
//
//  Created by Manfred Bergmann on 10.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordListKeyTest.h"


@implementation SwordListKeyTest

- (void)testContainsKey {
    
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"Gen 1:1-5"];
    SwordVerseKey *vk = [SwordVerseKey verseKeyWithRef:@"Gen 1:3"];
    BOOL result = [lk containsKey:vk];
    STAssertTrue(result);
}

@end
