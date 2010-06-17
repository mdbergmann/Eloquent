//
//  ToolbarController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 08.03.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "ToolbarController.h"
#import "ObjCSword/Logger.h"
#import "SearchTextFieldOptions.h"

@interface ToolbarController ()

- (void)_loadNib;

@end

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
        LogL(LOG_ERR, @"[ToolbarController -init] unable to load nib!");
    }
}

- (void)awakeFromNib {
    [toolbar setAllowsUserCustomization:YES];
    //[self reportLoadingComplete];
}

- (NSToolbar *)toolbar {
    return toolbar;
}

- (NSView *)toolbarHUDView {
    return toolbarHUDView;
}

- (void)setScopebarView:(NSView *)aView {
    [scopebarPlaceholder setContentView:aView];
}

- (void)setSearchTextFieldRecents:(NSArray *)recents {
    [searchTextField setRecentSearches:recents];
    [hudSearchTextField setRecentSearches:recents];
}

- (void)setSearchTextFieldRecentsMenu:(NSMenu *)aMenu {
    [[searchTextField cell] setSearchMenuTemplate:aMenu];    
    [[hudSearchTextField cell] setSearchMenuTemplate:aMenu];    
}

- (void)setSearchTextFieldString:(NSString *)aString {
    [searchTextField setStringValue:aString];    
    [hudSearchTextField setStringValue:aString];    
}

- (void)setSearchTextFieldOptions:(SearchTextFieldOptions *)options {
    [searchTextField setContinuous:[options continuous]];
    [[searchTextField cell] setSendsSearchStringImmediately:[options sendsSearchStringImmediately]]; 
    [[searchTextField cell] setSendsWholeSearchString:[options sendsWholeSearchString]];    

    [hudSearchTextField setContinuous:[options continuous]];
    [[hudSearchTextField cell] setSendsSearchStringImmediately:[options sendsSearchStringImmediately]]; 
    [[hudSearchTextField cell] setSendsWholeSearchString:[options sendsWholeSearchString]];    
}

- (void)focusSearchTextField {
    [[delegate window] makeFirstResponder:searchTextField];    
}

- (void)setActiveSearchTypeSegElement:(SearchType)aType {
    [searchTypeSegControl selectSegmentWithTag:aType];    
    [hudSearchTypeSegControl selectSegmentWithTag:aType];    
}

- (void)setEnabled:(BOOL)flag searchTypeSegElement:(SearchType)aType {
    [[searchTypeSegControl cell] setEnabled:flag forSegment:aType];    
    [[hudSearchTypeSegControl cell] setEnabled:flag forSegment:aType];    
}

- (void)setBookmarkButtonEnabled:(BOOL)flag {
    [addBookmarkBtn setEnabled:flag];
}

- (void)setForceReloadButtonEnabled:(BOOL)flag {
    [forceReloadBtn setEnabled:flag];
    [hudForceReloadBtn setEnabled:flag];
}

- (void)setLSBToggleButtonImage:(NSImage *)anImage {
    [leftSideBarToggleBtn setImage:anImage];
    [hudLeftSideBarToggleBtn setImage:anImage];
}

- (void)setRSBToggleButtonImage:(NSImage *)anImage {
    [rightSideBarToggleBtn setImage:anImage];    
    [hudRightSideBarToggleBtn setImage:anImage];
}

# pragma mark - NSToolbarDelegate

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar  {
	NSArray *defaultItemArray = [NSArray arrayWithObjects:
                                 @"LeftSidebarButton",
                                 NSToolbarSpaceItemIdentifier,
                                 @"SearchTypeSegmentButton",
                                 @"ReferenceTextField",
                                 @"AddBookmarkButton",
                                 @"RefreshButton",
                                 @"FullscreenButton",
                                 NSToolbarSpaceItemIdentifier,
                                 @"RightSidebarButton",
                                 nil];
	
	return defaultItemArray;
}

/*
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

- (IBAction)quitFullscreenMode:(id)sender {
    [delegate quitFullscreenMode:sender];
}

- (IBAction)enterFullscreenMode:(id)sender {
    [delegate enterFullscreenMode:sender];
}

@end
