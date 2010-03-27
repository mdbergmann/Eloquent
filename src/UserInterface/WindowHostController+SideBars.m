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
        if(lsbWidth == 0) {
            lsbWidth = defaultLSBWidth;
        }        
        NSView *v = [lsbViewController view];
        NSSize size = [v frame].size;
        size.width = lsbWidth;
        [[v animator] setFrameSize:size];
        [mainSplitView addSubview:v positioned:NSWindowBelow relativeTo:nil];
    } else {
        NSView *v = [lsbViewController view];
        NSSize size = [v frame].size;
        if(size.width > 0) {
            lsbWidth = size.width;
        }
        [v removeFromSuperview];
    }
    [self showingLSB];
}

- (void)showRightSideBar:(BOOL)flag {
    if(flag) {
        if(rsbWidth == 0) {
            rsbWidth = defaultRSBWidth;
        }
        NSView *v = [rsbViewController view];
        NSSize size = [v frame].size;
        size.width = rsbWidth;
        [[v animator] setFrameSize:size];
        [contentSplitView addSubview:v positioned:NSWindowAbove relativeTo:nil];
    } else {
        NSView *v = [rsbViewController view];
        NSSize size = [v frame].size;
        if(size.width > 0) {
            rsbWidth = size.width;
        }
        [v removeFromSuperview];
    }
    [self showingRSB];
}

@end
