//
//  NSUserDefaults+Additions.m
//  Eloquent
//
//  Created by Manfred Bergmann on 18.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "NSUserDefaults+Additions.h"


@implementation NSUserDefaults (Additions)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey {
    NSData *theData = [NSArchiver archivedDataWithRootObject:aColor];
    [self setObject:theData forKey:aKey];
}

- (NSColor *)colorForKey:(NSString *)aKey {
    NSColor *theColor = nil;
    NSData *theData = [self dataForKey:aKey];
    if(theData != nil)
        theColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return theColor;    
}

@end
