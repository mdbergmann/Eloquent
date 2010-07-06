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
#import "ObjCSword/SwordManager.h"
#import "ObjCSword/SwordModule.h"
#import "ObjCSword/SwordBible.h"
#import "SearchResultEntry.h"
#import "Highlighter.h"
#import "GradientCell.h"
#import "SearchBookSetEditorController.h"
#import "SearchBookSet.h"
#import "Bookmark.h"
#import "BookmarkManager.h"
#import "ObjCSword/SwordVerseKey.h"
#import "IndexingManager.h"
#import "ModulesUIController.h"
#import "BookmarksUIController.h"
#import "ObjCSword/SwordModuleTextEntry.h"
#import "ObjCSword/SwordBibleTextEntry.h"
#import "NSUserDefaults+Additions.h"
#import "NSTextView+LookupAdditions.h"
#import "NSAttributedString+Additions.h"
#import "WorkspaceViewHostController.h"
#import "globals.h"
#import "ObjCSword/SwordBibleBook.h"
#import "ObjCSword/SwordBibleChapter.h"
#import "CommentaryViewController.h"

@interface BibleViewController ()

- (void)moduleSelectionChanged:(id)sender;

- (void)checkPerformProgressCalculation;
- (void)_loadNib;

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
        if(![self isKindOfClass:[CommentaryViewController class]]) {
            [self _loadNib];            
        }
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
        if(aModule == nil) {
            NSArray *modArray = [[SwordManager defaultManager] modulesForType:SWMOD_CATEGORY_BIBLES];
            if([modArray count] > 0) {
                aModule = [modArray objectAtIndex:0];
            }
        }
        self.module = (SwordModule *)aModule;
        self.delegate = aDelegate;
        
        [self _loadNib];
    } else {
        CocoLog(LEVEL_ERR, @"[BibleViewController -init] unable init!");
    }
    
    return self;
}

- (void)commonInit {
    [super commonInit];
    self.nibName = BIBLEVIEW_NIBNAME;
    self.searchType = ReferenceSearchType;
    self.bookSelection = [NSMutableArray array];
    self.textContext = 0;

    searchBookSetsController = [[SearchBookSetEditorController alloc] init];
    [searchBookSetsController setDelegate:self];
}

- (void)_loadNib {
    BOOL stat = [NSBundle loadNibNamed:nibName owner:self];
    if(!stat) {
        CocoLog(LEVEL_ERR, @"[BibleViewController -init] unable to load nib!");            
    }    
}

- (void)awakeFromNib {
    [super awakeFromNib];
        
    // prepare for our custom cell
    gradientCell = [[GradientCell alloc] init];
    NSTableColumn *tableColumn = [entriesOutlineView tableColumnWithIdentifier:@"common"];
    [tableColumn setDataCell:gradientCell];    
    
    // if we have a reference, display it
    if(searchString && [searchString length] > 0) {
        [self displayTextForReference:searchString searchType:ReferenceSearchType];    
    }

    // if our hosted subview also has loaded, report that
    // else, reporting is done in -contentViewInitFinished
    if([contentDisplayController viewLoaded]) {
        // set sync scroll view
        [(ScrollSynchronizableView *)[self view] setSyncScrollView:[(<TextContentProviding>)contentDisplayController scrollView]];
        [(ScrollSynchronizableView *)[self view] setTextView:[(<TextContentProviding>)contentDisplayController textView]];
        
        // add the webview as contentview to the placeholder    
        [placeHolderView setContentView:[contentDisplayController view]];
        [self reportLoadingComplete];
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
    [[self modulesUIController] generateModuleMenu:&menu 
                                     forModuletype:bible 
                                    withMenuTarget:self 
                                    withMenuAction:@selector(moduleSelectionChanged:)];
    [modulePopBtn setMenu:menu];
    
    if(self.module != nil) {
        // on change, still exists?
        if(![[SwordManager defaultManager] moduleWithName:[module name]]) {
            // select the first one found
            NSArray *modArray = [[SwordManager defaultManager] modulesForType:SWMOD_CATEGORY_BIBLES];
            if([modArray count] > 0) {
                [self setModule:[modArray objectAtIndex:0]];
                // and redisplay if needed
                [self displayTextForReference:searchString searchType:searchType];
            }
        }
        
        [modulePopBtn selectItemWithTitle:[module name]];
    }
}

- (void)populateBookmarksMenu {
    NSMenu *bookmarksMenu = [[NSMenu alloc] init];
    [[self bookmarksUIController] generateBookmarkMenu:&bookmarksMenu withMenuTarget:self withMenuAction:@selector(addVersesToBookmark:)];
    NSMenuItem *item = [textContextMenu itemWithTag:AddVersesToBookmark];
    [item setSubmenu:bookmarksMenu];    
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
        if((self.searchString != nil) && ([self.searchString length] > 0)) {
            forceRedisplay = YES;
            [self displayTextForReference:self.searchString searchType:searchType];
        }
    }
    
    [entriesOutlineView reloadData];
}

- (void)setStatusText:(NSString *)aText {
    [statusLine setStringValue:aText];
}

#pragma mark - HostViewDelegate

- (void)prepareContentForHost:(WindowHostController *)aHostController {
    [super prepareContentForHost:aHostController];
    [self populateAddPopupMenu];
    [self populateBookmarksMenu];
    
    if(searchString == nil || [searchString length] == 0) {
        [hostingDelegate setSearchText:@"Gen 1"];
    }
}

- (BOOL)enableAddBookmarks {
    return (searchType == ReferenceSearchType);
}

- (NSString *)title {
    if(module != nil) {
        return [NSString stringWithFormat:@"%@ - %@", [module name], searchString];
    }
    return @"BibleView";    
}

- (NSView *)rightAccessoryView {
    if(searchType == ReferenceSearchType) {
        return [entriesOutlineView enclosingScrollView];
    } else {
        return [searchBookSetsController view];
    }
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

- (void)handleDisplayForReference {
    if([searchString length] > 0) {
        [self checkPerformProgressCalculation];
    }
    [super handleDisplayForReference];
}

- (void)checkPerformProgressCalculation {
    if(performProgressCalculation) {
        // in order to show a progress indicator for if the searching takes too long
        // we need to find out how long it will approximately take
        CocoLog(LEVEL_DEBUG, @"[BibleViewController -checkPerformProgressCalculation::] numberOfVerseKeys...");
        int len = [(SwordBible *)module numberOfVerseKeysForReference:searchString];
        // let's say that for more then 30 verses we show a progress indicator
        if(len >= 30) {
            [self beginIndicateProgress];
        }
        performProgressCalculation = YES;   // next time we do
        CocoLog(LEVEL_DEBUG, @"[BibleViewController -checkPerformProgressCalculation::] numberOfVerseKeys...done");
    }
}

- (void)handleDisplayIndexedPerformSearch {
    if([searchString length] > 0) {
        // show progress indicator
        // progress indicator is stopped in the delegate methods of either indexing or searching
        [self beginIndicateProgress];
        
        SearchBookSet *bookSet = [searchBookSetsController selectedBookSet];
        long maxResults = 10000;
        indexer = [[IndexingManager sharedManager] indexerForModuleName:[module name] moduleType:[module type]];
        if(indexer == nil) {
            CocoLog(LEVEL_ERR, @"[BibleViewController -performThreadedSearch::] Could not get indexer for searching!");
        } else {
            [indexer performThreadedSearchOperation:searchString constrains:bookSet maxResults:maxResults delegate:self];
        }        
    }
}

#pragma mark - Actions

- (IBAction)textContextChange:(id)sender {
    [super textContextChange:sender];
    
    // get selected context
    int tag = [(NSPopUpButton *)sender selectedTag];
        
    self.textContext = tag;
    
    // force redisplay
    forceRedisplay = YES;
    [self displayTextForReference:searchString];
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
    if(viewLoaded) {
        // set sync scroll view
        [(ScrollSynchronizableView *)[self view] setSyncScrollView:(NSScrollView *)[(<TextContentProviding>)contentDisplayController scrollView]];
        [(ScrollSynchronizableView *)[self view] setTextView:[(<TextContentProviding>)contentDisplayController textView]];
        
        // add the webview as contentvew to the placeholder    
        [placeHolderView setContentView:[aView view]];
        [self reportLoadingComplete];
    }
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
        [self _loadNib];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeInteger:textContext forKey:@"TextContextKey"];    
    [encoder encodeObject:nibName forKey:@"NibNameKey"];
}

@end
