//
//  NSMutableDictionary+Additions.m
//  Eloquent
//
//  Created by Manfred Bergmann on 18.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "NSDictionary+Additions.h"


@implementation NSMutableDictionary (Additions)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey {
    NSData *theData = [NSArchiver archivedDataWithRootObject:aColor];
    [self setObject:theData forKey:aKey];
}

@end

@implementation NSDictionary (Additions)

- (NSColor *)colorForKey:(NSString *)aKey {
    NSColor *theColor = nil;
    NSData *theData = [self objectForKey:aKey];
    if(theData != nil)
        theColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return theColor;    
}

@end
