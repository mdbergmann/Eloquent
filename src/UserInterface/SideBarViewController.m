//
//  SideBarViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SideBarViewController.h"


@implementation SideBarViewController

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[SideBarViewController -init] loading nib");
        
        // set delegate
        self.delegate = aDelegate;
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:SIDEBAROUTLINEVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SideBarViewController -init] unable to load nib!");
        } else {
            // default view is modules
            
        }            
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[SideBarViewController -awakeFromNib]");
    
    // loading finished
    viewLoaded = YES;
    [self reportLoadingComplete];
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOG(MBLOG_DEBUG, @"[SideBarViewController -contentViewInitFinished:]");
    // check if this view has completed loading annd also all of the subviews    
    if(viewLoaded == YES) {
        BOOL loaded = YES;
        
        if(loaded) {
            // report to super controller
            [self reportLoadingComplete];
        }
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    // remove the view of the send controller from our hosts
    NSView *view = [aViewController view];
    [view removeFromSuperview];
}

#pragma mark - Actions

- (IBAction)viewMenuChanged:(id)sender {

}

@end
