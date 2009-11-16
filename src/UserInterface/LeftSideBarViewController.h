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

#define LEFTSIDEBARVIEW_NIBNAME   @"LeftSideBarView"

@class SwordManager;
@class BookmarkManagerUIController;
@class NotesManager;
@class ThreeCellsCell;

@interface LeftSideBarViewController : SideBarViewController <SubviewHosting> {
    
    // module about
    IBOutlet NSWindow *moduleAboutWindow;
    IBOutlet NSTextView *moduleAboutTextView;
    // unlock window
    IBOutlet NSWindow *moduleUnlockWindow;
    IBOutlet NSTextField *moduleUnlockTextField;
    IBOutlet NSButton *moduleUnlockOKButton;
    // modules
    IBOutlet NSMenu *moduleMenu;
    
    BookmarkManagerUIController *bookmarksUIController;
    
    SwordManager *swordManager;
    NotesManager *notesManager;
    
    // images
    NSImage *bookmarkGroupImage;
    NSImage *bookmarkImage;
    NSImage *lockedImage;
    NSImage *unlockedImage;
    
    // clicked module
    SwordModule *clickedMod;
    
    // our custom cell
    ThreeCellsCell *threeCellsCell;
}

@property (readwrite) SwordManager *swordManager;
@property (readwrite) BookmarkManagerUIController *bookmarksUIController;
@property (readwrite) NotesManager *notesManager;

// initialitazion
- (id)initWithDelegate:(id)aDelegate;

// OutlineView helper
- (id)objectForClickedRow;

/** displays the module about sheet */
- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod;

// subviewhosting
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;

- (void)reload;
- (void)doubleClick;

// menu validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

// actions
- (IBAction)moduleMenuClicked:(id)sender;
- (IBAction)moduleAboutClose:(id)sender;
- (IBAction)moduleUnlockOk:(id)sender;
- (IBAction)moduleUnlockCancel:(id)sender;

@end
