//
//  WindowHostController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 05.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Indexer.h"
#import "ContentDisplayingViewController.h"

@class Bookmark;
@class ScopeBarView;
@class SearchTextObject;
@class FullScreenView;
@class LeftSideBarViewController;
@class RightSideBarViewController;
@class SingleViewHostController;
@class HostableViewController;
@class ModulesUIController;
@class BookmarksUIController;
@class NotesUIController;
@class ToolbarController;
@class PrintAccessoryViewController;

@interface WindowHostController : NSWindowController <NSWindowDelegate, NSSplitViewDelegate, NSCoding, SubviewHosting, ContentSaving> {
    IBOutlet NSSplitView *mainSplitView;
    IBOutlet NSBox *contentPlaceHolderView;
    IBOutlet FullScreenView *view;

    IBOutlet NSSplitView *contentSplitView;
    IBOutlet NSBox *placeHolderView;

    IBOutlet ScopeBarView *scopebarView;
    IBOutlet NSBox *scopebarViewPlaceholder;
    
    IBOutlet NSProgressIndicator *progressIndicator;

    id delegate;
    
    NSView *searchOptionsView;
    SearchTextObject *currentSearchText;

    ContentDisplayingViewController *contentViewController;
    
    ToolbarController *toolbarController;
    
    LeftSideBarViewController *lsbViewController;
    float lsbWidth;
    float defaultLSBWidth;
    float loadedLSBWidth;
    BOOL lsbShowing;
    
    RightSideBarViewController *rsbViewController;
    float rsbWidth;
    float defaultRSBWidth;
    float loadedRSBWidth;
    BOOL rsbShowing;

    ModulesUIController *modulesUIController;
    BookmarksUIController *bookmarksUIController;
    NotesUIController *notesUIController;
    
    PrintAccessoryViewController *printAccessoryController;
    
    BOOL inFullScreenTransition;
    BOOL inFullScreenMode;
    
    BOOL hostLoaded;
}

@property (assign, readwrite) id delegate;
@property (readwrite) SearchType searchType;
@property (retain, readwrite) SearchTextObject *currentSearchText;
@property (retain, readwrite) ContentDisplayingViewController *contentViewController;

// methods
- (NSView *)view;
- (void)setView:(FullScreenView *)aView;

/** sets the text string into the search text field */
- (void)setSearchText:(NSString *)aString;
- (NSString *)searchText;

/** sets the type of search to UI */
- (void)setSearchTypeUI:(SearchType)aType;

/** tells the lsb to open the module about window */
- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod;

- (ContentViewType)contentViewType;
- (void)readaptHostUI;
- (void)setupContentRelatedViews;
- (void)setupForContentViewController;

// SubviewHosting
- (void)addContentViewController:(ContentDisplayingViewController *)aViewController;
- (void)contentViewInitFinished:(HostableViewController *)aView;
- (void)removeSubview:(HostableViewController *)aViewController;

// ContentSaving
- (BOOL)hasUnsavedContent;
- (void)saveContent;

// actions
- (IBAction)myPrint:(id)sender;
- (IBAction)clearRecents:(id)sender;
- (IBAction)addBookmark:(id)sender;
- (IBAction)searchInput:(id)sender;
- (IBAction)searchType:(id)sender;
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
