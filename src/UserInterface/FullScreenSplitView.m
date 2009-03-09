//
//  FullScreenSplitView.m
//  MacSword2
//
//  Created by Manfred Bergmann on 09.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FullScreenSplitView.h"


@implementation FullScreenSplitView

- (BOOL)isFullScreenMode {
    return [self isInFullScreenMode];
}

- (void)setFullScreenMode:(BOOL)flag {
    if(flag) {
        [self enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
    } else {
        [self exitFullScreenModeWithOptions:nil];
    }
}

- (IBAction)fullScreenModeOnOff:(id)sender {
    [self setFullScreenMode:![self isFullScreenMode]];
}

@end
