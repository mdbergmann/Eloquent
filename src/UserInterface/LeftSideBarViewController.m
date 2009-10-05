//
//  LeftSideBarViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LeftSideBarViewController.h"
#import "AppController.h"
#import "BibleCombiViewController.h"
#import "HostableViewController.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SwordModCategory.h"
#import "BookmarkManager.h"
#import "Bookmark.h"
#import "ThreeCellsCell.h"
#import "BookmarkDragItem.h"
#import "SearchTextObject.h"

// drag & drop types
#define DD_BOOKMARK_TYPE   @"ddbookmarktype"

enum BookmarkMenu_Items{
    BookmarkMenuAddNewBM = 1,
    BookmarkMenuAddNewBMFolder,
    BookmarkMenuEditBM,
    BookmarkMenuRemoveBM,
    BookmarkMenuOpenBMInNew,
    BookmarkMenuOpenBMInCurrent,
}BookMarkMenuItems;

enum ModuleMenu_Items{
    ModuleMenuOpenSingle = 100,
    ModuleMenuOpenWorkspace,
    ModuleMenuOpenCurrent,
    ModuleMenuShowAbout = 120,
    ModuleMenuUnlock
}ModuleMenuItems;

@interface LeftSideBarViewController ()

- (void)doubleClick;
- (BOOL)deleteBookmarkForPath:(NSIndexPath *)path;
- (NSIndexPath *)indexPathForBookmark:(Bookmark *)bm;
- (int)getIndexPath:(NSMutableArray *)reverseIndex forBookmark:(Bookmark *)bm inList:(NSArray *)list;
- (void)modulesListChanged:(NSNotification *)notification;
- (id)objectForClickedRow;
- (BOOL)isDropSectionBookmarksForItem:(id)anItem;

@end

@implementation LeftSideBarViewController

@synthesize swordManager;
@synthesize bookmarkManager;

- (id)initWithDelegate:(id)aDelegate {
    self = [super initWithDelegate:aDelegate];
    if(self) {
        
        // default view is modules
        // init selection
        bookmarkSelection = [[NSMutableArray alloc] init];    
        
        // swordManager
        swordManager = [SwordManager defaultManager];
        // bookmarkManager
        bookmarkManager = [BookmarkManager defaultManager];
        
        // prepare images
        bookmarkGroupImage = [[NSImage imageNamed:@"groupbookmark.tiff"] retain];
        bookmarkImage = [[NSImage imageNamed:@"smallbookmark.tiff"] retain];
        lockedImage = [[NSImage imageNamed:NSImageNameLockLockedTemplate] retain];
        unlockedImage = [[NSImage imageNamed:NSImageNameLockUnlockedTemplate] retain];
        
        // register for modules changed notification
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(modulesListChanged:)
                                                     name:NotificationModulesChanged object:nil];            
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:LEFTSIDEBARVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[LeftSideBarViewController -init] unable to load nib!");
        }            
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[LeftSideBarViewController -awakeFromNib]");
    
    // set double click action
    [outlineView setTarget:self];
    [outlineView setDoubleAction:@selector(doubleClick)];
    
    // prepare for our custom cell
    threeCellsCell = [[ThreeCellsCell alloc] init];
    [threeCellsCell setWraps:NO];
    [threeCellsCell setTruncatesLastVisibleLine:YES];
    [threeCellsCell setLineBreakMode:NSLineBreakByTruncatingTail];
    NSTableColumn *tableColumn = [outlineView tableColumnWithIdentifier:@"common"];
    [tableColumn setDataCell:threeCellsCell];    
    
    // this text field should send continiuously
    [moduleUnlockTextField setContinuous:YES];
    
    // set drag & drop types
    [outlineView registerForDraggedTypes:[NSArray arrayWithObject:DD_BOOKMARK_TYPE]];
    
    // expand the first two items
    // second first, otherwise second is not second anymore
    [outlineView expandItem:[outlineView itemAtRow:1]];
    [outlineView expandItem:[outlineView itemAtRow:0]];
    
    [super awakeFromNib];
}

- (id)objectForClickedRow {
    id ret = nil;
    
    int clickedRow = [outlineView clickedRow];
    if(clickedRow >= 0) {
        // get row
        ret = [outlineView itemAtRow:clickedRow];
    }
    
    return ret;
}

/**
 update module list
 */
- (void)modulesListChanged:(NSNotification *)notification {
    [outlineView reloadData];
    [outlineView expandItem:[outlineView itemAtRow:1]];
    [outlineView expandItem:[outlineView itemAtRow:0]];
}

- (BOOL)deleteBookmarkForPath:(NSIndexPath *)path {
    NSMutableArray *list = [bookmarkManager bookmarks];
    for(int i = 0;i < [path length] - 1;i++) {
        Bookmark *b = [list objectAtIndex:[path indexAtPosition:i]];
        list = [b subGroups];
    }
    
    if(list) {
        [list removeObjectAtIndex:[path indexAtPosition:[path length] - 1]];
        return YES;
    }
    
    return NO;
}

- (NSIndexPath *)indexPathForBookmark:(Bookmark *)bm {
    NSIndexPath *ret = [[NSIndexPath alloc] init];
    
    NSMutableArray *reverseIndex = [NSMutableArray array];
    [self getIndexPath:reverseIndex forBookmark:bm inList:[bookmarkManager bookmarks]];
    int len = [reverseIndex count];
    NSUInteger indexes[len];
    for(int i = 0;i < len;i++) {
        indexes[len-1 - i] = (NSUInteger)[[reverseIndex objectAtIndex:i] intValue];
    }
    ret = [[NSIndexPath alloc] initWithIndexes:indexes length:len];
    
    return ret;
}

- (int)getIndexPath:(NSMutableArray *)reverseIndex forBookmark:(Bookmark *)bm inList:(NSArray *)list {
    
    if(list && [list count] > 0) {
        for(int i = 0;i < [list count];i++) {
            Bookmark *b = [list objectAtIndex:i];
            if(bm != b) {
                int index = [self getIndexPath:reverseIndex forBookmark:bm inList:[b subGroups]];
                if(index > -1) {
                    // record
                    [reverseIndex addObject:[NSNumber numberWithInt:i]];
                    return i;
                }
            } else {
                // record
                [reverseIndex addObject:[NSNumber numberWithInt:i]];
                return i;
            }
        }        
    }
    
    return -1;
}

- (void)bookmarkDialog:(id)sender {
    
    // create new bookmark instance
    Bookmark *new = [[Bookmark alloc] init];
    NSString *refText = [(SearchTextObject *)[(WindowHostController *)hostingDelegate currentSearchText] searchTextForType:ReferenceSearchType];
    [new setReference:refText];
    [new setName:refText];

    // set as content
    [bmObjectController setContent:new];

    // bring up bookmark panel
    bookmarkAction = BookmarkMenuAddNewBM;
    NSWindow *window = [(NSWindowController *)hostingDelegate window];
    [NSApp beginSheet:bookmarkPanel
       modalForWindow:window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
          contextInfo:nil];
}

- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod {
    // get about text as NSAttributedString
    NSAttributedString *aboutText = [aMod fullAboutText];
    [[moduleAboutTextView textStorage] setAttributedString:aboutText];
    // open window
    [NSApp beginSheet:moduleAboutWindow 
       modalForWindow:[hostingDelegate window] 
        modalDelegate:self
       didEndSelector:nil 
          contextInfo:nil];    
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOGV(MBLOG_DEBUG, @"[LeftSideBarViewController -contentViewInitFinished:] %@", [aView className]);
    
    // check if this view has completed loading annd also all of the subviews    
    if(viewLoaded == YES) {
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [super removeSubview:aViewController];
}

#pragma mark - menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	MBLOGV(MBLOG_DEBUG, @"[LeftSideBarViewController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = YES;
    
    // get module
    id clicked = [outlineView itemAtRow:[outlineView clickedRow]];

    // get menuitem tag
    int tag = [menuItem tag];
    
    // ------------ modules ---------------
    if(tag == ModuleMenuOpenCurrent) {
        if([clicked isKindOfClass:[SwordModule class]]) {
            SwordModule *mod = clicked;
            
            if([[hostingDelegate contentViewController] isKindOfClass:[BibleCombiViewController class]]) {
                // only commentary and bible views are able to show within bible the current
                if(([hostingDelegate moduleType] == mod.type) ||
                   ([hostingDelegate moduleType] == bible && mod.type == commentary)) {
                    ret = YES;
                } else {
                    ret = NO;
                }                
            } else {
                ret = NO;
            }
        }
    } else if(tag == ModuleMenuOpenWorkspace) {
        // we only open in workspace if the histingDelegate is a workspace
        if(![hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            ret = NO;
        }
    } else if(tag == ModuleMenuShowAbout) {
        if(![clicked isKindOfClass:[SwordModule class]]) {
            ret = NO;
        }
    } else if(tag == ModuleMenuUnlock) {
        if([clicked isKindOfClass:[SwordModule class]]) {
            SwordModule *mod = clicked;
            if(![mod isEncrypted]) {
                ret = NO;
            }
        }
    }
    // ----------------------- bookmarks -----------------------
    else if(tag == BookmarkMenuAddNewBM) {
        ret = YES;
    } else if(tag == BookmarkMenuAddNewBMFolder) {
        ret = YES;
    } else if(tag == BookmarkMenuRemoveBM) {
        if([bookmarkSelection count] == 0 || [bookmarkSelection count] == 1) {
            // get current selected module of clicked row
            id clicked = [self objectForClickedRow];
            if(clicked && [clicked isKindOfClass:[Bookmark class]]) {
                // replace any old selected with the clicked one
                [bookmarkSelection removeAllObjects];
                [bookmarkSelection addObject:clicked];
            }
        }
        if([bookmarkSelection count] > 0) {
            ret = YES;
        }
    } else if(tag == BookmarkMenuEditBM) {
        if([bookmarkSelection count] == 0 || [bookmarkSelection count] == 1) {
            // get current selected module of clicked row
            id clicked = [self objectForClickedRow];
            if(clicked && [clicked isKindOfClass:[Bookmark class]]) {
                // replace any old selected with the clicked one
                [bookmarkSelection removeAllObjects];
                [bookmarkSelection addObject:clicked];
            }
        }
        if([bookmarkSelection count] > 0) {
            ret = YES;
        }
    } else if(tag == BookmarkMenuOpenBMInNew) {
        ;
    } else if(tag == BookmarkMenuOpenBMInCurrent) {
        // we can only open in current, if it is a commentary or bible view
        if([hostingDelegate isKindOfClass:[SingleViewHostController class]] && 
           ([(SingleViewHostController *)hostingDelegate moduleType] == bible || [(SingleViewHostController *)hostingDelegate moduleType] == commentary)) {
            ret = YES;
        }
    }
    
    
    return ret;
}

#pragma mark - Actions

- (IBAction)moduleMenuClicked:(id)sender {
	MBLOGV(MBLOG_DEBUG, @"[LeftSideBarViewController -moduleMenuClicked:] %@", [sender description]);
    
    int tag = [sender tag];
    
    // get module
    SwordModule *mod = nil;
    id clicked = [outlineView itemAtRow:[outlineView clickedRow]];
    if([clicked isKindOfClass:[SwordModule class]]) {
        mod = clicked;
    }
    
    switch(tag) {
        case ModuleMenuOpenSingle:
            [[AppController defaultAppController] openSingleHostWindowForModule:mod];
            break;
        case ModuleMenuOpenWorkspace:
            [self doubleClick];
            break;
        case ModuleMenuOpenCurrent:
        {
            if(mod != nil) {
                if(mod.type == bible) {
                    [(BibleCombiViewController *)[hostingDelegate contentViewController] addNewBibleViewWithModule:(SwordBible *)mod];
                } else if(mod.type == commentary) {
                    [(BibleCombiViewController *)[hostingDelegate contentViewController] addNewCommentViewWithModule:(SwordCommentary *)mod];                    
                }
            }
            break;
        }
        case ModuleMenuShowAbout:
        {
            if(mod != nil) {
                clickedMod = mod;
                [self displayModuleAboutSheetForModule:mod];
            }
            break;
        }
        case ModuleMenuUnlock:
        {
            if(mod != nil) {
                clickedMod = mod;
                // open window
                [NSApp beginSheet:moduleUnlockWindow 
                   modalForWindow:[hostingDelegate window] 
                    modalDelegate:self 
                   didEndSelector:nil 
                      contextInfo:nil];                
            }
            break;
        }
    }
}

- (IBAction)moduleAboutClose:(id)sender {
    [moduleAboutWindow close];
    [NSApp endSheet:moduleAboutWindow];
    // clear textview
    [moduleAboutTextView setString:@""];
}

- (IBAction)moduleUnlockOk:(id)sender {
    
    NSString *unlockCode = [moduleUnlockTextField stringValue];
    if([unlockCode length] > 0) {
        // do something to unlock
        SwordModule *mod = clickedMod;        
        if(mod) {
            [mod unlock:unlockCode];
        }

        [moduleUnlockWindow close];
        [NSApp endSheet:moduleUnlockWindow];
        
        // clear textfield
        [moduleUnlockTextField setStringValue:@""];
        
        // reload item
        [outlineView reloadData];
    }
}

- (IBAction)moduleUnlockCancel:(id)sender {
    [moduleUnlockWindow close];
    [NSApp endSheet:moduleUnlockWindow];
    // clear textfield
    [moduleUnlockTextField setStringValue:@""];    
}

- (IBAction)bookmarkMenuClicked:(id)sender {
	MBLOGV(MBLOG_DEBUG, @"[LeftSideBarViewController -menuClicked:] %@", [sender description]);
    
    int tag = [sender tag];
    bookmarkAction = tag;
    
    switch(tag) {
        case BookmarkMenuAddNewBM:
        {
            Bookmark *new = [[Bookmark alloc] init];
            // set as content
            [bmObjectController setContent:new];
            // bring up bookmark panel
            [bookmarkPanel makeFirstResponder:bookmarkNameTextField];
            NSWindow *window = [(NSWindowController *)hostingDelegate window];
            [NSApp beginSheet:bookmarkPanel
               modalForWindow:window
                modalDelegate:self
               didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
                  contextInfo:nil];
            break;
        }
        case BookmarkMenuAddNewBMFolder:
        {
            // bring up bookmark panel
            [bookmarkFolderWindow makeFirstResponder:bookmarkFolderNameTextField];
            NSWindow *window = [(NSWindowController *)hostingDelegate window];
            [NSApp beginSheet:bookmarkFolderWindow
               modalForWindow:window
                modalDelegate:self
               didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
                  contextInfo:nil];
            break;
        }
        case BookmarkMenuEditBM:
        {
            Bookmark *clickedObj = [outlineView itemAtRow:[outlineView clickedRow]];
            // set as content
            [bmObjectController setContent:clickedObj];
            // bring up bookmark panel
            [bookmarkPanel makeFirstResponder:bookmarkNameTextField];
            NSWindow *window = [(NSWindowController *)hostingDelegate window];
            [NSApp beginSheet:bookmarkPanel 
               modalForWindow:window 
                modalDelegate:self 
               didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
                  contextInfo:nil];
            break;
        }
        case BookmarkMenuRemoveBM:
        {
            // confirm by user
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ConfirmBookmarkDelete", @"")
                                             defaultButton:NSLocalizedString(@"Yes", @"") 
                                           alternateButton:NSLocalizedString(@"No", @"") otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"ConfirmBookmarkDeleteText", @"")];
            if([alert runModal] == NSAlertDefaultReturn) {
                
                if([bookmarkSelection count] == 0 || [bookmarkSelection count] == 1) {
                    // get current selected module of clicked row
                    id clicked = [self objectForClickedRow];
                    if(clicked && [clicked isKindOfClass:[Bookmark class]]) {
                        // replace any old selected with the clicked one
                        [bookmarkSelection removeAllObjects];
                        [bookmarkSelection addObject:clicked];
                    }
                }
                for(Bookmark *b in bookmarkSelection) {
                    NSIndexPath *ip = [self indexPathForBookmark:b];
                    if([ip length] == 1) {
                        // we have to remove from root
                        int index = [ip indexAtPosition:0];
                        [[bookmarkManager bookmarks] removeObjectAtIndex:index];
                    } else if([ip length] > 1) {
                        Bookmark *bm = [[bookmarkManager bookmarks] objectAtIndex:[ip indexAtPosition:0]];
                        for(int i = 1;i < [ip length]-1;i++) {
                            bm = [[bm subGroups] objectAtIndex:[ip indexAtPosition:i]];
                        }
                        // if we have a bookmark, remove it
                        if(bm) {
                            [[bm subGroups] removeObjectAtIndex:[ip indexAtPosition:[ip length]-1]];
                        }
                    }
                    
                }
                [bookmarkManager saveBookmarks];
                // trigger reloading
                [outlineView reloadData];
            }
            break;
        }
        case BookmarkMenuOpenBMInNew:
        {
            Bookmark *clickedObj = [outlineView itemAtRow:[outlineView clickedRow]];
            // open new window
            SingleViewHostController *newC = [[AppController defaultAppController] openSingleHostWindowForModule:nil];
            [newC setSearchText:[clickedObj reference]];
        }
            break;
        case BookmarkMenuOpenBMInCurrent:
            [self doubleClick];
            break;
    }    
}

- (IBAction)bmWindowCancel:(id)sender {
    [NSApp endSheet:bookmarkPanel];
}

- (IBAction)bmWindowOk:(id)sender {
    [NSApp endSheet:bookmarkPanel];
    
    // get bookmark
    Bookmark *bm = [bmObjectController content];    
    if([[bm name] length] > 0) {
        if(bookmarkAction == BookmarkMenuAddNewBM) {
            
            if([bookmarkSelection count] == 0 || [bookmarkSelection count] == 1) {
                // get current selected module of clicked row
                id clicked = [self objectForClickedRow];
                if(clicked && [clicked isKindOfClass:[Bookmark class]]) {
                    // replace any old selected with the clicked one
                    [bookmarkSelection removeAllObjects];
                    [bookmarkSelection addObject:clicked];
                }
            }
            
            if([bookmarkSelection count] > 0) {
                Bookmark *selected = [bookmarkSelection objectAtIndex:0];
                if(selected == nil) {
                    // we add to root
                    [[bookmarkManager bookmarks] addObject:bm];
                } else {
                    if(![selected isLeaf]) {
                        // add to selected
                        [[selected subGroups] addObject:bm];            
                    } else {
                        // we add to root
                        [[bookmarkManager bookmarks] addObject:bm];            
                    }
                }
            } else {
                // we add to root
                [[bookmarkManager bookmarks] addObject:bm];
            }
        }
        
        // save
        [bookmarkManager saveBookmarks];
        [outlineView reloadData];
    }
    
    // reload outline view
    [outlineView reloadData];
}

- (IBAction)bmFolderWindowCancel:(id)sender {
    [NSApp endSheet:bookmarkFolderWindow];
}

- (IBAction)bmFolderWindowOk:(id)sender {
    [NSApp endSheet:bookmarkFolderWindow];
    
    // create new bookmark folder
    Bookmark *bm = [[Bookmark alloc] initWithName:[bookmarkFolderNameTextField stringValue]];
    [bm setSubGroups:[NSMutableArray array]];   // this will get a folder

    if([bookmarkSelection count] == 0 || [bookmarkSelection count] == 1) {
        // get current selected module of clicked row
        id clicked = [self objectForClickedRow];
        if(clicked && [clicked isKindOfClass:[Bookmark class]]) {
            // replace any old selected with the clicked one
            [bookmarkSelection removeAllObjects];
            [bookmarkSelection addObject:clicked];
        }
    }

    if([bookmarkSelection count] > 0) {
        // OutlineListObject will be generated on the fly, so we don't need to update them
        Bookmark *selected = [bookmarkSelection objectAtIndex:0];
        if(selected == nil) {
            // we add to root
            [[bookmarkManager bookmarks] addObject:bm];
        } else {
            if(![selected isLeaf]) {
                // add to selected
                [[selected subGroups] addObject:bm];            
            } else {
                // we add to root
                [[bookmarkManager bookmarks] addObject:bm];            
            }
        }
    } else {
        // we add to root
        [[bookmarkManager bookmarks] addObject:bm];
    }
    
    // save
    [bookmarkManager saveBookmarks];
    // reload outline view
    [outlineView reloadData];    
}

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	// hide sheet
	[sSheet orderOut:nil];
}

#pragma mark - NSControl delegate methods

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if([aNotification object] == moduleUnlockTextField) {
        if([[moduleUnlockTextField stringValue] length] == 0) {
            [moduleUnlockOKButton setEnabled:NO];
        } else {
            [moduleUnlockOKButton setEnabled:YES];        
        }        
    } else if([aNotification object] == bookmarkFolderNameTextField) {
        if([[bookmarkFolderNameTextField stringValue] length] == 0) {
            [bookmarkFolderOkButton setEnabled:NO];
        } else {
            [bookmarkFolderOkButton setEnabled:YES];        
        }
    }
}

#pragma mark - outline datasource methods

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    id ret = nil;
    
    if(item == nil) {
        // we have two root items (modules, bookmarks)
        if(index == 0) {
            ret = NSLocalizedString(@"LSBModules", @"");
        } else if(index == 1) {
            ret = NSLocalizedString(@"LSBBookmarks", @"");        
        }
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBModules", @"")]) {
        // modules root
        
        // get categories
        ret = [[SwordModCategory moduleCategories] objectAtIndex:index];
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBBookmarks", @"")]) {
        // bookmarks root
        
        // get bookmarks
        ret = [[[BookmarkManager defaultManager] bookmarks] objectAtIndex:index];
    } else if([item isKindOfClass:[SwordModCategory class]]) {
        // module category
        
        // get number of modules in category
        ret = [[[SwordManager defaultManager] modulesForType:[(SwordModCategory *)item name]] objectAtIndex:index];
    } else if([item isKindOfClass:[Bookmark class]] && ![(Bookmark *)item isLeaf]) {
        // bookmark folder
        
        ret = [[(Bookmark *)item subGroups] objectAtIndex:index];
    }
    
    return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    BOOL ret = NO;
    
    if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBModules", @"")]) {
        // modules root
        ret = YES;
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBBookmarks", @"")]) {
        // bookmarks root
        ret = YES;
    } else if([item isKindOfClass:[SwordModCategory class]]) {
        // module category
        ret = ([[[SwordManager defaultManager] modulesForType:[(SwordModCategory *)item name]] count] > 0);
    } else if([item isKindOfClass:[Bookmark class]] && ![(Bookmark *)item isLeaf]) {
        // bookmark folder
        ret = ([[(Bookmark *)item subGroups] count] > 0);
    }

    return ret;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    NSInteger ret = 0;
    
    if(item == nil) {
        // we have two root items (modules, bookmarks)
        ret = 2;
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBModules", @"")]) {
        // modules root
        
        // get categories
        ret = [[SwordModCategory moduleCategories] count];
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBBookmarks", @"")]) {
        // bookmarks root
        
        // get bookmarks
        ret = [[[BookmarkManager defaultManager] bookmarks] count];
    } else if([item isKindOfClass:[SwordModCategory class]]) {
        // module category
        
        // get number of modules in category
        ret = [[[SwordManager defaultManager] modulesForType:[(SwordModCategory *)item name]] count];
    } else if([item isKindOfClass:[Bookmark class]] && ![(Bookmark *)item isLeaf]) {
        // bookmark folder
        
        ret = [[(Bookmark *)item subGroups] count];
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    NSString *ret = nil;
    
    if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBModules", @"")]) {
        // modules root
        ret = item;
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBBookmarks", @"")]) {
        // bookmarks root
        ret = item;
    } else if([item isKindOfClass:[SwordModCategory class]]) {
        // module category
        ret = [(SwordModCategory *)item description];
    } else if([item isKindOfClass:[SwordModule class]]) {
        // module
        ret = [(SwordModule *)item name];
    } else if([item isKindOfClass:[Bookmark class]]) {
        // bookmark
        ret = [(Bookmark *)item name];
    }    
    
    return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
    // make sure this is no module that we are dragging here
    NSMutableArray *dragItems = [NSMutableArray arrayWithCapacity:[items count]];
    for(int i = 0;i < [items count];i++) {
        id item = [items objectAtIndex:i];
        if([item isKindOfClass:[Bookmark class]]) {
            // go ahead
            // get the bookmarks instances and encode them
            BookmarkDragItem *di = [[BookmarkDragItem alloc] init];
            di.bookmark = item;
            NSIndexPath *path = [self indexPathForBookmark:di.bookmark];
            di.path = path;
            [dragItems addObject:di];            
        }
    }
    
    if([dragItems count] > 0) {
        // write them to paste board
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dragItems];
        [pboard declareTypes:[NSArray arrayWithObject:DD_BOOKMARK_TYPE] owner:self];
        [pboard setData:data forType:DD_BOOKMARK_TYPE];
        return YES;        
    }
    
    return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    // make sure we drop only with in bookmarks
    if([self isDropSectionBookmarksForItem:item]) {        
        int mask = [info draggingSourceOperationMask];
        if(mask == NSDragOperationAll_Obsolete) {
            mask = NSDragOperationEvery;
        }
        int op = NSDragOperationNone;
        if(mask == NSDragOperationCopy) {
            op = NSDragOperationCopy;
        } else if(mask & NSDragOperationMove) {
            op = NSDragOperationMove;
        }
        
        return op;
    } else {
        return NSDragOperationNone;
    }
}

- (BOOL)isDropSectionBookmarksForItem:(id)anItem {
    return ([anItem isKindOfClass:[Bookmark class]] || ([anItem isKindOfClass:[NSString class]] && [(NSString *)anItem isEqualToString:NSLocalizedString(@"LSBBookmarks", @"")]));
}

- (BOOL)outlineView:(NSOutlineView *)anOutlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index {
    
    // get our data from the paste board
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData *data = [pboard dataForType:DD_BOOKMARK_TYPE];
    NSArray *draggedBookmarks = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    Bookmark *bitem = item;
    // is first level object?
    NSMutableArray *dropPoint = nil;
    if([bitem isKindOfClass:[NSString class]] && [(NSString *)bitem isEqualToString:NSLocalizedString(@"LSBBookmarks", @"")]) {
        dropPoint = [bookmarkManager bookmarks];
    } else {
        dropPoint = [bitem subGroups];
    }
    
    if(index == -1) {
        index = 0;
    }

    int dropPointLen = [dropPoint count];
    for(BookmarkDragItem *bd in draggedBookmarks) {
        // was it a move operation?
        // delete first, otherwise the path may not be correct anymore
        NSDragOperation draggingOperation = [info draggingSourceOperationMask];
        if(draggingOperation != NSDragOperationCopy) {
            [self deleteBookmarkForPath:[bd path]];
            
            // in case the dropPoint is the same level where we removed the bookmark
            // it might be that we have to decrement the index otherwise we might get an out of bounds exception when adding
            if(([dropPoint count] < dropPointLen) && (index > 0) && ([[bd path] indexAtPosition:[[bd path] length]-1] < index)) {
                index--;
            } 
        }
        
        [dropPoint insertObject:[bd bookmark] atIndex:index];
    }

    [bookmarkManager saveBookmarks];
    [outlineView reloadData];
    
    return YES;
}

#pragma mark - outline delegate methods

- (void)doubleClick {
    // get clicked row
    int clickedRow = [outlineView clickedRow];
    id clickedObj = [outlineView itemAtRow:clickedRow];
    
    if([clickedObj isKindOfClass:[SwordModule class]]) {
        SwordModule *mod  = clickedObj;
        // depending on the hosting window we open a new tab or window
        if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [(WorkspaceViewHostController *)hostingDelegate addTabContentForModule:mod];        
        } else if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            // default action on this is open another single view host with this module
            [[AppController defaultAppController] openSingleHostWindowForModule:mod];        
        }
    } else if([clickedObj isKindOfClass:[Bookmark class]]) {
        Bookmark *b = clickedObj;
        // check for type of host
        if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            [(SingleViewHostController *)hostingDelegate setSearchText:[b reference]];
        } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [(WorkspaceViewHostController *)hostingDelegate setSearchText:[b reference]];
        }
    }    
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	MBLOG(MBLOG_DEBUG,@"[LeftSideBarViewController outlineViewSelectionDidChange:]");
	
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {
            
			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			int len = [selectedRows count];
            
            if(len == 1) {
                id item = [oview itemAtRow:[oview selectedRow]];
                if([item isKindOfClass:[Bookmark class]] || 
                   ([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBBookmarks", @"")])) {
                    [oview setMenu:bookmarkMenu];
                } else if([item isKindOfClass:[SwordModule class]]) {
                    [oview setMenu:moduleMenu];
                } else {
                    [oview setMenu:nil];
                }
            } else {
                [oview setMenu:nil];            
            }
            
		} else {
			MBLOG(MBLOG_WARN,@"[LeftSideBarViewController outlineViewSelectionDidChange:] have a nil notification object!");
		}
	} else {
		MBLOG(MBLOG_WARN,@"[LeftSideBarViewController outlineViewSelectionDidChange:] have a nil notification!");
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    /*
    if(item != nil) {
        OutlineListObject *o = [item representedObject];
        int t = [o objectType];
        if(t == OutlineItemModuleRoot || t == OutlineItemBookmarkRoot) {
            return YES;
        }
    }
     */
    
    return NO;
}

- (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {

    [(ThreeCellsCell *)cell setImage:nil];
    [(ThreeCellsCell *)cell setRightImage:nil];
    [(ThreeCellsCell *)cell setRightCounter:0];
    [(ThreeCellsCell *)cell setLeftCounter:0];

    if(item != nil) {        
        if([item isKindOfClass:[NSString class]]) {
            NSFont *font = FontLargeBold;
            //float pointSize = [font pointSize];
            //[aOutlineView setRowHeight:pointSize + 6];
            
            [cell setFont:font];
            [cell setTextColor:[NSColor grayColor]];
            //float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
        } else {
            NSFont *font = FontStd;
            //float pointSize = [font pointSize];
            //[aOutlineView setRowHeight:pointSize + 6];
            
            [cell setFont:font];
            [cell setTextColor:[NSColor blackColor]];
            
            if([item isKindOfClass:[Bookmark class]] && [(Bookmark *)item isLeaf]) {
                [(ThreeCellsCell *)cell setImage:bookmarkImage];
            } else if([item isKindOfClass:[Bookmark class]] && ![(Bookmark *)item isLeaf]) {
                [(ThreeCellsCell *)cell setLeftCounter:[(Bookmark *)item childCount]];
                [(ThreeCellsCell *)cell setImage:bookmarkGroupImage];
            } else if([item isKindOfClass:[SwordModCategory class]]) {
                //[(ThreeCellsCell *)cell setRightCounter:[[[SwordManager defaultManager] modulesForType:[(SwordModCategory *)item name]] count]];                
            } else if([item isKindOfClass:[SwordModule class]]) {
                [(ThreeCellsCell *)cell setImage:nil];
                SwordModule *mod = item;
                NSImage *img = nil;
                if([mod isEncrypted]) {
                    if([mod isLocked]) {
                        img = lockedImage;
                    } else {
                        img = unlockedImage;                    
                    }
                }
                [(ThreeCellsCell *)cell setRightImage:img];                
            }
        }
    }
}

- (NSString *)outlineView:(NSOutlineView *)ov toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc item:(id)item mouseLocation:(NSPoint)mouseLocation {
    if(item != nil) {
        if([item isKindOfClass:[Bookmark class]]) {
            Bookmark *b = item;
            return [b reference];
        }
    }
    
    return @"";
}

@end
