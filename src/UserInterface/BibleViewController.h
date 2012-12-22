//
//  BibleTextViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 14.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
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
    
    // nib name
    NSString *nibName;
        
    // bible book selection in right sidebar
    NSMutableArray *bookSelection;
        
    // helper vars for rendering
    int lastChapter;
    int lastBook;
}

@property (retain, readwrite) NSString *nibName;
@property (retain, readwrite) NSMutableArray *bookSelection;

// ---------- initializers ---------
- (id)initWithModule:(SwordBible *)aModule;
- (id)initWithModule:(SwordBible *)aModule delegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate;

// ----------- methods -------------
// searchBookSetsController
- (SearchBookSetEditorController *)searchBookSetsController;

- (void)populateAddPopupMenu;
- (void)populateBookmarksMenu;

// selector called by menuitems
- (void)moduleSelectionChanged:(id)sender;

// actions
- (IBAction)addBookmark:(id)sender;
- (IBAction)addVersesToBookmark:(id)sender;
- (IBAction)addModule:(id)sender;
- (IBAction)closeButton:(id)sender;

@end
