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
#import <ContentDisplayingViewController.h>

// toolbar identifiers
#define TB_ADD_BIBLE_ITEM           @"IdAddBible"
#define TB_MODULEINSTALLER_ITEM     @"IdModuleInstaller"
#define TB_SEARCH_TYPE_ITEM         @"IdSearchType"
#define TB_SEARCH_TEXT_ITEM         @"IdSearchText"
#define TB_ADDBOOKMARK_TYPE_ITEM    @"IdAddBookmark"
#define TB_FORCERELOAD_TYPE_ITEM    @"IdForceReload"
#define TB_NAVIGATION_TYPE_ITEM     @"IdNavigation"

@class Bookmark;
@class ScopeBarView;
@class SearchTextObject;
@class FullScreenView;
@class LeftSideBarViewController;
@class RightSideBarViewController;
@class SingleViewHostController;
@class ContentDisplayingViewController;
@class ModuleListUIController;
@class BookmarkManagerUIController;

@interface WindowHostController : NSWindowController <NSCoding, SubviewHosting, ContentSaving> {
    IBOutlet NSSplitView *mainSplitView;
    IBOutlet FullScreenView *view;
    IBOutlet NSSplitView *contentSplitView;
    IBOutlet NSBox *placeHolderView;
    IBOutlet NSBox *placeHolderSearchOptionsView;
    IBOutlet NSView *optionsView;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSButton *leftSideBarToggleBtn;
    IBOutlet NSButton *rightSideBarToggleBtn;
    IBOutlet NSButton *addBookmarkBtn;
    IBOutlet NSButton *forceReloadBtn;
    IBOutlet NSSearchField *searchTextField;
    IBOutlet NSSegmentedControl *searchTypeSegControl;
    
    ContentDisplayingViewController *contentViewController;

    id delegate;
    
    LeftSideBarViewController *lsbViewController;
    float lsbWidth;
    float lsbWidthFullScreen;
    float defaultLSBWidth;
    
    RightSideBarViewController *rsbViewController;
    float rsbWidth;
    float rsbWidthFullScreen;
    float defaultRSBWidth;
    
    NSView *searchOptionsView;
    SearchTextObject *currentSearchText;
    
    ModuleListUIController *moduleAccessoryViewController;
    BookmarkManagerUIController *bookmarkManagerUIController;
    
    BOOL hostLoaded;
}

@property (readwrite) id delegate;
@property (readwrite) SearchType searchType;
@property (retain, readwrite) SearchTextObject *currentSearchText;
@property (retain, readwrite) ContentDisplayingViewController *contentViewController;

// methods
- (NSView *)view;
- (void)setView:(NSView *)aView;

// sidebars
- (BOOL)toggleLSB;
- (BOOL)toggleRSB;
- (void)showLeftSideBar:(BOOL)flag;
- (void)showRightSideBar:(BOOL)flag;
- (BOOL)showingLSB;
- (BOOL)showingRSB;

//- (void)setupToolbar;

/** sets the text string into the search text field */
- (void)setSearchText:(NSString *)aString;
- (NSString *)searchText;

/** sets the type of search to UI */
- (void)setSearchUIType:(SearchType)aType searchString:(NSString *)aString;

/** change the module type that is currently displaying */
- (void)adaptUIToCurrentlyDisplayingModuleType;

/** tells the lsb to open the module about window */
- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod;

- (void)addBookmarkForVerses:(NSArray *)aVerseList;
- (void)addVerses:(NSArray *)aVerseList toBookmark:(Bookmark *)aBookmark;

- (ContentViewType)contentViewType;

// computed window title
- (NSString *)computeWindowTitle;
- (void)setupContentRelatedViews;
- (void)adaptAccessoryViewComponents;

// SubviewHosting
- (void)contentViewInitFinished:(HostableViewController *)aView;
- (void)removeSubview:(HostableViewController *)aViewController;

// ContentSaving
- (BOOL)hasUnsavedContent;
- (void)saveContent;

// actions
- (IBAction)clearRecents:(id)sender;
- (IBAction)addBookmark:(id)sender;
- (IBAction)searchInput:(id)sender;
- (IBAction)searchType:(id)sender;
- (IBAction)myPrint:(id)sender;
- (IBAction)forceReload:(id)sender;

// menu first responder actions
- (IBAction)leftSideBarHideShow:(id)sender;
- (IBAction)rightSideBarHideShow:(id)sender;
- (IBAction)switchLookupView:(id)sender;
- (IBAction)fullScreenModeOnOff:(id)sender;
- (IBAction)focusSearchEntry:(id)sender;
- (IBAction)nextBook:(id)sender;
- (IBAction)previousBook:(id)sender;
- (IBAction)nextChapter:(id)sender;
- (IBAction)previousChapter:(id)sender;
- (IBAction)performClose:(id)sender;

@end
