//
//  SideBarViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SideBarViewController.h"

@interface SideBarViewController ()

@end

@implementation SideBarViewController

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if(self) {
        // set delegate
        self.delegate = aDelegate;        
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[SideBarViewController -awakeFromNib]");
    
    // loading finished
    viewLoaded = YES;
    [self reportLoadingComplete];
}

- (NSView *)resizeControl {
    return sidebarResizeControl;
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
}

- (void)removeSubview:(HostableViewController *)aViewController {
    // remove the view of the send controller from our hosts
    NSView *view = [aViewController view];
    [view removeFromSuperview];
}

@end
