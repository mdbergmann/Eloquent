//
//  BookmarksUIController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 16.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import "LeftSideBarAccessoryUIController.h"

@class BookmarkManager;

@interface BookmarksUIController : LeftSideBarAccessoryUIController {
    // bookmark folder window    
    IBOutlet NSWindow *bookmarkFolderWindow;
    IBOutlet NSTextField *bookmarkFolderNameTextField;
    IBOutlet NSButton *bookmarkFolderOkButton;
    
    // bookmarks
    IBOutlet NSMenu *bookmarkMenu;
    IBOutlet NSWindow *bookmarkDetailPanel;
    IBOutlet NSTextField *bookmarkNameTextField;    
    IBOutlet NSObjectController *bmObjectController;
    IBOutlet NSButton *bookmarkOkButton;
    int bookmarkAction;
    NSMutableArray *bookmarkSelection;
    
    BookmarkManager *bookmarkManager;
}

@property (readonly) NSMenu *bookmarkMenu;

- (void)generateBookmarkMenu:(NSMenu **)itemMenu 
              withMenuTarget:(id)aTarget 
              withMenuAction:(SEL)aSelector;

// methods
- (void)bookmarkDialog:(id)sender;
- (void)bookmarkDialogForVerseList:(NSArray *)aVerseList;

// actions
- (IBAction)bookmarkMenuClicked:(id)sender;
- (IBAction)bmWindowCancel:(id)sender;
- (IBAction)bmWindowOk:(id)sender;
- (IBAction)bmFolderWindowCancel:(id)sender;
- (IBAction)bmFolderWindowOk:(id)sender;

@end
