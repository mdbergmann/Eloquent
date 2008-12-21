//
//  ScopeBarView.m
//  MacSword2
//
//  Created by Manfred Bergmann on 28.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ScopeBarView.h"


@implementation ScopeBarView

@synthesize bgImageActive;
@synthesize bgImageNoneActive;
@dynamic windowActive;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.bgImageActive = [NSImage imageNamed:@"scopebar-active.png"];
        self.bgImageNoneActive = [NSImage imageNamed:@"scopebar-notactive.png"];
        windowActive = YES;
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
    
    NSImage *currImg = bgImageActive;
    if(!windowActive) {
        currImg = bgImageNoneActive;
    }
    
    NSRect tmp = [self bounds];
    int repeat = (tmp.size.width / 5) + 1;
    for(int i = 0;i < repeat;i++) {
        [currImg drawInRect:tmp fromRect:[self bounds] operation:NSCompositeSourceOver fraction:1.0];
        tmp.origin.x += 5;
    }
}

- (BOOL)windowActive {
    return windowActive;
}

- (void)setWindowActive:(BOOL)flag {
    windowActive = flag;
}

@end
