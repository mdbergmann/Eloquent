//
//  BookmarkOutlineViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkOutlineViewController.h"
#import "AppController.h"
#import "BibleCombiViewController.h"
#import "HostableViewController.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "BookmarkManager.h"
#import "Bookmark.h"

enum BookmarkMenu_Items{
    BookmarkMenuAddNewBM = 1,
    BookmarkMenuEditBM,
    BookmarkMenuRemoveBM,
    BookmarkMenuOpenBMInNew,
    BookmarkMenuOpenBMInCurrent,
};

@interface BookmarkOutlineViewController ()

- (void)doubleClick;

@end

@implementation BookmarkOutlineViewController

@synthesize manager;

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[BookmarkOutlineViewController -init] loading nib");
        
        // set delegate
        self.delegate = aDelegate;
        
        // get the default manager
        self.manager = [BookmarkManager defaultManager];
        
        // init selection
        selection = [[NSMutableArray alloc] init];

        // load nib
        BOOL stat = [NSBundle loadNibNamed:BOOKMARKOUTLINEVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BookmarkOutlineViewController -init] unable to load nib!");
        }            
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[BookmarkOutlineViewController -awakeFromNib]");
    
    // set double click action
    [outlineView setTarget:self];
    [outlineView setDoubleAction:@selector(doubleClick)];
    
    // loading finished
    viewLoaded = YES;
    [self reportLoadingComplete];
}

# pragma mark - Methods

#pragma mark - Module menu/actions

//--------------------------------------------------------------------
//----------- NSMenu validation --------------------------------
//--------------------------------------------------------------------
/**
 \brief validate menu
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	MBLOGV(MBLOG_DEBUG, @"[BookmarkOutlineViewController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = YES;
    
    // get menuitem tag
    int tag = [menuItem tag];
    
    if(tag == BookmarkMenuAddNewBM) {
        ret = YES;
    } else if(tag == BookmarkMenuRemoveBM) {
        if([[bmTreeController selectedObjects] count] > 0) {
            ret = YES;
        }
    } else if(tag == BookmarkMenuEditBM) {
        if([[bmTreeController selectedObjects] count] > 0) {
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

- (IBAction)bookmarkMenuClicked:(id)sender {
	MBLOGV(MBLOG_DEBUG, @"[BookmarkOutlineViewController -menuClicked:] %@", [sender description]);
    
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
            Bookmark *clickedObj = [[outlineView itemAtRow:[outlineView clickedRow]] representedObject];
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
            NSArray *indexes = [bmTreeController selectionIndexPaths];
            [bmTreeController removeObjectsAtArrangedObjectIndexPaths:indexes];
            [manager saveBookmarks];
            break;
        }
        case BookmarkMenuOpenBMInNew:
        {
            Bookmark *clickedObj = [[outlineView itemAtRow:[outlineView clickedRow]] representedObject];
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
    if(bookmarkAction == BookmarkMenuAddNewBM) {
        if([[bmTreeController selectedObjects] count] > 0) {
            Bookmark *selected = [[bmTreeController selectedObjects] objectAtIndex:0];
            if(selected == nil) {
                // we add to root
                [bmTreeController addObject:bm];
            } else {
                NSIndexPath *ip = [bmTreeController selectionIndexPath];
                //if([selected isLeaf]) {
                //    [bmTreeController insertObject:bm atArrangedObjectIndexPath:ip];                    
                //} else {
                    [bmTreeController insertObject:bm atArrangedObjectIndexPath:[ip indexPathByAddingIndex:0]];
                //}
            }
        } else {
            // we add to root
            [bmTreeController addObject:bm];
        }
    }
    
    // save
    [manager saveBookmarks];
    
    // reload outline view
    [outlineView reloadData];
}

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	// hide sheet
	[sSheet orderOut:nil];
}

#pragma mark - outline delegate methods

- (void)doubleClick {
    // get clicked row
    int clickedRow = [outlineView clickedRow];    
    Bookmark *clickedObj = [[outlineView itemAtRow:clickedRow] representedObject];
    // check for type of host
    if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
        [(SingleViewHostController *)hostingDelegate setSearchText:[clickedObj reference]];
    } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
        [(WorkspaceViewHostController *)hostingDelegate setSearchText:[clickedObj reference]];
    }
}

//--------------------------------------------------------------------
//----------- NSOutlineView delegates --------------------------------
//--------------------------------------------------------------------
/**
 \brief Notification is called when the selection has changed 
 */
/*
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    MBLOG(MBLOG_DEBUG,@"[ModuleOutlineViewController outlineViewSelectionDidChange:]");
    
    if(notification != nil) {
        NSOutlineView *oview = [notification object];
        if(oview != nil) {
            
            [selection removeAllObjects];
            
            NSIndexSet *selectedRows = [oview selectedRowIndexes];
            int len = [selectedRows count];
            NSDictionary *item = nil;
            if(len > 0) {
                unsigned int indexes[len];
                [selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
                
                for(int i = 0;i < len;i++) {
                    item = [oview itemAtRow:indexes[i]];
                    
                    // add to array
                    [selection addObject:item];
                }
            }
        } else {
            MBLOG(MBLOG_WARN,@"[ModuleOutlineViewController outlineViewSelectionDidChange:] have a nil notification object!");
        }
    } else {
        MBLOG(MBLOG_WARN,@"[ModuleOutlineViewController outlineViewSelectionDidChange:] have a nil notification!");
    }
}

- (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    
	// display call with std font
	NSFont *font = FontLarge;    
	[cell setFont:font];
	//float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
	float pointSize = [font pointSize];
	[aOutlineView setRowHeight:pointSize+6];
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    int count = 0;
	
	if(item == nil) {
        // bookmarks
        count = [[manager bookmarks] count];
    } else if([item isKindOfClass:[Bookmark class]]) {
        // bookmarks subgroups
        Bookmark *bitem = item;
        if([bitem subGroups] != nil) {
            count = [[bitem subGroups] count];
        }
    }
	
	return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    
    id ret = nil;
    
    if(item == nil) {
        // bookmarks
        ret = [[manager bookmarks] objectAtIndex:index];
    } else if([item isKindOfClass:[Bookmark class]]) {
        // subgroup bookmarks
        ret = [[(Bookmark *)item subGroups] objectAtIndex:index];
    } else {
        ret = @"test";
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    
    NSString *ret = @"test";
    
    if(item != nil) {
        if([item isKindOfClass:[Bookmark class]]) {
            ret = [(Bookmark *)item name];
        }
    }
    
    return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    
    if(item != nil && 
       ([item isKindOfClass:[Bookmark class]] && [(Bookmark *)item subGroups] != nil)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    if(item != nil) {
        if([item isKindOfClass:[Bookmark class]]) {
            return YES;
        }
    }
    
    return NO;
}
 
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}
*/

 - (NSString *)outlineView:(NSOutlineView *)ov toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc item:(id)item mouseLocation:(NSPoint)mouseLocation {
     
     if(item != nil) {
         Bookmark *bitem = [item representedObject];
         if([bitem isLeaf]) {
             return [bitem reference];
         }
     }

     return @"";
}
 
@end
