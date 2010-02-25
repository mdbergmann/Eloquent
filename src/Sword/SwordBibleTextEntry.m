//
//  SwordBibleTextEntry.m
//  MacSword2
//
//  Created by Manfred Bergmann on 01.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "SwordBibleTextEntry.h"

@implementation SwordBibleTextEntry

@synthesize preverseHeading;

+ (id)textEntryForKey:(NSString *)aKey andText:(NSString *)aText {
    return [[[SwordBibleTextEntry alloc] initWithKey:aKey andText:aText] autorelease];
}

- (id)initWithKey:(NSString *)aKey andText:(NSString *)aText {
    self = [super init];
    if(self) {
        self.key = aKey;
        self.text = aText;
    }    
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [self setPreverseHeading:nil];
    
    [super dealloc];
}

@end
