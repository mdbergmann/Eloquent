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

@class Bookmark;
@class ScopeBarView;
@class SearchTextObject;
@class FullScreenView;
@class LeftSideBarViewController;
@class RightSideBarViewController;
@class SingleViewHostController;
@class ContentDisplayingViewController;
@class ModulesUIController;
@class BookmarksUIController;
@class NotesUIController;

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
    
    id delegate;
    
    NSView *searchOptionsView;
    SearchTextObject *currentSearchText;

    ContentDisplayingViewController *contentViewController;
    
    LeftSideBarViewController *lsbViewController;
    float lsbWidth;
    float lsbWidthFullScreen;
    float defaultLSBWidth;
    
    RightSideBarViewController *rsbViewController;
    float rsbWidth;
    float rsbWidthFullScreen;
    float defaultRSBWidth;
        
    ModulesUIController *modulesUIController;
    BookmarksUIController *bookmarksUIController;
    NotesUIController *notesUIController;
    
    BOOL hostLoaded;
}

@property (readwrite) id delegate;
@property (readwrite) SearchType searchType;
@property (retain, readwrite) SearchTextObject *currentSearchText;
@property (retain, readwrite) ContentDisplayingViewController *contentViewController;

// methods
- (NSView *)view;
- (void)setView:(NSView *)aView;

/** sets the text string into the search text field */
- (void)setSearchText:(NSString *)aString;
- (NSString *)searchText;

/** sets the type of search to UI */
- (void)setSearchUIType:(SearchType)aType searchString:(NSString *)aString;

/** changes UI in regards to the module type */
- (void)adaptUIToCurrentlyDisplayingModuleType;

/** tells the lsb to open the module about window */
- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod;

- (ContentViewType)contentViewType;

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
- (IBAction)focusSearchEntry:(id)sender;
- (IBAction)nextBook:(id)sender;
- (IBAction)previousBook:(id)sender;
- (IBAction)nextChapter:(id)sender;
- (IBAction)previousChapter:(id)sender;
- (IBAction)performClose:(id)sender;

@end
