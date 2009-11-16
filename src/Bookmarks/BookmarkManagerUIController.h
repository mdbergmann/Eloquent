//
//  BookmarkManagerUIController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 16.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@class BookmarkManager;

@interface BookmarkManagerUIController : NSObject {
    IBOutlet id delegate;
    IBOutlet id hostingDelegate;
    
    // bookmark folder window    
    IBOutlet NSWindow *bookmarkFolderWindow;
    IBOutlet NSTextField *bookmarkFolderNameTextField;
    IBOutlet NSButton *bookmarkFolderOkButton;
    
    // bookmarks
    IBOutlet NSMenu *bookmarkMenu;
    IBOutlet NSWindow *bookmarkDetailPanel;
    IBOutlet NSTextField *bookmarkNameTextField;    
    IBOutlet NSObjectController *bmObjectController;
    int bookmarkAction;
    NSMutableArray *bookmarkSelection;
    
    BookmarkManager *bookmarkManager;
}

@property (readwrite) id delegate;
@property (readwrite) id hostingDelegate;
@property (readonly) NSMenu *bookmarkMenu;

// init
- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate;

// methods
- (void)bookmarkDialog:(id)sender;

// actions
- (IBAction)bookmarkMenuClicked:(id)sender;
- (IBAction)bmWindowCancel:(id)sender;
- (IBAction)bmWindowOk:(id)sender;
- (IBAction)bmFolderWindowCancel:(id)sender;
- (IBAction)bmFolderWindowOk:(id)sender;

@end
