//
//  BibleTextViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 14.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BibleViewController.h"
#import "AppController.h"
#import "SingleViewHostController.h"
#import "BibleCombiViewController.h"
#import "ExtTextViewController.h"
#import "ScrollSynchronizableView.h"
#import "MBPreferenceController.h"
#import "ReferenceCacheManager.h"
#import "ReferenceCacheObject.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SwordBible.h"
#import "SwordSearching.h"
#import "SearchResultEntry.h"
#import "Highlighter.h"
#import "GradientCell.h"
#import "SearchBookSetEditorController.h"
#import "SearchBookSet.h"
#import "Bookmark.h"
#import "BookmarkManager.h"
#import "SwordVerseKey.h"
#import "IndexingManager.h"
#import "ModulesUIController.h"
#import "BookmarksUIController.h"
#import "SwordModuleTextEntry.h"
#import "SwordBibleTextEntry.h"
#import "NSUserDefaults+Additions.h"
#import "NSTextView+LookupAdditions.h"
#import "NSAttributedString+Additions.h"
#import "WorkspaceViewHostController.h"
#import "globals.h"
#import "SwordBibleBook.h"
#import "SwordBibleChapter.h"

@interface BibleViewController ()

/** selector called by menuitems */
- (void)moduleSelectionChanged:(id)sender;

- (void)checkPerformProgressCalculation;
- (void)updateContentCache;

@end

@implementation BibleViewController

#pragma mark - getter/setter

@synthesize nibName;
@synthesize bookSelection;
@synthesize textContext;

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        self.searchType = ReferenceSearchType;
        self.module = nil;
        self.delegate = nil;
        self.bookSelection = [NSMutableArray array];
        self.textContext = 0;
        
        // init SearchBookSetController
        searchBookSetsController = [[SearchBookSetEditorController alloc] init];
        [searchBookSetsController setDelegate:self];
    }
    
    return self;
}

- (id)initWithModule:(SwordBible *)aModule {
    return [self initWithModule:aModule delegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
    return [self initWithModule:nil delegate:aDelegate];
}

- (id)initWithModule:(SwordBible *)aModule delegate:(id)aDelegate {
    self = [self init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[BibleViewController -init]");
        
        // if given module is nil, choose the first found in SwordManager
        if(aModule == nil) {
            NSArray *modArray = [[SwordManager defaultManager] modulesForType:SWMOD_CATEGORY_BIBLES];
            if([modArray count] > 0) {
                aModule = [modArray objectAtIndex:0];
            }
        }
        self.module = (SwordModule *)aModule;
        self.delegate = aDelegate;
                
        self.nibName = BIBLEVIEW_NIBNAME;
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:nibName owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BibleViewController -init] unable to load nib!");            
        }        
    } else {
        MBLOG(MBLOG_ERR, @"[BibleViewController -init] unable init!");
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -awakeFromNib]");
    
    [super awakeFromNib];
        
    // prepare for our custom cell
    gradientCell = [[GradientCell alloc] init];
    NSTableColumn *tableColumn = [entriesOutlineView tableColumnWithIdentifier:@"common"];
    [tableColumn setDataCell:gradientCell];    
    
    // set menu states of display options
    [[displayOptionsMenu itemWithTag:1] setState:[[displayOptions objectForKey:DefaultsBibleTextVersesOnOneLineKey] intValue]];
    
    // if our hosted subview also has loaded, report that
    // else, wait until the subview has loaded and report then
    if([(HostableViewController *)contentDisplayController viewLoaded]) {
        // set sync scroll view
        [(ScrollSynchronizableView *)[self view] setSyncScrollView:[(<TextContentProviding>)contentDisplayController scrollView]];
        [(ScrollSynchronizableView *)[self view] setTextView:[(<TextContentProviding>)contentDisplayController textView]];
        
        // add the webview as contentvew to the placeholder    
        [placeHolderView setContentView:[contentDisplayController view]];
        [self reportLoadingComplete];
    }
    
    // create popup button menu
    [self populateModulesMenu];
    [self populateAddPopupMenu];
    
    [self adaptUIToHost];
    
    // create bookmarks menu
    NSMenu *bookmarksMenu = [[NSMenu alloc] init];
    [[self bookmarksUIController] generateBookmarkMenu:&bookmarksMenu withMenuTarget:self withMenuAction:@selector(addVersesToBookmark:)];
    NSMenuItem *item = [textContextMenu itemWithTag:AddVersesToBookmark];
    [item setSubmenu:bookmarksMenu];
    
    // if we have areference, display it
    if(reference && [reference length] > 0) {
        [self displayTextForReference:reference searchType:searchType];    
    }

    viewLoaded = YES;
}

#pragma mark - methods

- (SearchBookSetEditorController *)searchBookSetsController {
    return searchBookSetsController;
}

- (void)adaptUIToHost {
    if(delegate) {
        if([delegate respondsToSelector:@selector(bibleViewCount)]) {
            NSNumber *countTemp = [delegate performSelector:@selector(bibleViewCount)];
            int count = [countTemp intValue];
            if(count == 1) {
                [closeBtn setEnabled:NO];
            } else {
                [closeBtn setEnabled:YES];
            }
        }
    }
}

/**
 overriding from super class
 */
- (void)modulesListChanged:(NSNotification *)aNotification {
    [self populateModulesMenu];
    [self populateAddPopupMenu];
}

- (void)populateModulesMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    // generate menu
    [[self modulesUIController] generateModuleMenu:&menu 
                                     forModuletype:bible 
                                    withMenuTarget:self 
                                    withMenuAction:@selector(moduleSelectionChanged:)];
    // add menu
    [modulePopBtn setMenu:menu];
    
    // select module
    if(self.module != nil) {
        // on change, still exists?
        if(![[SwordManager defaultManager] moduleWithName:[module name]]) {
            // select the first one found
            NSArray *modArray = [[SwordManager defaultManager] modulesForType:SWMOD_CATEGORY_BIBLES];
            if([modArray count] > 0) {
                [self setModule:[modArray objectAtIndex:0]];
                // and redisplay if needed
                [self displayTextForReference:[self reference] searchType:searchType];
            }
        }
        
        [modulePopBtn selectItemWithTitle:[module name]];
    }
}

- (void)populateAddPopupMenu {
    // generate bibles menu
    biblesMenu = [[NSMenu alloc] init];
    [biblesMenu setAutoenablesItems:YES];
    [[self modulesUIController] generateModuleMenu:&biblesMenu 
                                     forModuletype:bible 
                                    withMenuTarget:self 
                                    withMenuAction:@selector(addModule:)];
    
    // generate commentary menu
    commentariesMenu = [[NSMenu alloc] init];
    [[self modulesUIController] generateModuleMenu:&commentariesMenu 
                                     forModuletype:commentary 
                                    withMenuTarget:self 
                                    withMenuAction:@selector(addModule:)];
    
    // overall menu
    NSMenu *allMenu = [[NSMenu alloc] init];
    [allMenu addItemWithTitle:@"+" action:nil keyEquivalent:@""];
    NSMenuItem *mi = [allMenu addItemWithTitle:NSLocalizedString(@"Bible", @"") action:nil keyEquivalent:@""];
    [mi setSubmenu:biblesMenu];
    mi = [allMenu addItemWithTitle:NSLocalizedString(@"Commentary", @"") action:nil keyEquivalent:@""];
    [mi setSubmenu:commentariesMenu];
    
    // add menu
    [addPopBtn setMenu:allMenu];
}

- (void)moduleSelectionChanged:(id)sender {
    NSString *name = [(NSMenuItem *)sender title];
    if((self.module == nil) || (![name isEqualToString:[module name]])) {
        self.module = [[SwordManager defaultManager] moduleWithName:name];
        if((self.reference != nil) && ([self.reference length] > 0)) {
            forceRedisplay = YES;
            [self displayTextForReference:self.reference searchType:searchType];
        }
    }
    
    [entriesOutlineView reloadData];
}

- (void)setStatusText:(NSString *)aText {
    [statusLine setStringValue:aText];
}

- (NSString *)label {
    if(module != nil) {
        return [module name];
    }
    
    return @"BibleView";
}

#pragma mark - Menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    BOOL ret = YES;
    SEL selector = [menuItem action];
    
    if([menuItem menu] == textContextMenu) {
        NSAttributedString *textSelection = [[(<TextContentProviding>)contentDisplayController textView] selectedAttributedString];
        
        if(selector == @selector(addBookmark:)) {            
            if([textSelection length] == 0 || [[textSelection findBibleVerses] count] == 0) {
                ret = NO;
            }
        } else if(selector == @selector(addVersesToBookmark:)) {
            if([[menuItem submenu] numberOfItems] == 0 || [textSelection length] == 0 || [[textSelection findBibleVerses] count] == 0) {
                ret = NO;
            }
        }
        return ret;
    }
    
    return [super validateMenuItem:menuItem];
}

#pragma mark - TextDisplayable

- (BOOL)hasValidCacheObject {
    if((searchType == ReferenceSearchType && [[contentCache reference] isEqualToString:reference]) ||
       (searchType == IndexSearchType && [[searchContentCache reference] isEqualToString:reference])) {
        return YES;
    }
    return NO;
}

- (void)handleDisplayForReference {
    [self checkPerformProgressCalculation];
    [self updateContentCache];    
}

- (void)checkPerformProgressCalculation {
    if(performProgressCalculation) {
        // in order to show a progress indicator for if the searching takes too long
        // we need to find out how long it will approximately take
        MBLOG(MBLOG_DEBUG, @"[BibleViewController -checkPerformProgressCalculation::] numberOfVerseKeys...");
        int len = [(SwordBible *)module numberOfVerseKeysForReference:reference];
        // let's say that for more then 30 verses we show a progress indicator
        if(len >= 30) {
            [self beginIndicateProgress];
        }
        performProgressCalculation = YES;   // next time we do
        MBLOG(MBLOG_DEBUG, @"[BibleViewController -checkPerformProgressCalculation::] numberOfVerseKeys...done");
    }
}

- (void)updateContentCache {
    [contentCache setReference:reference];
    [contentCache setContent:[module renderedTextEntriesForRef:reference]];    
}

- (void)handleDisplayIndexedNoHasIndex {
    // let the user confirm to create the index now
    NSString *info = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"IndexBeingCreatedForModule", @""), [module name]];
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"IndexNotReady", @"")
                                     defaultButton:NSLocalizedString(@"OK", @"") 
                                   alternateButton:nil 
                                       otherButton:nil 
                         informativeTextWithFormat:info];
    [alert runModal];
    
    // show progress indicator
    // progress indicator is stopped in the delegate methods of either indexing or searching
    [self beginIndicateProgress];
    
    [module createIndexThreadedWithDelegate:self];    
}

- (void)handleDisplayIndexedPerformSearch {
    // show progress indicator
    // progress indicator is stopped in the delegate methods of either indexing or searching
    [self beginIndicateProgress];
    
    SearchBookSet *bookSet = [searchBookSetsController selectedBookSet];
    long maxResults = 10000;
    indexer = [[IndexingManager sharedManager] indexerForModuleName:[module name] moduleType:[module type]];
    if(indexer == nil) {
        MBLOG(MBLOG_ERR, @"[BibleViewController -performThreadedSearch::] Could not get indexer for searching!");
    } else {
        [indexer performThreadedSearchOperation:reference constrains:bookSet maxResults:maxResults delegate:self];
    }    
}

- (void)handleDisplayCached {
    NSAttributedString *displayText = nil;
    if(searchType == ReferenceSearchType) {
        displayText = [self displayableHTMLForReferenceLookup];
    } else {
        displayText = [self displayableHTMLForIndexedSearch];
    }
    
    if(displayText) {
        [self setAttributedString:displayText];
    }
}

- (void)handleDisplayStatusText {
    int length = 0;
    if(searchType == ReferenceSearchType) {
        length = [(NSArray *)[contentCache content] count];
    } else {
        length = [(NSArray *)[searchContentCache content] count];
    }
    
    [self setStatusText:[NSString stringWithFormat:@"Found %i verses", length]];        
}

#pragma mark - Actions

- (IBAction)textContextChange:(id)sender {
    [super textContextChange:sender];
    
    // get selected context
    int tag = [(NSPopUpButton *)sender selectedTag];
        
    self.textContext = tag;
    
    // force redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

- (IBAction)addModule:(id)sender {
    NSMenuItem *item = sender;
    
    SwordManager *sm = [SwordManager defaultManager];
    SwordModule *mod = [sm moduleWithName:[item title]];
    if(mod) {
        SEL selector = @selector(addNewCommentViewWithModule:);
        if([item menu] == biblesMenu) {
            selector = @selector(addNewBibleViewWithModule:);
        }

        if(delegate) {
            if([delegate respondsToSelector:selector]) {
                [delegate performSelector:selector withObject:mod];
            }
        }        
    }
}

- (IBAction)closeButton:(id)sender {
    // send close view to super view
    [self removeFromSuperview];
}

- (IBAction)addButton:(id)sender {
    // call delegate and tell to add a new bible view
    if(delegate) {
        if([delegate respondsToSelector:@selector(addNewBibleViewWithModule:)]) {
            [delegate performSelector:@selector(addNewBibleViewWithModule:) withObject:nil];
        }
    }
}

#pragma mark - Text Context Menu actions

- (IBAction)addBookmark:(id)sender {
    NSAttributedString *selection = [[(<TextContentProviding>)contentDisplayController textView] selectedAttributedString];
    NSArray *verses = [selection findBibleVerses];
    [[self bookmarksUIController] bookmarkDialogForVerseList:verses];
}

- (IBAction)addVersesToBookmark:(id)sender {
    NSAttributedString *selection = [[(<TextContentProviding>)contentDisplayController textView] selectedAttributedString];
    NSArray *verses = [selection findBibleVerses];
    Bookmark *bm = [(NSMenuItem *)sender representedObject];
    [bm setReference:[NSString stringWithFormat:@"%@;%@", [bm reference], [verses componentsJoinedByString:@";"]]];
    [[BookmarkManager defaultManager] saveBookmarks];
}

#pragma mark - SubviewHosting

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -contentViewInitFinished:]");
    
    // check if this view has completed loading
    if(viewLoaded == YES) {
        // set sync scroll view
        [(ScrollSynchronizableView *)[self view] setSyncScrollView:(NSScrollView *)[(<TextContentProviding>)contentDisplayController scrollView]];
        [(ScrollSynchronizableView *)[self view] setTextView:[(<TextContentProviding>)contentDisplayController textView]];
        
        // add the webview as contentvew to the placeholder    
        [placeHolderView setContentView:[aView view]];
        [self reportLoadingComplete];
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    // does nothing
}

#pragma mark - MouseTracking protocol

- (void)mouseEntered:(NSView *)theView {
    if(delegate && [delegate respondsToSelector:@selector(mouseEntered:)]) {
        [delegate performSelector:@selector(mouseEntered:) withObject:[self view]];
    }
}

- (void)mouseExited:(NSView *)theView {
    if(delegate && [delegate respondsToSelector:@selector(mouseExited:)]) {
        [delegate performSelector:@selector(mouseExited:) withObject:[self view]];
    }
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {        
        self.nibName = [decoder decodeObjectForKey:@"NibNameKey"];        
        self.textContext = [decoder decodeIntegerForKey:@"TextContextKey"];
        
        searchBookSetsController = [[SearchBookSetEditorController alloc] init];
        [searchBookSetsController setDelegate:self];

        // load nib
        BOOL stat = [NSBundle loadNibNamed:nibName owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BibleViewController -initWithCoder:] unable to load nib!");
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeInteger:textContext forKey:@"TextContextKey"];    
    [encoder encodeObject:nibName forKey:@"NibNameKey"];
}

@end
