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
#import "NotesManager.h"
#import "NotesUIController.h"
#import "FileRepresentation.h"
#import "ThreeCellsCell.h"
#import "BookmarkDragItem.h"
#import "SearchTextObject.h"
#import "BookmarkManagerUIController.h"
#import "ModuleListUIController.h"
#import "globals.h"

#define LEFTSIDEBARVIEW_NIBNAME   @"LeftSideBarView"

// drag & drop types
#define DD_BOOKMARK_TYPE   @"ddbookmarktype"

@interface LeftSideBarViewController ()

- (void)reload;
- (BOOL)isDropSectionBookmarksForItem:(id)anItem;

@end

@implementation LeftSideBarViewController

- (id)initWithDelegate:(id)aDelegate {
    self = [super initWithDelegate:aDelegate];
    if(self) {
        swordManager = [SwordManager defaultManager];
        moduleListUIController = [[ModuleListUIController alloc] initWithDelegate:self hostingDelegate:delegate];
        bookmarkManager = [BookmarkManager defaultManager];
        bookmarksUIController = [[BookmarkManagerUIController alloc] initWithDelegate:self hostingDelegate:delegate];
        notesManager = [NotesManager defaultManager];
        notesUIController = [[NotesUIController alloc] initWithDelegate:self hostingDelegate:delegate];
        
        // prepare images
        bookmarkGroupImage = [[NSImage imageNamed:@"Drawer.png"] retain];
        bookmarkImage = [[NSImage imageNamed:@"smallbookmark.tiff"] retain];
        lockedImage = [[NSImage imageNamed:NSImageNameLockLockedTemplate] retain];
        unlockedImage = [[NSImage imageNamed:NSImageNameLockUnlockedTemplate] retain];
        notesDrawerImage = [[NSImage imageNamed:@"Drawer.png"] retain];
        noteImage = [[NSImage imageNamed:@"edit_small.png"] retain];
                
        // load nib
        BOOL stat = [NSBundle loadNibNamed:LEFTSIDEBARVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[LeftSideBarViewController -init] unable to load nib!");
        }
    }
    
    return self;
}

- (void)awakeFromNib {
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

- (void)reload {
    [outlineView reloadData];
    [outlineView expandItem:[outlineView itemAtRow:1]];
    [outlineView expandItem:[outlineView itemAtRow:0]];
}

- (void)reloadForController:(LeftSideBarAccessoryUIController *)aController {
    if([aController isKindOfClass:[ModuleListUIController class]]) {
        [outlineView reloadItem:[outlineView itemAtRow:0] reloadChildren:YES];
    } else if([aController isKindOfClass:[BookmarkManagerUIController class]]) {
        [outlineView reloadItem:[outlineView itemAtRow:1] reloadChildren:YES];
    } else if([aController isKindOfClass:[NotesUIController class]]) {
        [outlineView reloadItem:[outlineView itemAtRow:2] reloadChildren:YES];        
    }
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

#pragma mark - outline datasource methods

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    NSInteger ret = 0;
    
    if(item == nil) {
        // we have two root items (modules, bookmarks, notes)
        ret = 3;
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBModules", @"")]) {
        // modules root
        // get categories
        ret = [[SwordModCategory moduleCategories] count];
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBBookmarks", @"")]) {
        // bookmarks root        
        // get bookmarks
        ret = [[[BookmarkManager defaultManager] bookmarks] count];
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBNotes", @"")]) {
        // notes root
        // get notes
        ret = [[[notesManager notesFileRep] directoryContent] count];
    } else if([item isKindOfClass:[SwordModCategory class]]) {
        // module category
        // get number of modules in category
        ret = [[swordManager modulesForType:[(SwordModCategory *)item name]] count];
    } else if([item isKindOfClass:[Bookmark class]] && ![(Bookmark *)item isLeaf]) {
        // bookmark folder
        ret = [[(Bookmark *)item subGroups] count];
    } else if([item isKindOfClass:[FileRepresentation class]] && [(FileRepresentation *)item isDirectory]) {
        // notes folder
        ret = [[(FileRepresentation *)item directoryContent] count];
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    id ret = nil;
    
    if(item == nil) {
        // we have two root items (modules, bookmarks)
        if(index == 0) {
            ret = NSLocalizedString(@"LSBModules", @"");
        } else if(index == 1) {
            ret = NSLocalizedString(@"LSBBookmarks", @"");
        } else if(index == 2) {
            ret = NSLocalizedString(@"LSBNotes", @"");
        }
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBModules", @"")]) {
        // modules root
        // get categories
        ret = [[SwordModCategory moduleCategories] objectAtIndex:index];
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBBookmarks", @"")]) {
        // bookmarks root
        // get bookmarks
        ret = [[bookmarkManager bookmarks] objectAtIndex:index];
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBNotes", @"")]) {
        // notes root
        // get notes
        ret = [[[notesManager notesFileRep] directoryContent] objectAtIndex:index];
    } else if([item isKindOfClass:[SwordModCategory class]]) {
        // module category
        // get number of modules in category
        ret = [[swordManager modulesForType:[(SwordModCategory *)item name]] objectAtIndex:index];
    } else if([item isKindOfClass:[Bookmark class]] && ![(Bookmark *)item isLeaf]) {
        // bookmark folder
        ret = [[(Bookmark *)item subGroups] objectAtIndex:index];
    } else if([item isKindOfClass:[FileRepresentation class]] && [(FileRepresentation *)item isDirectory]) {
        // notes folder
        ret = [[(FileRepresentation *)item directoryContent] objectAtIndex:index];
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
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBNotes", @"")]) {
        // notes root
        ret = YES;
    } else if([item isKindOfClass:[SwordModCategory class]]) {
        // module category
        ret = ([[swordManager modulesForType:[(SwordModCategory *)item name]] count] > 0);
    } else if([item isKindOfClass:[Bookmark class]] && ![(Bookmark *)item isLeaf]) {
        // bookmark folder
        ret = ([[(Bookmark *)item subGroups] count] > 0);
    } else if([item isKindOfClass:[FileRepresentation class]] && [(FileRepresentation *)item isDirectory]) {
        // notes folder
        ret = ([[(FileRepresentation *)item directoryContent] count] > 0);
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
    } else if([item isKindOfClass:[NSString class]] && [(NSString *)item isEqualToString:NSLocalizedString(@"LSBNotes", @"")]) {
        // notes root
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
    } else if([item isKindOfClass:[FileRepresentation class]]) {
        // note
        ret = [[(FileRepresentation *)item name] stringByDeletingPathExtension];
    }
    
    return ret;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if([item isKindOfClass:[FileRepresentation class]]) {
        FileRepresentation *fileRep = item;
        NSString *fileName = (NSString *)object;
        if(![fileRep isDirectory]) {
            fileName = [NSString stringWithFormat:@"%@.rtf", fileName];
        }
        [fileRep setName:fileName];            
    }    
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
            NSIndexPath *path = [bookmarkManager indexPathForBookmark:di.bookmark];
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
    if(data) {
        // Bookmarks dragging
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
                [bookmarkManager deleteBookmarkForPath:[bd path]];
                
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
    }
    
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
    } else if([clickedObj isKindOfClass:[FileRepresentation class]]) {
        FileRepresentation *f = clickedObj;
        // depending on the hosting window we open a new tab or window
        if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [(WorkspaceViewHostController *)hostingDelegate addTabContentForNote:f];        
        } else if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            // default action on this is open another single view host with this module
            [[AppController defaultAppController] openSingleHostWindowForNote:f];        
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
                    [oview setMenu:[bookmarksUIController bookmarkMenu]];
                } else if([item isKindOfClass:[SwordModule class]]) {
                    [oview setMenu:[moduleListUIController moduleMenu]];
                } else if([item isKindOfClass:[FileRepresentation class]]) {
                    [oview setMenu:[notesUIController notesMenu]];
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
    if([item isKindOfClass:[FileRepresentation class]]) {
        return YES;
    }
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    /*
    if(item != nil) {
        if([item isKindOfClass:[NSString class]] && 
           ([(NSString *)item isEqualToString:NSLocalizedString(@"LSBModules", @"")] ||
            [(NSString *)item isEqualToString:NSLocalizedString(@"LSBBookmarks", @"")] ||
            [(NSString *)item isEqualToString:NSLocalizedString(@"LSBNotes", @"")])) {
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
    [(ThreeCellsCell *)cell setEditable:NO];    

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
                ;
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
            } else if([item isKindOfClass:[FileRepresentation class]]) {
                [(ThreeCellsCell *)cell setEditable:YES];
                FileRepresentation *fileRep = item;
                if([fileRep isDirectory]) {
                    [(ThreeCellsCell *)cell setImage:notesDrawerImage];                    
                } else {
                    [(ThreeCellsCell *)cell setImage:noteImage];
                }
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
