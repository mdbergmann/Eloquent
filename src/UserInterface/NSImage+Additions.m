//
//  NSImage+Additions.m
//  Eloquent
//
//  Created by Manfred Bergmann on 28.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSImage+Additions.h"


@implementation NSImage (Additions)

- (NSImage *)rotateByDegrees:(int)degrees {
    
    NSSize size = [self size];

    BOOL vertical = NO;
    NSSize newSize;
    if(degrees > 0 && degrees < 180) {
        vertical = YES;
        newSize = NSMakeSize(size.height, size.width);    
    } else {
        newSize = NSMakeSize(size.width, size.height);
    }
    NSImage *rotatedImage = [[[NSImage alloc] initWithSize:newSize] autorelease];
    
    [rotatedImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    
    NSAffineTransform *rotateTF = [NSAffineTransform transform];
    NSPoint centerPoint = NSMakePoint(size.width * 0.5f, size.height * 0.5f);
    
    [rotateTF translateXBy:centerPoint.x yBy:centerPoint.y];
    [rotateTF rotateByDegrees:degrees];
    if(!vertical) {
        [rotateTF translateXBy:-centerPoint.x yBy:-centerPoint.y];    
    } else {
        [rotateTF translateXBy:-centerPoint.y yBy:-centerPoint.x];
    }
    [rotateTF concat];
    
    [self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    [rotatedImage unlockFocus];
    
    return rotatedImage;
}

- (NSImage *)mirrorVertically {

    NSImage *rotatedImage = [[[NSImage alloc] initWithSize:self.size] autorelease];
    
    [rotatedImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    
    NSAffineTransform *rotateTF = [NSAffineTransform transform];
    NSPoint centerPoint = NSMakePoint(self.size.width * 0.5f, self.size.height * 0.5f);
    
    [rotateTF translateXBy:centerPoint.x yBy:centerPoint.y];
    [rotateTF rotateByDegrees:180];
    [rotateTF translateXBy:-centerPoint.x yBy:-centerPoint.y];    
    [rotateTF concat];
    
    [self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    [rotatedImage unlockFocus];
    
    return rotatedImage;
}

@end
