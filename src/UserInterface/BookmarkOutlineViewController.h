//
//  BookmarkOutlineViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <HostableViewController.h>

#define BOOKMARKOUTLINEVIEW_NIBNAME   @"BookmarkOutlineView"

@class BookmarkManager;

@interface BookmarkOutlineViewController : HostableViewController {
    IBOutlet NSOutlineView *outlineView;
    IBOutlet NSMenu *bookmarkMenu;
    IBOutlet NSPanel *bookmarkPanel;
    
    /** the bookmark binding interface controller */
    IBOutlet NSTreeController *bmTreeController;
    IBOutlet NSObjectController *bmObjectController;
    
    /** the action in sheet */
    int bookmarkAction;
    
    /** bookmark selection */
    NSMutableArray *selection;
    
    // the BookmarkManager instance
    BookmarkManager *manager;
}

@property (readwrite) BookmarkManager *manager;

// initialitazion
- (id)initWithDelegate:(id)aDelegate;

// module menu
//--------------------------------------------------------------------
//----------- NSMenu validation --------------------------------
//--------------------------------------------------------------------
/**
 \brief validate menu
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;
- (IBAction)bookmarkMenuClicked:(id)sender;

- (IBAction)bmWindowCancel:(id)sender;
- (IBAction)bmWindowOk:(id)sender;

@end
