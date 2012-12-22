//
//  WindowHostController+Fullscreen.m
//  Eloquent
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "WindowHostController+Fullscreen.h"
#import "ToolbarController.h"
#import "WindowHostController.h"


@implementation WindowHostController (Fullscreen)

- (BOOL)isFullScreenMode {
    return inFullScreenMode;
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification {
    CocoLog(LEVEL_DEBUG, @"going to fullscreen");
    
    inFullScreenTransition = YES;
}

- (void)windowDidEnterFullScreen:(NSNotification *)notification {
    CocoLog(LEVEL_DEBUG, @"gone to fullscreen");
    
    inFullScreenTransition = NO;
    [self forceReload:nil];
    inFullScreenMode = YES;
}

- (void)windowWillExitFullScreen:(NSNotification *)notification {
    CocoLog(LEVEL_DEBUG, @"leaving fullscreen");
    
    inFullScreenTransition = YES;
}

- (void)windowDidExitFullScreen:(NSNotification *)notification {
    CocoLog(LEVEL_DEBUG, @"left fullscreen");
    
    inFullScreenTransition = NO;
    [self forceReload:nil];
    inFullScreenMode = NO;
}

@end
