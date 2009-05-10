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
@class BookmarkManager;
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
    
    // bookmark folder window    
    IBOutlet NSWindow *bookmarkFolderWindow;
    IBOutlet NSTextField *bookmarkFolderNameTextField;
    IBOutlet NSButton *bookmarkFolderOkButton;

    // bookmarks
    IBOutlet NSMenu *bookmarkMenu;
    IBOutlet NSWindow *bookmarkPanel;
    IBOutlet NSTextField *bookmarkNameTextField;    
    /** the bookmark binding interface controller */
    IBOutlet NSObjectController *bmObjectController;
    /** the action in sheet */
    int bookmarkAction;
    /** bookmark selection */
    NSMutableArray *bookmarkSelection;

    // the SwordManager instance
    SwordManager *swordManager;
    // the BookmarkManager instance
    BookmarkManager *bookmarkManager;
    
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
@property (readwrite) BookmarkManager *bookmarkManager;

// initialitazion
- (id)initWithDelegate:(id)aDelegate;

/** displays the module about sheet */
- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod;

// subviewhosting
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;

// menu validation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;

// convenience methods
- (void)bookmarkDialog:(id)sender;

// actions
- (IBAction)moduleMenuClicked:(id)sender;
- (IBAction)bookmarkMenuClicked:(id)sender;

- (IBAction)bmWindowCancel:(id)sender;
- (IBAction)bmWindowOk:(id)sender;

- (IBAction)bmFolderWindowCancel:(id)sender;
- (IBAction)bmFolderWindowOk:(id)sender;

- (IBAction)moduleAboutClose:(id)sender;
- (IBAction)moduleUnlockOk:(id)sender;
- (IBAction)moduleUnlockCancel:(id)sender;

@end
