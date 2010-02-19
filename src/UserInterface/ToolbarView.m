//
//  ToolbarView.m
//  MacSword2
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "ToolbarView.h"
#import "CTGradient.h"

@implementation ToolbarView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSColor *col1 = [NSColor colorWithCalibratedRed:0.3411 green:0.4156 blue:0.4901 alpha:1.0];
        NSColor *col2 = [NSColor colorWithCalibratedRed:0.2 green:0.2235 blue:0.2470 alpha:1.0];
        gradient = [CTGradient gradientWithBeginningColor:col1 endingColor:col2];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [gradient fillRect:dirtyRect angle:270.0];
    [super drawRect:dirtyRect];
}

- (void)finalize {
    [super finalize];
}

@end
