//
//  WindowHostController+SideBars.m
//  Eloquent
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "WindowHostController+SideBars.h"
#import "ToolbarController.h"
#import "WorkspaceViewHostController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "LeftSideBarViewController.h"
#import "RightSideBarViewController.h"

@implementation WindowHostController (SideBars)

- (BOOL)showingLSB {
    return [[mainSplitView subviews] containsObject:[lsbViewController view]];
}

- (BOOL)showingRSB {
    return [[contentSplitView subviews] containsObject:[rsbViewController view]];
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
        [mainSplitView addSubview:[lsbViewController view] positioned:NSWindowBelow relativeTo:nil];
        [self restoreLeftSideBarWithWidth:lsbWidth];
    } else {
        NSView *v = [lsbViewController view];
        NSSize size = [v frame].size;
        if(size.width > 0) {
            lsbWidth = (float) size.width;
        }
        [v removeFromSuperview];
    }
    [self showingLSB];
}

- (void)showRightSideBar:(BOOL)flag {
    if(flag) {
        if(![self showingRSB]) {
            if(rsbWidth == 0) {
                rsbWidth = defaultRSBWidth;
            }
            NSView *v = [rsbViewController view];
            [contentSplitView addSubview:v positioned:NSWindowAbove relativeTo:nil];
            [self restoreRightSideBarWithWidth:rsbWidth];            
        }
    } else {
        NSView *v = [rsbViewController view];
        NSSize size = [v frame].size;
        if(size.width > 0) {
            rsbWidth = (float) size.width;
        }
        [v removeFromSuperview];
    }
    [self showingRSB];
    [self storeRSBUserDefaults];
    [contentViewController setShowingRSBPreferred:flag];
}

- (void)restoreLeftSideBarWithWidth:(float)width {
    NSView *lv = [lsbViewController view];
    NSRect lvRect = [lv frame];
    lvRect.size.width = width;
    [lv setFrameSize:lvRect.size];

    NSRect rvRect = [contentPlaceHolderView frame];
    rvRect.size.width = [mainSplitView frame].size.width - (lvRect.size.width + [mainSplitView dividerThickness]);
    [contentPlaceHolderView setFrameSize:rvRect.size];    
}

- (void)restoreRightSideBarWithWidth:(float)width {
    NSView *rv = [rsbViewController view];
    NSRect rvRect = [rv frame];
    rvRect.size.width = width;
    [rv setFrameSize:rvRect.size];
    
    NSRect lvRect = [placeHolderView frame];
    lvRect.size.width = [contentSplitView frame].size.width - (rvRect.size.width + [contentSplitView dividerThickness]);
    [placeHolderView setFrameSize:lvRect.size];
}

- (void)storeRSBUserDefaults {
    if([self isKindOfClass:[WorkspaceViewHostController class]]) {
        [userDefaults setBool:[self showingRSB] forKey:DefaultsShowRSBWorkspace];
    } else {
        [userDefaults setBool:[self showingRSB] forKey:DefaultsShowRSBSingle];
    }    
}

@end
