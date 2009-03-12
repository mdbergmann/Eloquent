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
#import "OutlineListObject.h"
#import "ThreeCellsCell.h"
#import "BookmarkDragItem.h"
#import "SearchTextObject.h"

// drag & drop types
#define DD_BOOKMARK_TYPE   @"ddbookmarktype"

enum BookmarkMenu_Items{
    BookmarkMenuAddNewBM = 1,
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
- (void)prepareTreeContent;
- (BOOL)deleteBookmarkForPath:(NSIndexPath *)path;
- (NSIndexPath *)indexPathForBookmark:(Bookmark *)bm;
- (int)getIndexPath:(NSMutableArray *)reverseIndex forBookmark:(Bookmark *)bm inList:(NSArray *)list;
- (void)modulesListChanged:(NSNotification *)notification;

@end

@implementation LeftSideBarViewController

@synthesize swordManager;
@synthesize bookmarkManager;
@synthesize treeContent;

- (id)initWithDelegate:(id)aDelegate {
    self = [super initWithDelegate:aDelegate];
    if(self) {
        
        // default view is modules
        // init selection
        bookmarkSelection = [[NSMutableArray alloc] init];    
        
        self.treeContent = [NSMutableArray array];
        [self prepareTreeContent];
        
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
    NSTableColumn *tableColumn = [outlineView tableColumnWithIdentifier:@"common"];
    [tableColumn setDataCell:threeCellsCell];    
    
    // this text field shuld send continiuously
    [moduleUnlockTextField setContinuous:YES];
    
    // set drag & drop types
    [outlineView registerForDraggedTypes:[NSArray arrayWithObject:DD_BOOKMARK_TYPE]];
    
    // expand the first two items
    // second first, otherwise second is not second anymore
    [outlineView expandItem:[outlineView itemAtRow:1]];
    [outlineView expandItem:[outlineView itemAtRow:0]];
    
    [super awakeFromNib];
}

/**
 update module list
 */
- (void)modulesListChanged:(NSNotification *)notification {
    [treeContent removeAllObjects];
    // prepare again
    [self prepareTreeContent];
    // reload
    [treeController rearrangeObjects];
    //[outlineView reloadData];
    [outlineView expandItem:[outlineView itemAtRow:1]];
    [outlineView expandItem:[outlineView itemAtRow:0]];
}

/**
 Here we prepare the content array to be displayed by the tree controller
 */
- (void)prepareTreeContent {
    // first build up the modules section
    OutlineListObject *o = [[OutlineListObject alloc] initWithObject:nil];
    [o setType:OutlineItemModuleRoot];
    [treeContent addObject:o];
    
    // build up Bookmarks section
    o = [[OutlineListObject alloc] initWithObject:nil];
    [o setType:OutlineItemBookmarkRoot];
    [treeContent addObject:o];
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
    
    return -1;
}

- (void)bookmarkDialog:(id)sender {
    
    // create new bookmark instance
    Bookmark *new = [[Bookmark alloc] init];
    [new setReference:[(SearchTextObject *)[(WindowHostController *)hostingDelegate currentSearchText] searchTextForType:ReferenceSearchType]];

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
    
    BOOL ret = YES; // by default validate this item
    
    // get module
    OutlineListObject *clicked = [[outlineView itemAtRow:[outlineView clickedRow]] representedObject];

    // get menuitem tag
    int tag = [menuItem tag];
    
    // ------------ modules ---------------
    if(tag == ModuleMenuOpenCurrent) {
        if([clicked objectType] == OutlineItemModule) {
            SwordModule *mod = [clicked listObject];
            
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
        if([clicked objectType] != OutlineItemModule) {
            ret = NO;
        }
    } else if(tag == ModuleMenuUnlock) {
        SwordModule *mod = [clicked listObject];
        if([clicked objectType] != OutlineItemModule || ![mod isEncrypted]) {            
            ret = NO;
        }        
    }
    // ----------------------- bookmarks -----------------------
    else if(tag == BookmarkMenuAddNewBM) {
        ret = YES;
    } else if(tag == BookmarkMenuRemoveBM) {
        if([[treeController selectedObjects] count] > 0) {
            ret = YES;
        }
    } else if(tag == BookmarkMenuEditBM) {
        if([[treeController selectedObjects] count] > 0) {
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
    OutlineListObject *clicked = [[outlineView itemAtRow:[outlineView clickedRow]] representedObject];
    if([clicked objectType] == OutlineItemModule) {
        mod = [clicked listObject];
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
                // get about text as NSAttributedString
                NSAttributedString *aboutText = [mod fullAboutText];
                [[moduleAboutTextView textStorage] setAttributedString:aboutText];
                // open window
                [NSApp beginSheet:moduleAboutWindow 
                   modalForWindow:[hostingDelegate window] 
                    modalDelegate:self 
                   didEndSelector:nil 
                      contextInfo:nil];
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
            NSWindow *window = [(NSWindowController *)hostingDelegate window];
            [NSApp beginSheet:bookmarkPanel
               modalForWindow:window
                modalDelegate:self
               didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
                  contextInfo:nil];
            break;
        }
        case BookmarkMenuEditBM:
        {
            Bookmark *clickedObj = [[[outlineView itemAtRow:[outlineView clickedRow]] representedObject] listObject];
            // set as content
            [bmObjectController setContent:clickedObj];
            // bring up bookmark panel
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
                NSArray *indexes = [treeController selectionIndexPaths];
                for(NSIndexPath *path in indexes) {
                    if([path length] == 2) {
                        // we have to remove from root
                        int index = [path indexAtPosition:1];
                        [[bookmarkManager bookmarks] removeObjectAtIndex:index];
                    } else if([path length] > 2) {
                        Bookmark *bm = [[bookmarkManager bookmarks] objectAtIndex:[path indexAtPosition:1]];
                        for(int i = 2;i < [path length]-1;i++) {
                            bm = [[bm subGroups] objectAtIndex:[path indexAtPosition:i]];
                        }
                        // if we have a bookmark, remove it
                        if(bm) {
                            [[bm subGroups] removeObjectAtIndex:[path indexAtPosition:[path length]-1]];
                        }
                    }
                    
                }
                //[treeController removeObjectsAtArrangedObjectIndexPaths:indexes];
                [bookmarkManager saveBookmarks];
                // trigger reloading
                [treeController rearrangeObjects];                
            }
            break;
        }
        case BookmarkMenuOpenBMInNew:
        {
            Bookmark *clickedObj = [[[outlineView itemAtRow:[outlineView clickedRow]] representedObject] listObject];
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
            if([[treeController selectedObjects] count] > 0) {
                // OutlineListObject will be generated on the fly, so we don't need to update them
                Bookmark *selected = [[[treeController selectedObjects] objectAtIndex:0] listObject];
                if(selected == nil) {
                    // we add to root
                    [[bookmarkManager bookmarks] addObject:bm];
                } else {
                    // add to selected
                    [[selected subGroups] addObject:bm];
                    /*
                     NSIndexPath *ip = [treeController selectionIndexPath];
                     [treeController insertObject:bm atArrangedObjectIndexPath:[ip indexPathByAddingIndex:0]];
                     */
                }
            } else {
                // we add to root
                [[bookmarkManager bookmarks] addObject:bm];
                //[treeController addObject:bm];
            }
        }
        
        // save
        [bookmarkManager saveBookmarks];
        // trigger reloading of tree elements
        [treeController rearrangeObjects];        
    }
    
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
    }
}

#pragma mark - outline datasource methods

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard {
    // make sure this is no module that we are dragging here
    NSMutableArray *dragItems = [NSMutableArray arrayWithCapacity:[items count]];
    for(int i = 0;i < [items count];i++) {
        OutlineListObject *l = [[items objectAtIndex:i] representedObject];
        int t = [l objectType];
        if(t == OutlineItemBookmark || t == OutlineItemBookmarkDir) {
            // go ahead
            // get the bookmarks instances and encode them
            BookmarkDragItem *di = [[BookmarkDragItem alloc] init];
            di.bookmark = [l listObject];
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
    OutlineListObject *l = [item representedObject];
    int t = [l objectType];
    if(t == OutlineItemBookmarkRoot || t == OutlineItemBookmarkDir || t == OutlineItemBookmark) {
        
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

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index {
    
    // get our data from the paste board
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData *data = [pboard dataForType:DD_BOOKMARK_TYPE];
    NSArray *bms = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    // we should have now some bookmark instances
    Bookmark *bitem = [[item representedObject] listObject];
    // is first level object?
    NSMutableArray *dropPoint = nil;
    if(bitem == nil) {        
        dropPoint = [bookmarkManager bookmarks];
    } else {
        dropPoint = [bitem subGroups];
    }
    
    // was it a move operation?
    // delete first, otherwise the path may not be correct anymore
    if([info draggingSourceOperationMask] != NSDragOperationCopy) { 
        // delete the source objects
        for(BookmarkDragItem *bd in bms) {
            [self deleteBookmarkForPath:[bd path]];
        }
    }

    // copy to drop point
    for(BookmarkDragItem *bd in bms) {
        [dropPoint insertObject:[bd bookmark] atIndex:index];
    }
        
    // let tree controller rearrange
    [bookmarkManager saveBookmarks];
    [treeController rearrangeObjects];
    
    return YES;
}

#pragma mark - outline delegate methods

- (void)doubleClick {
    // get clicked row
    int clickedRow = [outlineView clickedRow];
    OutlineListObject *clickedObj = [[outlineView itemAtRow:clickedRow] representedObject];
    
    if([clickedObj objectType] == OutlineItemModule) {
        SwordModule *mod  = [clickedObj listObject];
        // depending on the hosting window we open a new tab or window
        if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [(WorkspaceViewHostController *)hostingDelegate addTabContentForModule:mod];        
        } else if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            // default action on this is open another single view host with this module
            [[AppController defaultAppController] openSingleHostWindowForModule:mod];        
        }
    } else if([clickedObj objectType] == OutlineItemBookmark) {
        Bookmark *b = [clickedObj listObject];
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
                OutlineListObject *item = [[oview itemAtRow:[oview selectedRow]] representedObject];
                int t = [item objectType];
                if(t == OutlineItemBookmarkDir || t == OutlineItemBookmark || t == OutlineItemBookmarkRoot) {
                    [oview setMenu:bookmarkMenu];
                } else if(t == OutlineItemModule) {
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

    if(item != nil) {        
        OutlineListObject *o = [item representedObject];
        int t = [o objectType];
        if(t == OutlineItemModuleRoot || t == OutlineItemBookmarkRoot) {
            NSFont *font = FontLargeBold;
            //float pointSize = [font pointSize];
            //[aOutlineView setRowHeight:pointSize + 6];
            
            [cell setFont:font];
            [cell setTextColor:[NSColor grayColor]];
            [(ThreeCellsCell *)cell setImage:nil];
            [(ThreeCellsCell *)cell setRightImage:nil];
            //[(ThreeCellsCell *)cell setNumberValue:[NSNumber numberWithInt:4]];
            //float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
        } else {
            NSFont *font = FontStd;
            //float pointSize = [font pointSize];
            //[aOutlineView setRowHeight:pointSize + 6];
            
            [cell setFont:font];
            [cell setTextColor:[NSColor blackColor]];
            [(ThreeCellsCell *)cell setRightImage:nil];
            [(ThreeCellsCell *)cell setImage:nil];
            
            if(t == OutlineItemBookmark) {
                [(ThreeCellsCell *)cell setImage:bookmarkImage];
            } else if(t == OutlineItemBookmarkDir) {
                [(ThreeCellsCell *)cell setImage:bookmarkGroupImage];            
            } else if(t == OutlineItemModule) {
                [(ThreeCellsCell *)cell setImage:nil];
                SwordModule *mod = [o listObject];
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
        OutlineListObject *o = [item representedObject];
        int t = [o objectType];
        if(t == OutlineItemBookmark) {
            Bookmark *b = [o listObject];
            return [b reference];
        }
    }
    
    return @"";
}

@end
