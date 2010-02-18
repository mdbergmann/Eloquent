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
#import "NSImage+Additions.h"
#import "FullScreenView.h"
#import "ModuleCommonsViewController.h"
#import "BibleCombiViewController.h"
#import "CommentaryViewController.h"
#import "GenBookViewController.h"
#import "DictionaryViewController.h"
#import "SwordVerseKey.h"
#import "SingleViewHostController.h"
#import "ModuleListUIController.h"
#import "BookmarkManagerUIController.h"
#import "WorkspaceViewHostController.h"
#import "NotesViewController.h"

@interface WindowHostController ()

- (void)goingToFullScreenMode;
- (void)goneToFullScreenMode;
- (void)leavingFullScreenMode;
- (void)leftFullScreenMode;

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
        
        moduleAccessoryViewController = [[ModuleListUIController alloc] initWithDelegate:lsbViewController hostingDelegate:self];
        bookmarkManagerUIController = [[BookmarkManagerUIController alloc] initWithDelegate:lsbViewController hostingDelegate:self];
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
    
    [self showingLSB];
    [self showingRSB];
    
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
    
    [self setupContentRelatedViews];
}

- (void)setSearchType:(SearchType)aType {
    [currentSearchText setSearchType:aType];
}

- (SearchType)searchType; {
    return [currentSearchText searchType];
}

- (void)setupContentRelatedViews {
    [placeHolderView setContentView:[contentViewController view]];        
    [rsbViewController setContentView:[(<AccessoryViewProviding>)contentViewController rightAccessoryView]];
    [placeHolderSearchOptionsView setContentView:[(<AccessoryViewProviding>)contentViewController topAccessoryView]];    
}

- (void)adaptAccessoryViewComponents {
    if(contentViewController != nil) {
        [contentViewController adaptTopAccessoryViewComponentsForSearchType:[self searchType]];
        [self showRightSideBar:[contentViewController showsRightSideBar]];
    }
}

#pragma mark - Actions

- (IBAction)clearRecents:(id)sender {
    NSMutableArray *recents = [currentSearchText recentSearchsForType:[currentSearchText searchType]];
    [recents removeAllObjects];
    [searchTextField setRecentSearches:recents];
}

- (IBAction)addBookmark:(id)sender {
    [bookmarkManagerUIController bookmarkDialog:sender];
}

- (IBAction)searchInput:(id)sender {
    // buffer search text string
    SearchType type = [currentSearchText searchType];
    NSString *searchText = [sender stringValue];
    [currentSearchText setSearchText:searchText forSearchType:type];
    
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
    [(<TextDisplayable>)contentViewController displayTextForReference:searchText searchType:type];
    
    [[self window] setTitle:[self computeWindowTitle]];
}

- (IBAction)searchType:(id)sender {
    SearchType type;
    if([(NSSegmentedControl *)sender selectedSegment] == 0) {
        type = ReferenceSearchType;
    } else {
        type = IndexSearchType;
    }
    [self setSearchUIType:type searchString:nil];
}

/** to be overriden by subclasses */
- (IBAction)forceReload:(id)sender {
}

- (IBAction)leftSideBarHideShow:(id)sender {
    [self toggleLSB];
}

- (IBAction)rightSideBarHideShow:(id)sender {
    [self toggleRSB];
}

- (IBAction)switchLookupView:(id)sender {
    if([[self currentSearchText] searchType] == IndexSearchType) {
        [self setSearchUIType:ReferenceSearchType searchString:nil];    
    } else {
        [self setSearchUIType:IndexSearchType searchString:nil];    
    }
}

- (IBAction)fullScreenModeOnOff:(id)sender {
    [view fullScreenModeOnOff:sender];
}

- (IBAction)focusSearchEntry:(id)sender {
    [[self window] makeFirstResponder:searchTextField];
}

- (IBAction)nextBook:(id)sender {
    // get current search entry, take the first versekey's book and add 1
    if([contentViewController isKindOfClass:[BibleCombiViewController class]] || 
        [contentViewController isKindOfClass:[CommentaryViewController class]]) {
        SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[(ModuleCommonsViewController *)contentViewController reference]];
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
        SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[(ModuleCommonsViewController *)contentViewController reference]];
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
        SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[(ModuleCommonsViewController *)contentViewController reference]];
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
        SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[(ModuleCommonsViewController *)contentViewController reference]];
        [verseKey setChapter:[verseKey chapter] - 1];
        
        // get verse key text
        NSString *keyStr = [NSString stringWithFormat:@"%@ %i", [verseKey bookName], [verseKey chapter]];
        [self setSearchText:keyStr];
    }    
}

- (IBAction)performClose:(id)sender {
    [self close];
}

#pragma mark - Methods

- (NSView *)view {
    return (NSView *)view;
}

- (void)setView:(FullScreenView *)aView {
    view = aView;
}

- (BOOL)showingLSB {
    BOOL ret = NO;
    if([[mainSplitView subviews] containsObject:[lsbViewController view]]) {
        ret = YES;
        // show image play to right
        [leftSideBarToggleBtn setImage:[NSImage imageNamed:NSImageNameSlideshowTemplate]];
    } else {
        // show image play to left
        [leftSideBarToggleBtn setImage:[(NSImage *)[NSImage imageNamed:NSImageNameSlideshowTemplate] mirrorVertically]];
    }
    
    return ret;
}

- (BOOL)showingRSB {
    BOOL ret = NO;
    if([[contentSplitView subviews] containsObject:[rsbViewController view]]) {
        ret = YES;
        // show image play to left
        [rightSideBarToggleBtn setImage:[(NSImage *)[NSImage imageNamed:NSImageNameSlideshowTemplate] mirrorVertically]];    
    } else {
        // show image play to right
        [rightSideBarToggleBtn setImage:[NSImage imageNamed:NSImageNameSlideshowTemplate]];
    }
    
    return ret;
}

- (BOOL)toggleLSB {
    BOOL show = ![self showingLSB];
    [self showLeftSideBar:show];
    return show;
}

- (BOOL)toggleRSB {
    BOOL show = ![self showingRSB];
    [self showRightSideBar:show];
    return show;
}

- (void)showLeftSideBar:(BOOL)flag {
    if(flag) {
        // if size is 0 set to default size
        if(lsbWidth == 0) {
            lsbWidth = defaultLSBWidth;
        }        
        // change size of view
        NSView *v = [lsbViewController view];
        NSSize size = [v frame].size;
        size.width = lsbWidth;
        [mainSplitView addSubview:v positioned:NSWindowBelow relativeTo:nil];
        [[v animator] setFrameSize:size];
    } else {
        // shrink the view
        NSView *v = [lsbViewController view];
        NSSize size = [v frame].size;
        if(size.width > 0) {
            lsbWidth = size.width;
        }
        [[v animator] removeFromSuperview];
    }
    [self showingLSB];
    
    [mainSplitView setNeedsDisplay:YES];
    [mainSplitView adjustSubviews];
}

- (void)showRightSideBar:(BOOL)flag {
    if(flag) {
        // if size is 0 set to default size
        if(rsbWidth == 0) {
            rsbWidth = defaultRSBWidth;
        }
        // change size of view
        NSView *v = [rsbViewController view];
        NSSize size = [v frame].size;
        size.width = rsbWidth;
        [contentSplitView addSubview:v positioned:NSWindowAbove relativeTo:nil];
        [[v animator] setFrameSize:size];
    } else {
        // shrink the view
        NSView *v = [rsbViewController view];
        NSSize size = [v frame].size;
        if(size.width > 0) {
            rsbWidth = size.width;
        }
        [[v animator] removeFromSuperview];
    }
    [self showingRSB];
    
    [contentSplitView setNeedsDisplay:YES];
    [contentSplitView adjustSubviews];
}

/** used to set text to the search field from outside */
- (void)setSearchText:(NSString *)aString {
    [searchTextField setStringValue:aString];
    [self searchInput:searchTextField];
}

- (NSString *)searchText {
    return [searchTextField stringValue];
}

/** sets the type of search to UI */
- (void)setSearchUIType:(SearchType)aType searchString:(NSString *)aString {
    
    SearchType oldType = [currentSearchText searchType];
    [currentSearchText setSearchType:aType];
    
    // set UI
    [searchTypeSegControl selectSegmentWithTag:aType];
    
    NSString *text = @"";
    // if the new search type is the same, we don't need to set anything
    if(aType != oldType) {
        text = [currentSearchText searchTextForType:aType];    
    }
    if(aString != nil) {
        text = aString;
    }
    [self setSearchText:text];
    
    [self adaptUIToCurrentlyDisplayingModuleType];
}

- (void)adaptUIToCurrentlyDisplayingModuleType {
    // -------------------------------
    // search text and recent searches
    // -------------------------------
    SearchType stype = [currentSearchText searchType];
    NSString *buf = [currentSearchText searchTextForType:stype];
    [searchTextField setStringValue:buf];
    NSArray *bufAr = [currentSearchText recentSearchsForType:stype];
    [searchTextField setRecentSearches:bufAr];
    
    // -------------------------------
    // content view controller stuff
    // -------------------------------
    if(contentViewController != nil) {
        [self adaptAccessoryViewComponents];
        [rsbViewController setContentView:[(<AccessoryViewProviding>)contentViewController rightAccessoryView]];    

        // -------------------------------
        // search segment control
        // -------------------------------
        if([contentViewController contentViewType] == SwordGenBookContentType ||
           [contentViewController contentViewType] == NoteContentType) {
            [currentSearchText setSearchType:IndexSearchType];
            [[searchTypeSegControl cell] setEnabled:NO forSegment:0];
            [[searchTypeSegControl cell] setEnabled:YES forSegment:1];
            [[searchTypeSegControl cell] setSelected:NO forSegment:0];
            [[searchTypeSegControl cell] setSelected:YES forSegment:1];        
        } else {        
            [[searchTypeSegControl cell] setEnabled:YES forSegment:0];
            [[searchTypeSegControl cell] setEnabled:YES forSegment:1];
            switch(stype) {
                case ReferenceSearchType:
                    [[searchTypeSegControl cell] setSelected:YES forSegment:0];
                    [[searchTypeSegControl cell] setSelected:NO forSegment:1];
                    break;
                case IndexSearchType:
                    [[searchTypeSegControl cell] setSelected:NO forSegment:0];
                    [[searchTypeSegControl cell] setSelected:YES forSegment:1];
                    break;
                case ViewSearchType:
                    break;
            }
        }
        
        // -----------------
        // search text field
        // -----------------
        if([contentViewController contentViewType] == SwordGenBookContentType ||
           [contentViewController contentViewType] == SwordDictionaryContentType ||
           [contentViewController contentViewType] == NoteContentType) {
            if(stype == ReferenceSearchType) {
                [searchTextField setContinuous:YES];
                [[searchTextField cell] setSendsSearchStringImmediately:YES];
                //[[searchTextField cell] setSendsWholeSearchString:NO];
            } else {
                [searchTextField setContinuous:NO];
                [[searchTextField cell] setSendsSearchStringImmediately:NO];
                [[searchTextField cell] setSendsWholeSearchString:YES];            
            }
        } else {
            [searchTextField setContinuous:NO];
            [[searchTextField cell] setSendsSearchStringImmediately:NO];
            [[searchTextField cell] setSendsWholeSearchString:YES];        
        }
        
        // -----------------
        // bookmark button
        // -----------------
        if([contentViewController contentViewType] == SwordBibleContentType ||
           [contentViewController contentViewType] == SwordCommentaryContentType) {
            [addBookmarkBtn setEnabled:(stype == ReferenceSearchType)];
            [forceReloadBtn setEnabled:YES];
        } else if([contentViewController contentViewType] == NoteContentType) {
            [addBookmarkBtn setEnabled:NO];
            [forceReloadBtn setEnabled:YES];
        } else {
            [addBookmarkBtn setEnabled:NO];
            [forceReloadBtn setEnabled:NO];    
        }
    }
    
    // -----------------
    // window title
    // -----------------
    [[self window] setTitle:[self computeWindowTitle]];
}

- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod {
    [moduleAccessoryViewController displayModuleAboutSheetForModule:aMod];
}

- (NSString *)computeWindowTitle {
    NSMutableString *ret = [NSMutableString string];
    
    if([self isKindOfClass:[SingleViewHostController class]]) {
        [ret appendFormat:@"%@ - ", NSLocalizedString(@"Single", @"")];
    } else {
        [ret appendFormat:@"%@ - ", NSLocalizedString(@"Workspace", @"")];    
    }
    
    if(contentViewController != nil) {
        if([contentViewController isSwordModuleContentType]) {
            SwordModule *mod = [(ModuleViewController *)contentViewController module];
            if(mod != nil) {
                [ret appendFormat:@"%@ - %@", [mod name], [searchTextField stringValue]];
            }            
        } else if([contentViewController isNoteContentType]) {
            [ret appendString:[(NotesViewController *)contentViewController label]];
        }
    }    
    
    return ret;
}

- (ContentViewType)contentViewType {
    if(contentViewController) {
        return [contentViewController contentViewType];
    }
    return SwordBibleContentType;
}

- (void)addBookmarkForVerses:(NSArray *)aVerseList {
    [bookmarkManagerUIController bookmarkDialogForVerseList:aVerseList];
}

- (void)addVerses:(NSArray *)aVerseList toBookmark:(Bookmark *)aBookmark {
    
}

#pragma mark - FullScreen stuff

- (void)goingToFullScreenMode {
    lsbWidthFullScreen = [[lsbViewController view] frame].size.width;
    rsbWidthFullScreen = [[rsbViewController view] frame].size.width;
}

- (void)goneToFullScreenMode {
    lsbWidth = lsbWidthFullScreen;
    [self showLeftSideBar:[self showingLSB]];
    rsbWidth = rsbWidthFullScreen;
    [self showRightSideBar:[self showingRSB]];
}

- (void)leavingFullScreenMode {
    lsbWidthFullScreen = [[lsbViewController view] frame].size.width;
    rsbWidthFullScreen = [[rsbViewController view] frame].size.width;    
}

- (void)leftFullScreenMode {
    lsbWidth = lsbWidthFullScreen;
    [self showLeftSideBar:[self showingLSB]];
    rsbWidth = rsbWidthFullScreen;
    [self showRightSideBar:[self showingRSB]];
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

- (void)contentViewInitFinished:(HostableViewController *)aView {
    if([aView isKindOfClass:[LeftSideBarViewController class]]) {
        //[mainSplitView addSubview:[aView view] positioned:NSWindowBelow relativeTo:placeHolderView];
        NSSize s = [[lsbViewController view] frame].size;
        s.width = lsbWidth;
        [[lsbViewController view] setFrameSize:s];
    } else if([aView isKindOfClass:[RightSideBarViewController class]]) {
        //[contentSplitView addSubview:[aView view] positioned:NSWindowAbove relativeTo:nil];
        NSSize s = [[rsbViewController view] frame].size;
        s.width = rsbWidth;
        [[rsbViewController view] setFrameSize:s];
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [[aViewController view] removeFromSuperview];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    // load lsb view
    lsbWidth = [decoder decodeIntForKey:@"LSBWidth"];
    if(lsbViewController == nil) {
        lsbViewController = [[LeftSideBarViewController alloc] initWithDelegate:self];
        [lsbViewController setHostingDelegate:self];
    }
    // load rsb view
    rsbWidth = [decoder decodeIntForKey:@"RSBWidth"];
    if(rsbViewController == nil) {
        rsbViewController = [[RightSideBarViewController alloc] initWithDelegate:self];
        [rsbViewController setHostingDelegate:self];    
    }

    moduleAccessoryViewController = [[ModuleListUIController alloc] initWithDelegate:lsbViewController hostingDelegate:self];
    bookmarkManagerUIController = [[BookmarkManagerUIController alloc] initWithDelegate:lsbViewController hostingDelegate:self];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode LSB and RSB width
    int w = lsbWidth;
    if([self showingLSB]) {
        w = [[lsbViewController view] frame].size.width;
    }
    [encoder encodeInt:w forKey:@"LSBWidth"];
    w = rsbWidth;
    if([self showingRSB]) {
        w = [[rsbViewController view] frame].size.width;
    }
    [encoder encodeInt:w forKey:@"RSBWidth"];
    
    // encode searchQuery
    [encoder encodeObject:currentSearchText forKey:@"SearchTextObject"];
    // encode window frame
    [encoder encodePoint:[[self window] frame].origin forKey:@"WindowOriginEncoded"];
    [encoder encodeSize:[[self window] frame].size forKey:@"WindowSizeEncoded"];
}

@end
