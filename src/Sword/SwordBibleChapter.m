//
//  SwordBibleChapter.m
//  MacSword2
//
//  Created by Manfred Bergmann on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordBibleChapter.h"


@implementation SwordBibleChapter

@synthesize book;
@synthesize number;

- (id)initWithBook:(SwordBibleBook *)aBook andChapter:(int)aNumber {
    self = [super init];
    if(self) {
        self.book = aBook;
        self.number = aNumber;
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

@end
