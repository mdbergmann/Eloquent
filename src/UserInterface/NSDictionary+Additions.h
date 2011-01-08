//
//  NSMutableDictionary+Additions.h
//  Eloquent
//
//  Created by Manfred Bergmann on 18.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableDictionary (Additions)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey;

@end

@interface NSDictionary (Additions)

- (NSColor *)colorForKey:(NSString *)aKey;

@end
