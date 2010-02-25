//
//  SwordModuleTextEntry.m
//  MacSword2
//
//  Created by Manfred Bergmann on 03.10.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "SwordModuleTextEntry.h"
#import "SwordKey.h"

@implementation SwordModuleTextEntry

@synthesize key;
@synthesize text;

+ (id)textEntryForKey:(NSString *)aKey andText:(NSString *)aText {
    return [[[SwordModuleTextEntry alloc] initWithKey:aKey andText:aText] autorelease];
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
    [self setKey:nil];
    [self setText:nil];
    
    [super dealloc];
}

@end
