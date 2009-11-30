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

@class BookmarkManagerUIController;
@class BookmarkManager;
@class SwordManager;
@class ModuleListUIController;
@class NotesManager;
@class NotesUIController;
@class ThreeCellsCell;

@interface LeftSideBarViewController : SideBarViewController <SubviewHosting> {
        
    BookmarkManagerUIController *bookmarksUIController;
    BookmarkManager *bookmarkManager;
    
    ModuleListUIController *moduleListUIController;
    SwordManager *swordManager;
    
    NotesUIController *notesUIController;
    NotesManager *notesManager;
    
    // images
    NSImage *bookmarkGroupImage;
    NSImage *bookmarkImage;
    NSImage *lockedImage;
    NSImage *unlockedImage;
    NSImage *notesDrawer;
    
    // clicked module
    SwordModule *clickedMod;
    
    // our custom cell
    ThreeCellsCell *threeCellsCell;
}

// initialitazion
- (id)initWithDelegate:(id)aDelegate;

// OutlineView helper
- (id)objectForClickedRow;

// subviewhosting
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;

- (void)reload;
- (void)doubleClick;

@end
