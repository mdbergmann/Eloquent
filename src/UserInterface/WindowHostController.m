//
//  WindowHostController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 05.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HostableViewController.h"
#import "WindowHostController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "AppController.h"
#import "SearchTextObject.h"
#import "LeftSideBarViewController.h"
#import "RightSideBarViewController.h"
#import "ScopeBarView.h"
#import "FullScreenView.h"
#import "ModuleCommonsViewController.h"
#import "BibleCombiViewController.h"
#import "CommentaryViewController.h"
#import "SingleViewHostController.h"
#import "ModulesUIController.h"
#import "BookmarksUIController.h"
#import "NotesUIController.h"
#import "WindowHostController+SideBars.h"
#import "ObjectAssociations.h"
#import "SearchTextFieldOptions.h"
#import "ToolbarController.h"
#import "PrintAccessoryViewController.h"
#import "WindowHostController+Fullscreen.h"

extern char ModuleListUI;
extern char BookmarkMgrUI;
extern char NotesMgrUI;

@interface WindowHostController ()

- (NSString *)computeWindowTitle;

@end

@implementation WindowHostController

@synthesize delegate;
@dynamic searchType;
@synthesize currentSearchText;
@synthesize contentViewController;

typedef enum _NavigationDirectionType {
    DirectionBackward = 1,
    DirectionForward
}NavigationDirectionType;

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        hostLoaded = NO;
        inFullScreenTransition = NO;
        inFullScreenMode = NO;
        
        [self setCurrentSearchText:[[[SearchTextObject alloc] init] autorelease]];
        
        lsbViewController = [[LeftSideBarViewController alloc] initWithDelegate:self];
        [lsbViewController setHostingDelegate:self];
        
        rsbViewController = [[RightSideBarViewController alloc] initWithDelegate:self];
        [rsbViewController setHostingDelegate:self];
        
        modulesUIController = [[ModulesUIController alloc] initWithDelegate:lsbViewController hostingDelegate:self];
        [Associater registerObject:modulesUIController forAssociatedObject:self withKey:&ModuleListUI];
        bookmarksUIController = [[BookmarksUIController alloc] initWithDelegate:lsbViewController hostingDelegate:self];
        [Associater registerObject:bookmarksUIController forAssociatedObject:self withKey:&BookmarkMgrUI];
        notesUIController = [[NotesUIController alloc] initWithDelegate:lsbViewController hostingDelegate:self];
        [Associater registerObject:notesUIController forAssociatedObject:self withKey:&NotesMgrUI];
        
        toolbarController = [[ToolbarController alloc] initWithDelegate:self];
        printAccessoryController = [[PrintAccessoryViewController alloc] initWithPrintInfo:[[[NSPrintInfo alloc] init] autorelease]];
    }
    
    return self;
}

- (void)dealloc {
    [lsbViewController release];
    [rsbViewController release];
    [modulesUIController release];
    [bookmarksUIController release];
    [notesUIController release];
    [toolbarController release];
    [printAccessoryController release];
    [currentSearchText release];
    [contentViewController release];
    [super dealloc];
}

- (void)awakeFromNib {
    [view setDelegate:self];
    
    [view setToolbarController:toolbarController];
    
    defaultLSBWidth = [[userDefaults objectForKey:DefaultsLSBWidth] intValue];
    defaultRSBWidth = [[userDefaults objectForKey:DefaultsRSBWidth] intValue];
    
    [mainSplitView setVertical:YES];
    [mainSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    [mainSplitView setDelegate:self];

    [contentSplitView setVertical:YES];
    [contentSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    [contentSplitView setDelegate:self];
    
    [self showLeftSideBar:lsbShowing];
    //[self showRightSideBar:rsbShowing];

    [[self window] setToolbar:[toolbarController toolbar]];
    
    NSMenu *recentsMenu = [[[NSMenu alloc] initWithTitle:NSLocalizedString(@"SearchMenu", @"")] autorelease];
    [recentsMenu setAutoenablesItems:YES];
    // recent searches
    NSMenuItem *item = [recentsMenu addItemWithTitle:NSLocalizedString(@"RecentSearches", @"") action:nil keyEquivalent:@""];
    [item setTag:NSSearchFieldRecentsTitleMenuItemTag];
    // recents
    item = [recentsMenu addItemWithTitle:NSLocalizedString(@"Recents", @"") action:nil keyEquivalent:@""];
    [item setTag:NSSearchFieldRecentsMenuItemTag];
    
    // install menu
    [toolbarController setSearchTextFieldRecentsMenu:recentsMenu];

    // we start with reference search type
    [currentSearchText setSearchType:ReferenceSearchType];
    
    // set search string
    [toolbarController setSearchTextFieldString:[self searchText]];
}

#pragma mark - Actions

- (IBAction)clearRecents:(id)sender {
    NSMutableArray *recents = [currentSearchText recentSearchsForType:[currentSearchText searchType]];
    [recents removeAllObjects];
    [toolbarController setSearchTextFieldRecents:recents];
}

- (IBAction)addBookmark:(id)sender {
    [bookmarksUIController bookmarkDialog:sender];
}

- (IBAction)searchInput:(id)sender {
    // buffer search text string
    SearchType type = [currentSearchText searchType];
    NSString *searchText = [sender stringValue];
    
    // add to recent searches
    NSMutableArray *recentSearches = [currentSearchText recentSearchsForType:type];
    if(![recentSearches containsObject:searchText] && [searchText length] > 0) {
        [recentSearches addObject:searchText];
        // remove everything above 10 searches
        int len = [recentSearches count];
        if(len > 10) {
            [recentSearches removeObjectAtIndex:0];
        }            
    }
    [self setSearchText:searchText];
}

- (IBAction)searchType:(id)sender {
    SearchType type;
    if([(NSSegmentedControl *)sender selectedSegment] == 0) {
        type = ReferenceSearchType;
    } else {
        type = IndexSearchType;
    }
    [self setSearchType:type];
}

- (IBAction)forceReload:(id)sender {
    [contentViewController forceReload];
}

- (IBAction)leftSideBarHideShow:(id)sender {
    [self toggleLSB];
}

- (IBAction)rightSideBarHideShow:(id)sender {
    [self toggleRSB];
}

- (IBAction)switchLookupView:(id)sender {
    if([[self currentSearchText] searchType] == IndexSearchType) {
        [self setSearchTypeUI:ReferenceSearchType];
    } else {
        [self setSearchTypeUI:IndexSearchType];
    }
}

- (IBAction)focusSearchEntry:(id)sender {
    [toolbarController focusSearchTextField];
}

- (IBAction)nextBook:(id)sender {
    // get current search entry, take the first verseKey's book and add 1
    if([contentViewController isKindOfClass:[BibleCombiViewController class]] || 
        [contentViewController isKindOfClass:[CommentaryViewController class]]) {
        SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[(ModuleCommonsViewController *)contentViewController searchString]];
        [verseKey setBook:(char) ([verseKey book] + 1)];
        [verseKey setChapter:1];
                
        // get verse key text
        NSString *keyStr = [NSString stringWithFormat:@"%@ %i", [verseKey bookName], [verseKey chapter]];
        [self setSearchText:keyStr];
    }
}

- (IBAction)previousBook:(id)sender {
    // get current search entry, take the first verseKey's book and add 1
    if([contentViewController isKindOfClass:[BibleCombiViewController class]] || 
       [contentViewController isKindOfClass:[CommentaryViewController class]]) {
        SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[(ModuleCommonsViewController *)contentViewController searchString]];
        [verseKey setBook:(char) ([verseKey book] - 1)];
        [verseKey setChapter:1];
        
        // get verse key text
        NSString *keyStr = [NSString stringWithFormat:@"%@ %i", [verseKey bookName], [verseKey chapter]];
        [self setSearchText:keyStr];
    }    
}

- (IBAction)nextChapter:(id)sender {
    // get current search entry, take the first verseKey's book and add 1
    if([contentViewController isKindOfClass:[BibleCombiViewController class]] || 
       [contentViewController isKindOfClass:[CommentaryViewController class]]) {
        SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[(ModuleCommonsViewController *)contentViewController searchString]];
        [verseKey setChapter:[verseKey chapter] + 1];
        
        // get verse key text
        NSString *keyStr = [NSString stringWithFormat:@"%@ %i", [verseKey bookName], [verseKey chapter]];
        [self setSearchText:keyStr];
    }
}

- (IBAction)previousChapter:(id)sender {
    // get current search entry, take the first verseKey's book and add 1
    if([contentViewController isKindOfClass:[BibleCombiViewController class]] || 
       [contentViewController isKindOfClass:[CommentaryViewController class]]) {
        SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[(ModuleCommonsViewController *)contentViewController searchString]];
        [verseKey setChapter:[verseKey chapter] - 1];
        
        // get verse key text
        NSString *keyStr = [NSString stringWithFormat:@"%@ %i", [verseKey bookName], [verseKey chapter]];
        [self setSearchText:keyStr];
    }    
}

- (IBAction)performClose:(id)sender {
    [self close];
    [Associater unregisterForAssociatedObject:self withKey:&NotesMgrUI];
    [Associater unregisterForAssociatedObject:self withKey:&ModuleListUI];
    [Associater unregisterForAssociatedObject:self withKey:&BookmarkMgrUI];
}

#pragma mark - Methods

- (NSView *)view {
    return view;
}

- (void)setView:(FullScreenView *)aView {
    view = aView;
}

- (void)setSearchType:(SearchType)aType {
    SearchType oldType = [self searchType];
    if(oldType != aType) {
        [currentSearchText setSearchType:aType];
        [toolbarController setSearchTextFieldString:[self searchText]];
        [contentViewController searchTypeChanged:aType withSearchString:[self searchText]];
        [self readaptHostUI];
    }
}

- (SearchType)searchType; {
    return [currentSearchText searchType];
}

/** used to set text to the search field from outside */
- (void)setSearchText:(NSString *)aString {
    if(aString != nil) {
        [currentSearchText setSearchText:aString forSearchType:[self searchType]];
        [toolbarController setSearchTextFieldString:aString];
        [contentViewController searchStringChanged:aString];
    }
    [[self window] setTitle:[self computeWindowTitle]];
}

- (NSString *)searchText {
    NSString *text = [currentSearchText searchTextForType:[self searchType]];
    return text;
}

- (void)setSearchTypeUI:(SearchType)aType {
    [self setSearchType:aType];     // this will trigger -readaptHostUI
    [toolbarController setActiveSearchTypeSegElement:aType];
}

- (void)setupContentRelatedViews {
    [placeHolderView setContentView:[contentViewController view]];
    [rsbViewController setContentView:[contentViewController rightAccessoryView]];
    [scopebarViewPlaceholder setContentView:[contentViewController topAccessoryView]];
    
    [self showRightSideBar:[contentViewController showsRightSideBar]];
}

- (void)readaptHostUI {
    SearchType stype = [currentSearchText searchType];
    [toolbarController setSearchTextFieldString:[currentSearchText searchTextForType:stype]];
    [toolbarController setSearchTextFieldRecents:[currentSearchText recentSearchsForType:stype]];
    
    if(contentViewController != nil) {
        // RSB
        [rsbViewController setContentView:[contentViewController rightAccessoryView]];
        [self showRightSideBar:[contentViewController showsRightSideBar]];
        // TOP
        NSView *topView = [contentViewController topAccessoryView];
        if([self isFullScreenMode]) {
            [toolbarController setScopebarView:topView];
        } else {
            [scopebarViewPlaceholder setContentView:topView];            
        }
        
        // search type segmented view
        [toolbarController setEnabled:[contentViewController enableReferenceSearch] searchTypeSegElement:ReferenceSearchType];
        [toolbarController setEnabled:[contentViewController enableIndexedSearch] searchTypeSegElement:IndexSearchType];
        [toolbarController setActiveSearchTypeSegElement:[contentViewController preferredSearchType]];
        
        // search field
        [toolbarController setSearchTextFieldOptions:[contentViewController searchFieldOptions]];
        
        // bookmark add button
        [toolbarController setBookmarkButtonEnabled:[contentViewController enableAddBookmarks]];
        
        // force reload button
        [toolbarController setForceReloadButtonEnabled:[contentViewController enableForceReload]];
    }
    
    [[self window] setTitle:[self computeWindowTitle]];
}

- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod {
    [modulesUIController displayModuleAboutSheetForModule:aMod];
}

- (NSString *)computeWindowTitle {
    NSMutableString *ret = [NSMutableString string];
    
    if([self isKindOfClass:[SingleViewHostController class]]) {
        [ret appendFormat:@"%@ - ", NSLocalizedString(@"Single", @"")];
    } else {
        [ret appendFormat:@"%@ - ", NSLocalizedString(@"Workspace", @"")];    
    }
    
    if(contentViewController != nil) {
        NSString *title = @"";
        if(contentViewController != nil) {
            title = [contentViewController title];
        }
        [ret appendString:title];
    }    
    
    return ret;
}

- (ContentViewType)contentViewType {
    if(contentViewController && [contentViewController respondsToSelector:@selector(contentViewType)]) {
        return [contentViewController contentViewType];
    }
    return SwordBibleContentType;
}

#pragma mark - NSWindow delegate methods

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [scopebarView setWindowActive:YES];
}

- (void)windowDidResignMain:(NSNotification *)notification {
    [scopebarView setWindowActive:NO];
}

- (void)windowWillClose:(NSNotification *)notification {
    if([self hasUnsavedContent]) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"")
                                         defaultButton:NSLocalizedString(@"Yes", @"") 
                                       alternateButton:NSLocalizedString(@"No", @"") 
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"UnsavedContent", @"")];    
        NSInteger modalResult = [alert runModal];
        if(modalResult == NSAlertDefaultReturn) {
            [self saveContent];
        }
    }
    
    // tell delegate that we are closing
    if(delegate && [delegate respondsToSelector:@selector(hostClosing:)]) {
        [delegate performSelector:@selector(hostClosing:) withObject:self];
    } else {
        CocoLog(LEVEL_WARN, @"[WindowHostController -windowWillClose:] delegate does not respond to selector!");
    }
}

#pragma mark - Printing

- (IBAction)myPrint:(id)sender {
    NSPrintInfo *printInfo = [printAccessoryController printInfo];
    
    // set margins
    CGFloat factor = 72.0 / 2.54;
    
    [printInfo setLeftMargin:[userDefaults floatForKey:DefaultsPrintLeftMargin] * factor];
    [printInfo setRightMargin:[userDefaults floatForKey:DefaultsPrintRightMargin] * factor];
    [printInfo setTopMargin:[userDefaults floatForKey:DefaultsPrintTopMargin] * factor];
    [printInfo setBottomMargin:[userDefaults floatForKey:DefaultsPrintBottomMargin] * factor];
    
    [printInfo setHorizontallyCentered:[userDefaults boolForKey:DefaultsPrintCenterHorizontally]];
    [printInfo setVerticallyCentered:[userDefaults boolForKey:DefaultsPrintCenterVertically]];
    
    // get print view
    if(contentViewController) {
        NSView *printView = [(ModuleCommonsViewController *)contentViewController printViewForInfo:printInfo];
        if(printView) {
            
            NSPrintOperation *printOp = [NSPrintOperation printOperationWithView:printView printInfo:printInfo];
            [printOp runOperation];
        }
    }
}

#pragma mark - ContentSaving

- (BOOL)hasUnsavedContent {
    return [contentViewController hasUnsavedContent];
}

- (void)saveContent {
    [contentViewController saveContent];
}

#pragma mark - SubviewHosting protocol

- (void)addContentViewController:(ContentDisplayingViewController *)aViewController {
    self.contentViewController = aViewController;
    [contentViewController setDelegate:self];
    [self setupForContentViewController];
}

- (void)contentViewInitFinished:(HostableViewController *)aViewController {
    if([aViewController isKindOfClass:[LeftSideBarViewController class]]) {
        NSSize s = [[lsbViewController view] frame].size;
        s.width = lsbWidth;
        [[lsbViewController view] setFrameSize:s];
    } else if([aViewController isKindOfClass:[RightSideBarViewController class]]) {
        NSSize s = [[rsbViewController view] frame].size;
        s.width = rsbWidth;
        [[rsbViewController view] setFrameSize:s];
    } else if([aViewController isKindOfClass:[toolbarController class]]) {
        [[self window] setToolbar:[toolbarController toolbar]];
    } else if([aViewController isKindOfClass:[ContentDisplayingViewController class]]) {
        self.contentViewController = (ContentDisplayingViewController *)aViewController;
        [self setupForContentViewController];
    }
}

- (void)setupForContentViewController {
    [self setSearchTypeUI:[contentViewController preferredSearchType]];
    [self setupContentRelatedViews];
    [contentViewController searchStringChanged:[self searchText]];
    [contentViewController prepareContentForHost:self];
    [self readaptHostUI];
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [[aViewController view] removeFromSuperview];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    [Associater setCurrentInitialisationHost:self];
    
    self.currentSearchText = [decoder decodeObjectForKey:@"SearchTextObject"];

    lsbWidth = loadedLSBWidth = [decoder decodeIntForKey:@"LSBWidth"];
    lsbShowing = [decoder decodeBoolForKey:@"LSBShowing"];
    if(lsbViewController == nil) {
        lsbViewController = [[LeftSideBarViewController alloc] initWithDelegate:self];
        [lsbViewController setHostingDelegate:self];
    }
    rsbWidth = loadedRSBWidth = [decoder decodeIntForKey:@"RSBWidth"];
    rsbShowing = [decoder decodeBoolForKey:@"RSBShowing"];
    if(rsbViewController == nil) {
        rsbViewController = [[RightSideBarViewController alloc] initWithDelegate:self];
        [rsbViewController setHostingDelegate:self];    
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode LSB and RSB width
    lsbShowing = [self showingLSB];
    CGFloat w = lsbWidth;
    if(lsbShowing) {
        w = [[lsbViewController view] frame].size.width;
    }
    [encoder encodeInt:w forKey:@"LSBWidth"];
    [encoder encodeBool:lsbShowing forKey:@"LSBShowing"];
    rsbShowing = [self showingRSB];
    w = rsbWidth;
    if(rsbShowing) {
        w = [[rsbViewController view] frame].size.width;
    }
    [encoder encodeInt:(int)w forKey:@"RSBWidth"];
    [encoder encodeBool:rsbShowing forKey:@"RSBShowing"];
    
    // encode searchQuery
    [encoder encodeObject:currentSearchText forKey:@"SearchTextObject"];
    // encode window frame
    [encoder encodePoint:[[self window] frame].origin forKey:@"WindowOriginEncoded"];
    [encoder encodeSize:[[self window] frame].size forKey:@"WindowSizeEncoded"];
}

@end
