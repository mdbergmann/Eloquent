//
//  ToolbarController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 08.03.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import "HostableViewController.h"

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
    IBOutlet NSButton *rightSideBarToggleBtn;
    IBOutlet NSButton *addBookmarkBtn;
    IBOutlet NSButton *forceReloadBtn;
    IBOutlet NSSearchField *searchTextField;
    IBOutlet NSSegmentedControl *searchTypeSegControl;

    IBOutlet NSToolbar *toolbar;
    IBOutlet NSToolbarItem *toolbarViewItem;
    IBOutlet NSToolbarItem *searchTextFieldItem;
    
    IBOutlet NSBox *scopebarPlaceholder;
    
    NSMutableDictionary *tbIdentifiers;
}

- (id)initWithDelegate:(WindowHostController *)aDelegate;

- (NSToolbar *)toolbar;

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

@end
