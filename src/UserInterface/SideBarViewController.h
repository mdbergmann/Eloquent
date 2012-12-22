//
//  SideBarViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HostableViewController.h"

@class ModulesUIController, BookmarksUIController, NotesUIController;

@interface SideBarViewController : HostableViewController {
    IBOutlet NSOutlineView *outlineView;
}

// initialitazion
- (id)initWithDelegate:(WindowHostController *)aDelegate;

- (ModulesUIController *)modulesUIController;
- (BookmarksUIController *)bookmarksUIController;
- (NotesUIController *)notesUIController;

@end
