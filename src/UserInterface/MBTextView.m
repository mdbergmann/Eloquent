//
//  MBTextView.m
//  Eloquent
//
//  Created by Manfred Bergmann on 31.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MBTextView.h"


@implementation MBTextView

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
    
    if([menuItem action] == @selector(saveDocument:)) {
        if(![self isEditable]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return [super validateMenuItem:menuItem];
    }
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    CocoLog(LEVEL_DEBUG, @"[MBTextView -menuForEvent:] %@\n", [event description]);
    
    NSMenu *ret = [[self delegate] menuForEvent:event];
    if(!ret) {
        ret = [super menuForEvent:event];
    }
    
    return ret;
}

@end
