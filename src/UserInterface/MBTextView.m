//
//  MBTextView.m
//  MacSword2
//
//  Created by Manfred Bergmann on 31.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MBTextView.h"


@implementation MBTextView

@synthesize contextMenu;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    MBLOGV(MBLOG_DEBUG, @"[MBTextView -menuForEvent:] %@\n", [event description]);
    
    NSMenu *ret = contextMenu;
    if(!ret) {
        ret = [super menuForEvent:event];
    }
    
    return ret;
}

@end
