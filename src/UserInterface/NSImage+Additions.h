//
//  NSImage+Additions.h
//  Eloquent
//
//  Created by Manfred Bergmann on 28.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (Additions)

- (NSImage *)rotateByDegrees:(int)degrees;
- (NSImage *)mirrorVertically;

@end
