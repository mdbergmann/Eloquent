//
//  WindowHostController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 05.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ProtocolHelper.h>
#import <Indexer.h>

// toolbar identifiers
#define TB_ADD_BIBLE_ITEM           @"IdAddBible"
#define TB_MODULEINSTALLER_ITEM     @"IdModuleInstaller"
#define TB_SEARCH_TYPE_ITEM         @"IdSearchType"
#define TB_SEARCH_TEXT_ITEM         @"IdSearchText"
#define TB_ADDBOOKMARK_TYPE_ITEM    @"IdAddBookmark"
#define TB_FORCERELOAD_TYPE_ITEM    @"IdForceReload"
#define TB_NAVIGATION_TYPE_ITEM     @"IdNavigation"

@class ScopeBarView;
@class SearchTextObject;
@class FullScreenSplitView;
@class LeftSideBarViewController;
@class RightSideBarViewController;
@class SingleViewHostController;

@interface WindowHostController : NSWindowController <NSCoding, SubviewHosting, WindowHosting> {
    // splitView to add and remove modules view. splitview hosts placeHolderView
    IBOutlet FullScreenSplitView *mainSplitView;
    // the contentview of the window
    IBOutlet NSView *view;
    // splitView for placeholderview
    IBOutlet NSSplitView *contentSplitView;
    // placeholder for the main content view
    IBOutlet NSBox *placeHolderView;
    // placeholder for the search options
    IBOutlet NSBox *placeHolderSearchOptionsView;
    // options bar
    IBOutlet NSView *optionsView;
    // progress indicator
    IBOutlet NSProgressIndicator *progressIndicator;
    /** the segmentedcontrol for left sides */
    IBOutlet NSSegmentedControl *leftSideBottomSegControl;
    /** the segmentedcontrol for right sides */
    IBOutlet NSSegmentedControl *rightSideBottomSegControl;
    IBOutlet NSButton *addBookmarkBtn;
    IBOutlet NSButton *forceReloadBtn;
    
    // the main view for placeHolderView
    HostableViewController *contentViewController;

    // our delegate
    id delegate;
    
	// we need a dictionary for all our toolbar identifiers
	NSMutableDictionary *tbIdentifiers;

    // every host has a left side bar view
    LeftSideBarViewController *lsbViewController;
    float lsbWidth;
    float defaultLSBWidth;
    
    // every host has a right side bar view
    RightSideBarViewController *rsbViewController;
    float rsbWidth;
    float defaultRSBWidth;
    
    // navigation segment control
    NSSegmentedControl *navigationSegControl;
    BOOL navigationAction;
    
    // search stuff
    NSSearchField *searchTextField;
    NSView *searchOptionsView;
    /** search type segmented control */
    NSSegmentedControl *searchTypeSegControl;
    // the search text helper object
    SearchTextObject *currentSearchText;
    
    /** flag indicating that the host has fully loaded */
    BOOL hostLoaded;
}

@property (readwrite) id delegate;
@property (readwrite) SearchType searchType;
@property (retain, readwrite) SearchTextObject *currentSearchText;

// methods
- (NSView *)view;
- (void)setView:(NSView *)aView;

// sidebars
- (void)toggleLSB;
- (void)toggleRSB;
- (void)showLeftSideBar:(BOOL)flag;
- (void)showRightSideBar:(BOOL)flag;
- (BOOL)showingLSB;
- (BOOL)showingRSB;

- (void)setupToolbar;

/** sets the text string into the search text field */
- (void)setSearchText:(NSString *)aString;
- (NSString *)searchText;

/** sets the type of search to UI */
- (void)setSearchUIType:(SearchType)aType searchString:(NSString *)aString;

/** action of any input to the search text field */
- (void)searchInput:(id)sender;

/** change the module type that is currently displaying */
- (void)adaptUIToCurrentlyDisplayingModuleType;

/** tells the lsb to open the module about window */
- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod;

// Printing
- (IBAction)myPrint:(id)sender;

// WindowHosting
- (ModuleType)moduleType;

// computed window title
- (NSString *)computeWindowTitle;

// SubviewHosting
- (void)contentViewInitFinished:(HostableViewController *)aView;
- (void)removeSubview:(HostableViewController *)aViewController;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

// actions
- (void)clearRecents:(id)sender;

// direct connections
- (IBAction)leftSideBottomSegChange:(id)sender;
- (IBAction)rightSideBottomSegChange:(id)sender;
- (IBAction)navigationAction:(id)sender;
- (IBAction)forceReload:(id)sender;

// menu first responder actions
- (IBAction)leftSideBarHideShow:(id)sender;
- (IBAction)rightSideBarHideShow:(id)sender;
- (IBAction)switchLookupView:(id)sender;
- (IBAction)navigationBack:(id)sender;
- (IBAction)navigationForward:(id)sender;
- (IBAction)fullScreenModeOnOff:(id)sender;
- (IBAction)focusSearchEntry:(id)sender;
- (IBAction)nextBook:(id)sender;
- (IBAction)previousBook:(id)sender;
- (IBAction)nextChapter:(id)sender;
- (IBAction)previousChapter:(id)sender;
- (IBAction)performClose:(id)sender;

@end
