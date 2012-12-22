//
//  ScrollSynchronizableView.m
//  Eloquent
//
//  Created by Manfred Bergmann on 20.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ScrollSynchronizableView.h"

@implementation ScrollSynchronizableView

@synthesize syncScrollView;
@synthesize textView;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
    [super drawRect:rect];
}

- (void)dealloc {
    [syncScrollView release];
    [textView release];
    [super dealloc];
}

@end
