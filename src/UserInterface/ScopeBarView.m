//
//  ScopeBarView.m
//  Eloquent
//
//  Created by Manfred Bergmann on 28.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ScopeBarView.h"


@implementation ScopeBarView

@synthesize windowActive;
@synthesize bgImageActive;
@synthesize bgImageInactive;


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bgImageActive = [NSImage imageNamed:@"scopebar_active.png"];
        self.bgImageInactive = [NSImage imageNamed:@"scopebar_inactive.png"];
        windowActive = YES;
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect {
    NSImage *image = bgImageActive;
    if(!windowActive) {
        image = bgImageInactive;
    }
    NSRect tmp = [self bounds];
    int repeat = (int) ((tmp.size.width / 5) + 1);
    for(int i = 0;i < repeat;i++) {
        [image drawInRect:tmp fromRect:[self bounds] operation:NSCompositeSourceOver fraction:1.0];
        tmp.origin.x += 5;
    }
}

- (void)dealloc {
    [bgImageActive release];
    [bgImageInactive release];
    [super dealloc];
}

@end
