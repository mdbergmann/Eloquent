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

/** we react on save menu item */
- (IBAction)saveDocument:(id)sender {
    [[self delegate] saveDocument:sender];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    
    if([self isEditable] && [menuItem action] == @selector(saveDocument:)) {
        MBLOG(MBLOG_DEBUG, @"[MBTextView -validateMenuItem:] enabling Save menuItem");
        return YES;    
    }
    
    return NO;
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
