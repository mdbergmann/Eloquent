//
//  MouseTrackingScrollView.m
//  Eloquent
//
//  Created by Manfred Bergmann on 03.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MouseTrackingScrollView.h"


@implementation MouseTrackingScrollView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    CocoLog(LEVEL_DEBUG, @"[MouseTrackingScrollView -mouseEntered:]");
    if(delegate && [delegate respondsToSelector:@selector(mouseEnteredView:)]) {
        [delegate performSelector:@selector(mouseEnteredView:) withObject:self];
    }
    
    //[super mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent {
    CocoLog(LEVEL_DEBUG, @"[MouseTrackingScrollView -mouseExited:]");
    if(delegate && [delegate respondsToSelector:@selector(mouseExitedView:)]) {
        [delegate performSelector:@selector(mouseExitedView:) withObject:self];
    }
    
    //[super mouseExited:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent {
}

- (void)updateMouseTracking {
    while(self.trackingAreas.count > 0) {
		[self removeTrackingArea:[self.trackingAreas lastObject]];
	}
    [self addTrackingArea:[[[NSTrackingArea alloc] initWithRect:[self bounds] 
                                                        options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow) 
                                                          owner:self 
                                                       userInfo:nil] autorelease]];
}

@end
