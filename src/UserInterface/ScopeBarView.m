//
//  ScopeBarView.m
//  MacSword2
//
//  Created by Manfred Bergmann on 28.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ScopeBarView.h"


@implementation ScopeBarView

@synthesize windowActive;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        activeTopLine = [NSColor colorWithCalibratedWhite:0.7450 alpha:1.0];
        activeFill = [NSColor colorWithCalibratedWhite:0.5843 alpha:1.0];
        inactiveTopLine = [NSColor colorWithCalibratedWhite:0.8980 alpha:1.0];
        inactiveFill = [NSColor colorWithCalibratedWhite:0.8313 alpha:1.0];
        windowActive = YES;
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect {
    MBLOGV(MBLOG_DEBUG, @"[ScopeBarView -drawRect:] x:%f, y:%f, w:%f, h:%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    if(!windowActive) {
        MBLOG(MBLOG_DEBUG, @"[ScopeBarView -drawRect:] inactive");
        [inactiveFill set];
    } else {
        MBLOG(MBLOG_DEBUG, @"[ScopeBarView -drawRect:] active");
        [activeFill set];
    }
    [NSBezierPath fillRect:rect];

    if(!windowActive) {
        [inactiveTopLine set];
    } else {
        [activeTopLine set];
    }
    [NSBezierPath strokeRect:NSMakeRect(rect.origin.x, rect.size.height-0.5, rect.size.width, 0.5)];
}

@end
