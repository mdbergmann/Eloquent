//
//  ToolbarController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 08.03.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <Indexer.h>
#import <HostableViewController.h>

// toolbar identifiers
#define TB_ADD_BIBLE_ITEM           @"IdAddBible"
#define TB_MODULEINSTALLER_ITEM     @"IdModuleInstaller"
#define TB_SEARCH_TYPE_ITEM         @"IdSearchType"
#define TB_SEARCH_TEXT_ITEM         @"IdSearchText"
#define TB_ADDBOOKMARK_TYPE_ITEM    @"IdAddBookmark"
#define TB_FORCERELOAD_TYPE_ITEM    @"IdForceReload"
#define TB_NAVIGATION_TYPE_ITEM     @"IdNavigation"

@class WindowHostController;
@class SearchTextFieldOptions;

@interface ToolbarController : HostableViewController {
    IBOutlet NSButton *leftSideBarToggleBtn;
    IBOutlet NSButton *hudLeftSideBarToggleBtn;
    IBOutlet NSButton *rightSideBarToggleBtn;
    IBOutlet NSButton *hudRightSideBarToggleBtn;
    IBOutlet NSButton *addBookmarkBtn;
    IBOutlet NSButton *forceReloadBtn;
    IBOutlet NSButton *hudForceReloadBtn;
    IBOutlet NSSearchField *searchTextField;
    IBOutlet NSSearchField *hudSearchTextField;
    IBOutlet NSSegmentedControl *searchTypeSegControl;
    IBOutlet NSSegmentedControl *hudSearchTypeSegControl;
    IBOutlet NSButton *enterFullscreenModeBtn;
    IBOutlet NSButton *quitFullscreenModeBtn;

    IBOutlet NSToolbar *toolbar;
    IBOutlet NSToolbarItem *toolbarViewItem;
    IBOutlet NSView *toolbarHUDView;
    
    IBOutlet NSBox *scopebarPlaceholder;
    
    NSMutableDictionary *tbIdentifiers;
}

- (NSToolbar *)toolbar;
- (NSView *)toolbarHUDView;

- (void)setScopebarView:(NSView *)aView;

- (void)setSearchTextFieldRecents:(NSArray *)recents;
- (void)setSearchTextFieldRecentsMenu:(NSMenu *)aMenu;
- (void)setSearchTextFieldString:(NSString *)aString;
- (void)setSearchTextFieldOptions:(SearchTextFieldOptions *)options;
- (void)focusSearchTextField;

- (void)setActiveSearchTypeSegElement:(SearchType)aType;
- (void)setEnabled:(BOOL)flag searchTypeSegElement:(SearchType)aType;

- (void)setBookmarkButtonEnabled:(BOOL)flag;
- (void)setForceReloadButtonEnabled:(BOOL)flag;

- (void)setLSBToggleButtonImage:(NSImage *)anImage;
- (void)setRSBToggleButtonImage:(NSImage *)anImage;

- (IBAction)clearRecents:(id)sender;
- (IBAction)addBookmark:(id)sender;
- (IBAction)searchInput:(id)sender;
- (IBAction)searchType:(id)sender;
- (IBAction)forceReload:(id)sender;
- (IBAction)leftSideBarHideShow:(id)sender;
- (IBAction)rightSideBarHideShow:(id)sender;
- (IBAction)enterFullscreenMode:(id)sender;
- (IBAction)quitFullscreenMode:(id)sender;

@end
