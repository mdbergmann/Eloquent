//
//  ToolbarController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 08.03.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "ToolbarController.h"
#import "SearchTextFieldOptions.h"

@implementation ToolbarController

- (id)initWithDelegate:(WindowHostController *)aDelegate {
    self = [super init];
    if(self) {
        [self setDelegate:aDelegate];
        [self _loadNib];
    }
    return self;
}

- (void)_loadNib {
    BOOL stat = [NSBundle loadNibNamed:@"WindowHostToolbar" owner:self];
    if(!stat) {
        CocoLog(LEVEL_ERR, @"unable to load nib!");
    }
}

- (void)awakeFromNib {
    [toolbar setAllowsUserCustomization:YES];
    [searchTextField setFrameSize:CGSizeMake(600.0, [searchTextField frame].size.height)];
    [searchTextFieldItem setMaxSize:CGSizeMake(600.0, [searchTextField frame].size.height)];
}

- (NSToolbar *)toolbar {
    return toolbar;
}

- (void)setScopebarView:(NSView *)aView {
    [scopebarPlaceholder setContentView:aView];
}

- (void)setSearchTextFieldRecents:(NSArray *)recents {
    [searchTextField setRecentSearches:recents];
}

- (void)setSearchTextFieldRecentsMenu:(NSMenu *)aMenu {
    [[searchTextField cell] setSearchMenuTemplate:aMenu];    
}

- (void)setSearchTextFieldString:(NSString *)aString {
    [searchTextField setStringValue:aString];    
}

- (void)setSearchTextFieldOptions:(SearchTextFieldOptions *)options {
    [searchTextField setContinuous:[options continuous]];
    [[searchTextField cell] setSendsSearchStringImmediately:[options sendsSearchStringImmediately]]; 
    [[searchTextField cell] setSendsWholeSearchString:[options sendsWholeSearchString]];    
}

- (void)focusSearchTextField {
    [[delegate window] makeFirstResponder:searchTextField];    
}

- (void)setActiveSearchTypeSegElement:(SearchType)aType {
    [searchTypeSegControl selectSegmentWithTag:aType];    
}

- (void)setEnabled:(BOOL)flag searchTypeSegElement:(SearchType)aType {
    [[searchTypeSegControl cell] setEnabled:flag forSegment:aType];    
}

- (void)setBookmarkButtonEnabled:(BOOL)flag {
    [addBookmarkBtn setEnabled:flag];
}

- (void)setForceReloadButtonEnabled:(BOOL)flag {
    [forceReloadBtn setEnabled:flag];
}

- (void)setLSBToggleButtonImage:(NSImage *)anImage {
    [leftSideBarToggleBtn setImage:anImage];
}

- (void)setRSBToggleButtonImage:(NSImage *)anImage {
    [rightSideBarToggleBtn setImage:anImage];    
}

# pragma mark - NSToolbarDelegate

/*
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar  {
	NSArray *defaultItemArray = [NSArray arrayWithObjects:
        @"LeftSidebarButton",
        NSToolbarFlexibleSpaceItemIdentifier,
        @"SearchTypeSegmentButton",
        @"ReferenceTextField",
        @"AddBookmarkButton",
        @"RefreshButton",
        NSToolbarFlexibleSpaceItemIdentifier,
        @"RightSidebarButton",
        nil];
	
	return defaultItemArray;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag {
	return [tbIdentifiers valueForKey:itemIdentifier];
}
 */

#pragma mark - Actions

- (IBAction)clearRecents:(id)sender {
    [delegate clearRecents:sender];
}

- (IBAction)addBookmark:(id)sender {
    [delegate addBookmark:sender];
}

- (IBAction)searchInput:(id)sender {
    [delegate searchInput:sender];
}

- (IBAction)searchType:(id)sender {
    [delegate searchType:sender];
}

- (IBAction)forceReload:(id)sender {
    [delegate forceReload:sender];
}

- (IBAction)leftSideBarHideShow:(id)sender {
    [delegate leftSideBarHideShow:sender];
}

- (IBAction)rightSideBarHideShow:(id)sender {
    [delegate rightSideBarHideShow:sender];
}

@end
