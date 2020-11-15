//
//  BibleTextViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 14.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FooLogger/CocoLogger.h>
#import "ModuleViewController.h"

@class SwordBible;
@class GradientCell;
@class SearchBookSetEditorController;

#define BIBLEVIEW_NIBNAME   @"BibleView"

@interface BibleViewController : ModuleViewController <NSCoding, NSOutlineViewDelegate, NSOutlineViewDataSource> {
    IBOutlet NSButton *closeBtn;
    IBOutlet NSPopUpButton *addPopBtn;
    IBOutlet NSPopUpButton *modulePopBtn;
    
    IBOutlet NSView *sideBarView;
    IBOutlet NSOutlineView *entriesOutlineView;

    NSMenu *biblesMenu;
    NSMenu *commentariesMenu;
    
    // booksets controller
    SearchBookSetEditorController *searchBookSetsController;
    
    // gradient cell for outline view
    GradientCell *gradientCell;
    
    // helper vars for rendering
    int lastChapter;
    int lastBook;
}

@property (strong, readwrite) NSMutableArray *bookSelection;
@property (strong, readwrite) NSDictionary *outlineViewItems;

// ---------- initializers ---------
- (id)initWithModule:(SwordBible *)aModule;
- (id)initWithModule:(SwordBible *)aModule delegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate;

// ----------- methods -------------
// searchBookSetsController
- (SearchBookSetEditorController *)searchBookSetsController;

- (void)populateAddPopupMenu;
- (void)populateBookmarksMenu;

// actions
- (IBAction)addBookmark:(id)sender;
- (IBAction)addVersesToBookmark:(id)sender;
- (IBAction)addModule:(id)sender;
- (IBAction)closeButton:(id)sender;

@end
