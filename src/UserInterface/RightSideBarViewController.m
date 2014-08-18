//
//  RightSideBarViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 18.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HostableViewController.h"
#import "RightSideBarViewController.h"


@implementation RightSideBarViewController

- (id)initWithDelegate:(id)aDelegate {
    self = [super initWithDelegate:aDelegate];
    if(self) {
        // load nib
        BOOL stat = [NSBundle loadNibNamed:RIGHTSIDEBARVIEW_NIBNAME owner:self];
        if(!stat) {
            CocoLog(LEVEL_ERR, @"[RightSideBarViewController -init] unable to load nib!");
        } else {
        }            
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setContentView:(NSView *)aView {
    [placeholderView setContentView:aView];
}

- (NSView *)contentView {
    return [placeholderView contentView];
}

@end
