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
#import "BookmarksUIController.h"
#import "ModulesUIController.h"
#import "globals.h"

#define LEFTSIDEBARVIEW_NIBNAME   @"LeftSideBarView"

// drag & drop types
#define DD_BOOKMARK_TYPE    @"ddbookmarktype"
#define DD_NOTE_TYPE        @"ddnotetype"

@interface LeftSideBarViewController ()

- (void)reload;
- (BOOL)isDropSectionBookmarksForItem:(id)anItem;
- (BOOL)isDropSectionNotesForItem:(id)anItem;

@end

@implementation LeftSideBarViewController

- (id)initWithDelegate:(WindowHostController *)aDelegate {
    self = [super initWithDelegate:aDelegate];
    if(self) {
        swordManager = [SwordManager defaultManager];
        bookmarkManager = [BookmarkManager defaultManager];
        notesManager = [NotesManager defaultManager];
        
        bookmarkGroupImage = [[NSImage imageNamed:@"Drawer.png"] retain];
        bookmarkImage = [[NSImage imageNamed:@"smallbookmark.tiff"] retain];
        lockedImage = [[NSImage imageNamed:NSImageNameLockLockedTemplate] retain];
        unlockedImage = [[NSImage imageNamed:NSImageNameLockUnlockedTemplate] retain];
        notesDrawerImage = [[NSImage imageNamed:@"Drawer.png"] retain];
        noteImage = [[NSImage imageNamed:@"edit_small.png"] retain];

        modulesRootItem = NSLocalizedString(@"LSBModules", @"");
        bookmarksRootItem = NSLocalizedString(@"LSBBookmarks", @"");
        notesRootItem = NSLocalizedString(@"LSBNotes", @"");        
        
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
    [outlineView registerForDraggedTypes:[NSArray arrayWithObjects:DD_BOOKMARK_TYPE, DD_NOTE_TYPE, nil]];
	// make our outline view appear with gradient selection, and behave like the Finder, iTunes, etc.
	[outlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    
    // expand the first two items
    // second first, otherwise second is not second anymore
    [outlineView expandItem:[outlineView itemAtRow:1]];
    [outlineView expandItem:[outlineView itemAtRow:0]];
    
    [super awakeFromNib];
}

- (void)finalize {
    [super finalize];
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
    [outlineView collapseItem:nil collapseChildren:NO];
    [outlineView expandItem:bookmarksRootItem];
    [outlineView expandItem:modulesRootItem];
}

- (void)reloadForController:(LeftSideBarAccessoryUIController *)aController {
    if([aController isKindOfClass:[ModulesUIController class]]) {
        [outlineView reloadItem:modulesRootItem reloadChildren:YES];
    } else if([aController isKindOfClass:[BookmarksUIController class]]) {
        [outlineView reloadItem:bookmarksRootItem reloadChildren:YES];
    } else if([aController isKindOfClass:[NotesUIController class]]) {
        [outlineView reloadItem:notesRootItem reloadChildren:YES];        
    }
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
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
    } else if(item == modulesRootItem) {
        // modules root
        // get categories
        ret = [[SwordModCategory moduleCategories] count];
    } else if(item == bookmarksRootItem) {
        // bookmarks root        
        // get bookmarks
        ret = [[[BookmarkManager defaultManager] bookmarks] count];
    } else if(item == notesRootItem) {
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
        // we have three root items (modules, bookmarks, notes)
        if(index == 0) {
            ret = modulesRootItem;
        } else if(index == 1) {
            ret = bookmarksRootItem;
        } else if(index == 2) {
            ret = notesRootItem;
        }
    } else if(item == modulesRootItem) {
        // modules root
        // get categories
        ret = [[SwordModCategory moduleCategories] objectAtIndex:index];
    } else if(item == bookmarksRootItem) {
        // bookmarks root
        // get bookmarks
        ret = [[bookmarkManager bookmarks] objectAtIndex:index];
    } else if(item == notesRootItem) {
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
    
    if(item == modulesRootItem) {
        ret = YES;
    } else if(item == bookmarksRootItem) {
        ret = YES;
    } else if(item == notesRootItem) {
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
    
    if(item == modulesRootItem) {
        ret = item;
    } else if(item == bookmarksRootItem) {
        ret = item;
    } else if(item == notesRootItem) {
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
    NSString *dragType = @"";
    NSMutableArray *dragItems = [NSMutableArray arrayWithCapacity:[items count]];
    for(int i = 0;i < [items count];i++) {
        id item = [items objectAtIndex:i];
        if([item isKindOfClass:[Bookmark class]]) {
            // get the bookmarks instances and encode them
            BookmarkDragItem *di = [[BookmarkDragItem alloc] init];
            di.bookmark = item;
            NSIndexPath *path = [bookmarkManager indexPathForBookmark:di.bookmark];
            di.path = path;
            [dragItems addObject:di];
            dragType = DD_BOOKMARK_TYPE;
        } else if([item isKindOfClass:[FileRepresentation class]]) {
            [dragItems addObject:[(FileRepresentation *)item filePath]];
            dragType = DD_NOTE_TYPE;
        }
    }
    
    if([dragItems count] > 0) {
        // write them to paste board
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dragItems];
        [pboard declareTypes:[NSArray arrayWithObject:dragType] owner:self];
        [pboard setData:data forType:dragType];
        return YES;        
    }
    
    return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    // make sure we drop only with in bookmarks
    if([self isDropSectionBookmarksForItem:item] ||
       [self isDropSectionNotesForItem:item]) {
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
    return ([anItem isKindOfClass:[Bookmark class]] || (anItem == bookmarksRootItem));
}

- (BOOL)isDropSectionNotesForItem:(id)anItem {
    return (([anItem isKindOfClass:[FileRepresentation class]] && [(FileRepresentation *)anItem isDirectory]) || (anItem == notesRootItem));
}

- (BOOL)outlineView:(NSOutlineView *)anOutlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index {
    // get our data from the paste board
    NSPasteboard* pboard = [info draggingPasteboard];
    if([pboard dataForType:DD_BOOKMARK_TYPE]) {
        NSData *data = [pboard dataForType:DD_BOOKMARK_TYPE];
        // Bookmarks dragging
        NSArray *draggedBookmarks = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        Bookmark *bitem = item;
        // is first level object?
        NSMutableArray *dropPoint = nil;
        if(bitem == bookmarksRootItem) {
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
        [outlineView reloadItem:bookmarksRootItem reloadChildren:YES];
    } else if([pboard dataForType:DD_NOTE_TYPE]) {
        NSData *data = [pboard dataForType:DD_NOTE_TYPE];
        NSArray *draggedNotePaths = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if(item == notesRootItem) {
            item = [notesManager notesFileRep];
        }
        
        for(NSString *filePath in draggedNotePaths) {
            FileRepresentation *fileRep = [notesManager fileRepForPath:filePath];
            if(fileRep != nil) {
                // item is dropPoint, has to be Folder FileRepresentation
                NSDragOperation draggingOperation = [info draggingSourceOperationMask];
                if(draggingOperation == NSDragOperationCopy) {
                    [FileRepresentation copyComplete:fileRep to:item];
                } else {
                    [FileRepresentation moveComplete:fileRep to:item];
                }
            }
        }
        [outlineView reloadItem:notesRootItem reloadChildren:YES];
    }
    
    return YES;
}

#pragma mark - outline delegate methods

- (void)doubleClick {
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
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {
            
			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			int len = [selectedRows count];
            
            if(len == 1) {
                id item = [oview itemAtRow:[oview selectedRow]];
                if([item isKindOfClass:[Bookmark class]] || 
                   (item == bookmarksRootItem)) {
                    [oview setMenu:[[self bookmarksUIController] bookmarkMenu]];
                } else if([item isKindOfClass:[SwordModule class]]) {
                    [oview setMenu:[[self modulesUIController] moduleMenu]];
                } else if([item isKindOfClass:[FileRepresentation class]] ||
                          (item == notesRootItem)) {
                    [oview setMenu:[[self notesUIController] notesMenu]];
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
    if(item != nil) {
        if(item == modulesRootItem || 
           item == bookmarksRootItem ||
           item == notesRootItem) {
            return YES;
        }
    }
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
            NSFont *font = FontStdBold;
            //float pointSize = [font pointSize];
            //[aOutlineView setRowHeight:pointSize + 6];
            
            [cell setFont:font];
            //[cell setTextColor:[NSColor grayColor]];
            //float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
        } else {
            NSFont *font = FontStd;
            //float pointSize = [font pointSize];
            //[aOutlineView setRowHeight:pointSize + 6];
            
            [cell setFont:font];
            //[cell setTextColor:[NSColor blackColor]];
            
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
