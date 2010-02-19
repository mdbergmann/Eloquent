//
//  WindowHostController+FullscreenDelegate.m
//  MacSword2
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "WindowHostController+FullscreenDelegate.h"
#import "WindowHostController+SideBars.h"


@implementation WindowHostController (FullscreenDelegate)

- (void)goingToFullScreenMode {
    lsbWidthFullScreen = [[lsbViewController view] frame].size.width;
    rsbWidthFullScreen = [[rsbViewController view] frame].size.width;
}

- (void)goneToFullScreenMode {
    lsbWidth = lsbWidthFullScreen;
    [self showLeftSideBar:[self showingLSB]];
    rsbWidth = rsbWidthFullScreen;
    [self showRightSideBar:[self showingRSB]];
}

- (void)leavingFullScreenMode {
    lsbWidthFullScreen = [[lsbViewController view] frame].size.width;
    rsbWidthFullScreen = [[rsbViewController view] frame].size.width;    
}

- (void)leftFullScreenMode {
    lsbWidth = lsbWidthFullScreen;
    [self showLeftSideBar:[self showingLSB]];
    rsbWidth = rsbWidthFullScreen;
    [self showRightSideBar:[self showingRSB]];
}

@end
