//
//  RightSideBarViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 18.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RightSideBarViewController.h"


@implementation RightSideBarViewController

- (id)initWithDelegate:(id)aDelegate {
    self = [super initWithDelegate:aDelegate];
    if(self) {
        // load nib
        BOOL stat = [NSBundle loadNibNamed:RIGHTSIDEBARVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[RightSideBarViewController -init] unable to load nib!");
        } else {
        }            
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[LeftSideBarViewController -awakeFromNib]");
    
    [super awakeFromNib];
}

- (void)setContentView:(NSView *)aView {
    [placeholderView setContentView:aView];
}

- (NSView *)contentView {
    return [placeholderView contentView];
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOGV(MBLOG_DEBUG, @"[RightSideBarViewController -contentViewInitFinished:] %@", [aView className]);
    
    // check if this view has completed loading annd also all of the subviews    
    if(viewLoaded == YES) {
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [super removeSubview:aViewController];
}

@end
