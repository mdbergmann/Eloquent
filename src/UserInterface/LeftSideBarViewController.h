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
#import <LeftSideBarAccessoryUIController.h>

@class BookmarksUIController;
@class BookmarkManager;
@class SwordManager;
@class ModulesUIController;
@class NotesManager;
@class NotesUIController;
@class ThreeCellsCell;

@interface LeftSideBarViewController : SideBarViewController <SubviewHosting, LeftSideBarDelegate> {
        
    BookmarkManager *bookmarkManager;
    SwordManager *swordManager;    
    NotesManager *notesManager;
    
    NSImage *bookmarkGroupImage;
    NSImage *bookmarkImage;
    NSImage *lockedImage;
    NSImage *unlockedImage;
    NSImage *notesDrawerImage;
    NSImage *noteImage;
    
    // root outlineview items
    id modulesRootItem;
    id bookmarksRootItem;
    id notesRootItem;
    
    SwordModule *clickedMod;
    
    ThreeCellsCell *threeCellsCell;
}

- (id)initWithDelegate:(WindowHostController *)aDelegate;

// LeftSideBarDelegate
- (id)objectForClickedRow;
- (void)doubleClick;
- (void)reloadForController:(LeftSideBarAccessoryUIController *)aController;

// subviewhosting
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;

@end
