//
//  SideBarViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HostableViewController.h>
#import <ProtocolHelper.h>

@class ModulesUIController, BookmarksUIController, NotesUIController;

@interface SideBarViewController : HostableViewController <SubviewHosting> {
    IBOutlet NSOutlineView *outlineView;
    IBOutlet NSView *sidebarResizeControl;
}

// initialitazion
- (id)initWithDelegate:(WindowHostController *)aDelegate;

/** view of control rect */
- (NSView *)resizeControl;

- (ModulesUIController *)modulesUIController;
- (BookmarksUIController *)bookmarksUIController;
- (NotesUIController *)notesUIController;

// subviewhosting
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;

@end
