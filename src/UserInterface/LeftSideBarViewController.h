//
//  LeftSideBarViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SideBarViewController.h>
#import <HostableViewController.h>
#import <ProtocolHelper.h>

@class ModuleOutlineViewController, BookmarkOutlineViewController;

@interface LeftSideBarViewController : SideBarViewController <SubviewHosting> {
    ModuleOutlineViewController *moduleViewController;
    BookmarkOutlineViewController *bookmarksViewController;
}

// initialitazion
- (id)initWithDelegate:(id)aDelegate;

// subviewhosting
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;

// actions
- (IBAction)viewMenuChanged:(id)sender;

@end
