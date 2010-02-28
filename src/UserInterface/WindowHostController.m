//
//  WindowHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 05.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WindowHostController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "AppController.h"
#import "SearchTextObject.h"
#import "LeftSideBarViewController.h"
#import "RightSideBarViewController.h"
#import "SwordManager.h"
#import "ScopeBarView.h"
#import "FullScreenView.h"
#import "ModuleCommonsViewController.h"
#import "BibleCombiViewController.h"
#import "CommentaryViewController.h"
#import "GenBookViewController.h"
#import "DictionaryViewController.h"
#import "SwordVerseKey.h"
#import "SingleViewHostController.h"
#import "ModulesUIController.h"
#import "BookmarksUIController.h"
#import "NotesUIController.h"
#import "WorkspaceViewHostController.h"
#import "NotesViewController.h"
#import "WindowHostController+SideBars.h"
#import "ObjectAssotiations.h"
#import "SearchTextFieldOptions.h"

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
        
        [self setCurrentSearchText:[[SearchTextObject alloc] init]];
        
        lsbViewController = [[LeftSideBarViewController alloc] initWithDelegate:self];
        [lsbViewController setHostingDelegate:self];
        
        rsbViewController = [[RightSideBarViewController alloc] initWithDelegate:self];
        [rsbViewController setHostingDelegate:self];
        
        modulesUIController = [[ModulesUIController alloc] initWithDelegate:lsbViewController hostingDelegate:self];
        [Assotiater registerObject:modulesUIController forAssotiatedObject:self withKey:&ModuleListUI];
        bookmarksUIController = [[BookmarksUIController alloc] initWithDelegate:lsbViewController hostingDelegate:self];
        [Assotiater registerObject:bookmarksUIController forAssotiatedObject:self withKey:&BookmarkMgrUI];    
        notesUIController = [[NotesUIController alloc] initWithDelegate:lsbViewController hostingDelegate:self];
        [Assotiater registerObject:notesUIController forAssotiatedObject:self withKey:&NotesMgrUI];    
    }
    
    return self;
}

- (void)awakeFromNib {
    [view setDelegate:self];
    
    defaultLSBWidth = [[userDefaults objectForKey:DefaultsLSBWidth] intValue];
    defaultRSBWidth = [[userDefaults objectForKey:DefaultsRSBWidth] intValue];
    
    [mainSplitView setVertical:YES];
    [mainSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    [mainSplitView setDelegate:self];

    [contentSplitView setVertical:YES];
    [contentSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    [contentSplitView setDelegate:self];
    
    [[self window] setAcceptsMouseMovedEvents:YES];
    
    [self showLeftSideBar:lsbShowing];
    [self showRightSideBar:rsbShowing];
    
    NSMenu *recentsMenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"SearchMenu", @"")];
    [recentsMenu setAutoenablesItems:YES];
    // recent searches
    NSMenuItem *item = [recentsMenu addItemWithTitle:NSLocalizedString(@"RecentSearches", @"") action:nil keyEquivalent:@""];
    [item setTag:NSSearchFieldRecentsTitleMenuItemTag];
    // recents
    item = [recentsMenu addItemWithTitle:NSLocalizedString(@"Recents", @"") action:nil keyEquivalent:@""];
    [item setTag:NSSearchFieldRecentsMenuItemTag];    
    // install menu
    [[searchTextField cell] setSearchMenuTemplate:recentsMenu];
    // we start with reference search type
    [currentSearchText setSearchType:ReferenceSearchType];
    // set search string
    [searchTextField setStringValue:[self searchText]];
}

#pragma mark - Actions

- (IBAction)clearRecents:(id)sender {
    NSMutableArray *recents = [currentSearchText recentSearchsForType:[currentSearchText searchType]];
    [recents removeAllObjects];
    [searchTextField setRecentSearches:recents];
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
    [[self window] makeFirstResponder:searchTextField];
}

- (IBAction)nextBook:(id)sender {
    // get current search entry, take the first versekey's book and add 1
    if([contentViewController isKindOfClass:[BibleCombiViewController class]] || 
        [contentViewController isKindOfClass:[CommentaryViewController class]]) {
        SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[(ModuleCommonsViewController *)contentViewController searchString]];
        [verseKey setBook:[verseKey book] + 1];
        [verseKey setChapter:1];
                
        // get verse key text
        NSString *keyStr = [NSString stringWithFormat:@"%@ %i", [verseKey bookName], [verseKey chapter]];
        [self setSearchText:keyStr];
    }
}

- (IBAction)previousBook:(id)sender {
    // get current search entry, take the first versekey's book and add 1
    if([contentViewController isKindOfClass:[BibleCombiViewController class]] || 
       [contentViewController isKindOfClass:[CommentaryViewController class]]) {
        SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[(ModuleCommonsViewController *)contentViewController searchString]];
        [verseKey setBook:[verseKey book] - 1];
        [verseKey setChapter:1];
        
        // get verse key text
        NSString *keyStr = [NSString stringWithFormat:@"%@ %i", [verseKey bookName], [verseKey chapter]];
        [self setSearchText:keyStr];
    }    
}

- (IBAction)nextChapter:(id)sender {
    // get current search entry, take the first versekey's book and add 1
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
    // get current search entry, take the first versekey's book and add 1
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
    [Assotiater unregisterForAssotiatedObject:self withKey:&NotesMgrUI];
    [Assotiater unregisterForAssotiatedObject:self withKey:&ModuleListUI];
    [Assotiater unregisterForAssotiatedObject:self withKey:&BookmarkMgrUI];
}

#pragma mark - Methods

- (NSView *)view {
    return (NSView *)view;
}

- (void)setView:(FullScreenView *)aView {
    view = aView;
}

- (void)setSearchType:(SearchType)aType {
    SearchType oldType = [self searchType];
    if(oldType != aType) {
        [currentSearchText setSearchType:aType];
        [searchTextField setStringValue:[self searchText]];
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
        [searchTextField setStringValue:aString];
        [contentViewController searchStringChanged:aString];
    }
    [[self window] setTitle:[self computeWindowTitle]];
}

- (NSString *)searchText {
    NSString *text = [currentSearchText searchTextForType:[self searchType]];
    return text;
}

- (void)setSearchTypeUI:(SearchType)aType {
    [self setSearchType:aType];
    [searchTypeSegControl selectSegmentWithTag:aType];
    [self readaptHostUI];
}

- (void)setupContentRelatedViews {
    [placeHolderView setContentView:[contentViewController view]];
    [rsbViewController setContentView:[contentViewController rightAccessoryView]];
    [placeHolderSearchOptionsView setContentView:[contentViewController topAccessoryView]];
    
    [self showRightSideBar:[contentViewController showsRightSideBar]];
}

- (void)readaptHostUI {
    SearchType stype = [currentSearchText searchType];
    [searchTextField setStringValue:[currentSearchText searchTextForType:stype]];
    [searchTextField setRecentSearches:[currentSearchText recentSearchsForType:stype]];
    
    if(contentViewController != nil) {
        // RSB
        [self showRightSideBar:[contentViewController showsRightSideBar]];
        [rsbViewController setContentView:[contentViewController rightAccessoryView]];
        // TOP
        [placeHolderSearchOptionsView setContentView:[contentViewController topAccessoryView]];
        
        // search type segmented view
        [[searchTypeSegControl cell] setEnabled:[contentViewController enableReferenceSearch] forSegment:0];
        [[searchTypeSegControl cell] setEnabled:[contentViewController enableIndexedSearch] forSegment:1];
        [searchTypeSegControl selectSegmentWithTag:[contentViewController preferedSearchType]];
        
        // search field
        SearchTextFieldOptions *options = [contentViewController searchFieldOptions];
        [searchTextField setContinuous:[options continuous]];
        [[searchTextField cell] setSendsSearchStringImmediately:[options sendsSearchStringImmediately]]; 
        [[searchTextField cell] setSendsWholeSearchString:[options sendsWholeSearchString]]; 
        
        // bookmark add button
        [addBookmarkBtn setEnabled:[contentViewController enableAddBookmarks]];
        
        // force reload button
        [forceReloadBtn setEnabled:[contentViewController enableForceReload]];        
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
        [ret appendString:[contentViewController title]];
    }    
    
    return ret;
}

- (ContentViewType)contentViewType {
    if(contentViewController && [contentViewController respondsToSelector:@selector(contentViewType)]) {
        return [(ContentDisplayingViewController *)contentViewController contentViewType];
    }
    return SwordBibleContentType;
}

#pragma mark - NSSplitView delegate methods

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    //detect if it's a window resize
    if ([sender inLiveResize]) {
        //info needed
        NSRect tmpRect = [sender bounds];
        NSArray *subviews = [sender subviews];

        if(sender == mainSplitView) {
            NSView *left = nil;
            NSRect leftRect = NSZeroRect;
            NSView *mid = nil;
            if([subviews count] > 1) {
                left = [subviews objectAtIndex:0];
                leftRect = [left bounds];
                mid = [subviews objectAtIndex:1];
            } else {
                mid = [subviews objectAtIndex:0];                
            }
            
            // left side stays fixed
            if(left) {
                tmpRect.size.width = leftRect.size.width;
                tmpRect.origin.x = 0;
                [left setFrame:tmpRect];                
            }
            
            // mid dynamic
            tmpRect.size.width = [sender bounds].size.width - (leftRect.size.width + [sender dividerThickness]);
            tmpRect.origin.x = leftRect.size.width + [sender dividerThickness];
            [mid setFrame:tmpRect];
        } else if(sender == contentSplitView) {
            NSView *left = [subviews objectAtIndex:0];
            NSView *right = nil;
            NSRect rightRect = NSZeroRect;
            if([subviews count] > 1) {
                right = [subviews objectAtIndex:1];
                rightRect = [right bounds];
            }
            
            // left side is dynamic
            tmpRect.size.width = [sender bounds].size.width - (rightRect.size.width + [sender dividerThickness]);
            tmpRect.origin.x = 0;
            [left setFrame:tmpRect];
            
            // right is fixed
            tmpRect.size.width = rightRect.size.width;
            tmpRect.origin.x = [sender bounds].size.width - (rightRect.size.width + [sender dividerThickness]) + 1;
            [right setFrame:tmpRect];
        }
    } else {
        [sender adjustSubviews];
    }
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification {
    if(hostLoaded) {
        NSSplitView *sv = [aNotification object];
        if(sv == mainSplitView) {
            NSSize s = [[lsbViewController view] frame].size;
            if(s.width > 20) {
                [userDefaults setInteger:s.width forKey:DefaultsLSBWidth];
            }
        } else if(sv == contentSplitView) {
            NSSize s = [[rsbViewController view] frame].size;
            if(s.width > 10) {
                rsbWidth = s.width;
                [userDefaults setInteger:rsbWidth forKey:DefaultsRSBWidth];
            }
        }        
    }
}

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
    if(splitView == mainSplitView) {
        return [[lsbViewController resizeControl] convertRect:[(NSView *)[lsbViewController resizeControl] bounds] toView:splitView];
    }
    
    return NSZeroRect;
}

#pragma mark - NSWindow delegate methods

- (void)windowDidBecomeKey:(NSNotification *)notification {
}

- (void)windowDidResignMain:(NSNotification *)notification {
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
        MBLOG(MBLOG_WARN, @"[WindowHostController -windowWillClose:] delegate does not respond to selector!");
    }
}

#pragma mark - Printing

- (IBAction)myPrint:(id)sender {
    // get print info
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
    
    // set margins
    [printInfo setLeftMargin:1.5 * (72.0 / 2.54)];
    [printInfo setRightMargin:1 * (72.0 / 2.54)];
    [printInfo setTopMargin:1.5 * (72.0 / 2.54)];
    [printInfo setBottomMargin:2.0 * (72.0 / 2.54)];
    
    // get print view
    if(contentViewController) {
        NSView *printView = [(ModuleCommonsViewController *)contentViewController printViewForInfo:printInfo];
        if(printView) {
            [printView print:self];
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
        //[mainSplitView addSubview:[aView view] positioned:NSWindowBelow relativeTo:placeHolderView];
        NSSize s = [[lsbViewController view] frame].size;
        s.width = lsbWidth;
        [[lsbViewController view] setFrameSize:s];
    } else if([aViewController isKindOfClass:[RightSideBarViewController class]]) {
        //[contentSplitView addSubview:[aView view] positioned:NSWindowAbove relativeTo:nil];
        NSSize s = [[rsbViewController view] frame].size;
        s.width = rsbWidth;
        [[rsbViewController view] setFrameSize:s];
    } else if([aViewController isKindOfClass:[ContentDisplayingViewController class]]) {
        self.contentViewController = (ContentDisplayingViewController *)aViewController;
        [self setupForContentViewController];
    }
}

- (void)setupForContentViewController {
    [self setSearchTypeUI:[contentViewController preferedSearchType]];
    [self setupContentRelatedViews];
    [contentViewController prepareContentForHost:self];
    [contentViewController searchStringChanged:[self searchText]];
    [self readaptHostUI];
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [[aViewController view] removeFromSuperview];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    [Assotiater setCurrentInitialisationHost:self];
    
    self.currentSearchText = [decoder decodeObjectForKey:@"SearchTextObject"];

    lsbWidth = [decoder decodeIntForKey:@"LSBWidth"];
    lsbShowing = [decoder decodeBoolForKey:@"LSBShowing"];
    if(lsbViewController == nil) {
        lsbViewController = [[LeftSideBarViewController alloc] initWithDelegate:self];
        [lsbViewController setHostingDelegate:self];
    }
    rsbWidth = [decoder decodeIntForKey:@"RSBWidth"];
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
    int w = lsbWidth;
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
    [encoder encodeInt:w forKey:@"RSBWidth"];
    [encoder encodeBool:rsbShowing forKey:@"RSBShowing"];
    
    // encode searchQuery
    [encoder encodeObject:currentSearchText forKey:@"SearchTextObject"];
    // encode window frame
    [encoder encodePoint:[[self window] frame].origin forKey:@"WindowOriginEncoded"];
    [encoder encodeSize:[[self window] frame].size forKey:@"WindowSizeEncoded"];
}

@end
