//
//  VerseEnumerator.m
//  MacSword2
//
//  Created by Manfred Bergmann on 25.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "VerseEnumerator.h"
#import "SwordListKey.h"

@interface VerseEnumerator ()
@property (retain, readwrite) SwordListKey *listKey;
@end

@implementation VerseEnumerator

@synthesize listKey;

- (id)initWithListKey:(SwordListKey *)aListKey {
    self = [super init];
    if(self) {
        self.listKey = aListKey;
        *[listKey swListKey] = sword::TOP;
    }
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [super dealloc];
}

- (NSArray *)allObjects {
    NSMutableArray *t = [NSMutableArray array];
    for(*[listKey swListKey] = sword::TOP;![listKey swListKey]->Error(); *[listKey swListKey] += 1) {
        [t addObject:[listKey keyText]];
    }
    // possition TOP again
    *[listKey swListKey] = sword::TOP;
    
    return [NSArray arrayWithArray:t];
}

- (NSString *)nextObject {
    NSString *ret = nil;
    if(![listKey swListKey]->Error()) {
        ret = [listKey keyText];
        *[listKey swListKey] += 1;
    }
    return ret;
}

@end
