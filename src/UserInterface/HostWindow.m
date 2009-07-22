//
//  HostWindow.m
//  MacSword2
//
//  Created by Manfred Bergmann on 05.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HostWindow.h"


@implementation HostWindow

- (IBAction)leftSideBarHideShow:(id)sender {
    [[self delegate] performSelector:@selector(leftSideBarHideShow:) withObject:sender];
}

- (IBAction)rightSideBarHideShow:(id)sender {
    [[self delegate] performSelector:@selector(rightSideBarHideShow:) withObject:sender];
}

- (IBAction)leftSideBottomSegChange:(id)sender {
    [[self delegate] performSelector:@selector(leftSideBottomSegChange:) withObject:sender];
}

- (IBAction)rightSideBottomSegChange:(id)sender {
    [[self delegate] performSelector:@selector(rightSideBottomSegChange:) withObject:sender];
}

- (IBAction)switchToRefLookup:(id)sender {
    [[self delegate] performSelector:@selector(switchToRefLookup:) withObject:sender];
}

- (IBAction)switchToIndexLookup:(id)sender {
    [[self delegate] performSelector:@selector(switchToIndexLookup:) withObject:sender];
}

- (IBAction)navigationAction:(id)sender {
    [[self delegate] performSelector:@selector(navigationAction:) withObject:sender];
}

- (IBAction)navigationBack:(id)sender {
    [[self delegate] performSelector:@selector(navigationBack:) withObject:sender];
}

- (IBAction)navigationForward:(id)sender {
    [[self delegate] performSelector:@selector(navigationForward:) withObject:sender];
}

- (IBAction)fullScreenModeOnOff:(id)sender {
    [[self delegate] performSelector:@selector(fullScreenModeOnOff:) withObject:sender];
}

- (IBAction)performClose:(id)sender {
    [[self delegate] performSelector:@selector(performClose:) withObject:sender];
}

@end
