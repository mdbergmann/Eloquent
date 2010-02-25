//
//  SwordListKeyTest.m
//  MacSword2
//
//  Created by Manfred Bergmann on 10.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordListKeyTest.h"
#import "SwordListKey.h"
#import "SwordVerseKey.h"
#import "VerseEnumerator.h"

@implementation SwordListKeyTest

- (void)testContainsKey {
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"Gen 1:1-5"];
    SwordVerseKey *vk = [SwordVerseKey verseKeyWithRef:@"Gen 1:3"];
    STAssertTrue([lk containsKey:vk], @"");
}

/*
- (void)testNumberOfVerses {
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen 1:2-20"];
    STAssertNotNil(lk, @"");
    STAssertTrue(([lk numberOfVerses] == 19), @"");
}
*/

- (void)testVerseEnumeratorAllObjects {
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen 1:2-20"];
    STAssertNotNil(lk, @"");
    
    VerseEnumerator *ve = [lk verseEnumerator];
    NSArray *verseRefs = [ve allObjects];
    STAssertNotNil(verseRefs, @"");
    STAssertTrue(([verseRefs count] == 19), @"");
}

- (void)testVerseEnumeratorNextObject {
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen 1:2-20"];
    STAssertNotNil(lk, @"");
    
    VerseEnumerator *ve = [lk verseEnumerator];
    int count = 0;
    NSString *ref = nil;
    while((ref = [ve nextObject])) {
        count++;
    }
    STAssertTrue((count == 19), @"");
}

@end
