//
//  HeaderImageView.m
//  Eloquent
//
//  Created by Manfred Bergmann on 24.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HeaderImageView.h"


@implementation HeaderImageView

@synthesize bgImage;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.bgImage = [NSImage imageNamed:@"header_gradient.png"];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
    NSRect tmp = [self bounds];
    int repeat = (int) ((tmp.size.width / 5) + 1);
    for(int i = 0;i < repeat;i++) {
        [bgImage drawInRect:tmp fromRect:[self bounds] operation:NSCompositeSourceOver fraction:1.0];
        tmp.origin.x += 5;
    }
}

- (void)dealloc {
    [bgImage release];
    [super dealloc];
}

@end
