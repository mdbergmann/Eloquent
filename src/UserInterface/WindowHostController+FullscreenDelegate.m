//
//  WindowHostController+FullscreenDelegate.m
//  MacSword2
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "WindowHostController+FullscreenDelegate.h"
#import "WindowHostController+SideBars.h"
#import "ToolbarController.h"


@implementation WindowHostController (FullscreenDelegate)

- (void)goingToFullScreenMode {
    inFullScreenTransition = YES;
    MBLOG(MBLOG_DEBUG, @"going to fullscreen");
    
    NSView *topView = [contentViewController topAccessoryView];
    [topView removeFromSuperview];
    [toolbarController setScopebarView:topView];
}

- (void)goneToFullScreenMode {
    MBLOG(MBLOG_DEBUG, @"gone to fullscreen");
    inFullScreenTransition = NO;
}

- (void)leavingFullScreenMode {
    inFullScreenTransition = YES;
    MBLOG(MBLOG_DEBUG, @"leaving fullscreen");
    
    NSView *topView = [contentViewController topAccessoryView];
    [topView removeFromSuperview];
    [scopebarViewPlaceholder setContentView:topView];
}

- (void)leftFullScreenMode {
    MBLOG(MBLOG_DEBUG, @"left fullscreen");
    inFullScreenTransition = NO;
}

- (IBAction)fullScreenModeOnOff:(id)sender {
    [view fullScreenModeOnOff:sender];
}

@end
