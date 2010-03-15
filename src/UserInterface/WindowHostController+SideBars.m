//
//  WindowHostController+SideBars.m
//  MacSword2
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "WindowHostController+SideBars.h"
#import "ToolbarController.h"
#import "NSImage+Additions.h"

@implementation WindowHostController (SideBars)

- (BOOL)showingLSB {
    BOOL ret = NO;
    if([[mainSplitView subviews] containsObject:[lsbViewController view]]) {
        ret = YES;
        // show image play to right
        [toolbarController setLSBToggleButtonImage:[NSImage imageNamed:NSImageNameSlideshowTemplate]];
    } else {
        // show image play to left
        [toolbarController setLSBToggleButtonImage:[(NSImage *)[NSImage imageNamed:NSImageNameSlideshowTemplate] mirrorVertically]];
    }
    
    return ret;
}

- (BOOL)showingRSB {
    BOOL ret = NO;
    if([[contentSplitView subviews] containsObject:[rsbViewController view]]) {
        ret = YES;
        // show image play to left
        [toolbarController setRSBToggleButtonImage:[(NSImage *)[NSImage imageNamed:NSImageNameSlideshowTemplate] mirrorVertically]];    
    } else {
        // show image play to right
        [toolbarController setRSBToggleButtonImage:[NSImage imageNamed:NSImageNameSlideshowTemplate]];
    }
    
    return ret;
}

- (BOOL)toggleLSB {
    BOOL show = ![self showingLSB];
    [self showLeftSideBar:show];
    return show;
}

- (BOOL)toggleRSB {
    BOOL show = ![self showingRSB];
    [self showRightSideBar:show];
    return show;
}

- (void)showLeftSideBar:(BOOL)flag {
    if(flag) {
        // if size is 0 set to default size
        if(lsbWidth == 0) {
            lsbWidth = defaultLSBWidth;
        }        
        // change size of view
        NSView *v = [lsbViewController view];
        NSSize size = [v frame].size;
        size.width = lsbWidth;
        [mainSplitView addSubview:v positioned:NSWindowBelow relativeTo:nil];
        [[v animator] setFrameSize:size];
    } else {
        // shrink the view
        NSView *v = [lsbViewController view];
        NSSize size = [v frame].size;
        if(size.width > 0) {
            lsbWidth = size.width;
        }
        [[v animator] removeFromSuperview];
    }
    [self showingLSB];
    
    [mainSplitView setNeedsDisplay:YES];
    [mainSplitView adjustSubviews];
}

- (void)showRightSideBar:(BOOL)flag {
    if(flag) {
        // if size is 0 set to default size
        if(rsbWidth == 0) {
            rsbWidth = defaultRSBWidth;
        }
        // change size of view
        NSView *v = [rsbViewController view];
        NSSize size = [v frame].size;
        size.width = rsbWidth;
        [contentSplitView addSubview:v positioned:NSWindowAbove relativeTo:nil];
        [[v animator] setFrameSize:size];
    } else {
        // shrink the view
        NSView *v = [rsbViewController view];
        NSSize size = [v frame].size;
        if(size.width > 0) {
            rsbWidth = size.width;
        }
        [[v animator] removeFromSuperview];
    }
    [self showingRSB];
    
    [contentSplitView setNeedsDisplay:YES];
    [contentSplitView adjustSubviews];
}

@end
