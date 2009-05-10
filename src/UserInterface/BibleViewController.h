//
//  BibleTextViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 14.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <HostableViewController.h>
#import <ModuleViewController.h>
#import <ProtocolHelper.h>

@class SwordBible;
@class GradientCell;
@class SearchBookSetEditorController;

#define BIBLEVIEW_NIBNAME   @"BibleView"

/** the view of this view controller is a ScrollSynchronizableView */
@interface BibleViewController : ModuleViewController <NSCoding, TextDisplayable, SubviewHosting, MouseTracking> {
    // close button
    IBOutlet NSButton *closeBtn;
    // add button
    IBOutlet NSPopUpButton *addPopBtn;
    // module popup button
    IBOutlet NSPopUpButton *modulePopBtn;
    // status line
    IBOutlet NSTextField *statusLine;
    // the outlineview view for the bible books and chapters items
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
    
    // text display context
    NSInteger textContext;
}

@property (retain, readwrite) NSString *nibName;
@property (retain, readwrite) NSMutableArray *bookSelection;
@property (readwrite) NSInteger textContext;

// ---------- initializers ---------
- (id)initWithModule:(SwordBible *)aModule;
- (id)initWithModule:(SwordBible *)aModule delegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate;

// ----------- methods -------------

// accessory view
- (NSView *)listContentView;

// searchBookSetsController
- (SearchBookSetEditorController *)searchBookSetsController;

// pass further the scrollview
- (NSScrollView *)scrollView;

// method called by subview
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;
- (void)adaptUIToHost;
- (void)setStatusText:(NSString *)aText;
- (void)populateAddPopupMenu;

// protocol definitions
- (void)displayTextForReference:(NSString *)aReference;
- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType;
// selector called by menuitems
- (void)moduleSelectionChanged:(id)sender;

// MouseTracking
- (void)mouseEntered:(NSView *)theView;
- (void)mouseExited:(NSView *)theView;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

// actions
- (IBAction)addModule:(id)sender;
- (IBAction)closeButton:(id)sender;

@end
