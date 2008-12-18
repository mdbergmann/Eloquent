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
    ModuleMenuOpenCurrent
}ModuleMenuItems;

@interface LeftSideBarViewController ()

- (void)doubleClick;
- (void)prepareTreeContent;

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

    [super awakeFromNib];
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
	MBLOGV(MBLOG_DEBUG, @"[ModuleOutlineViewController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = YES; // all of the module stype should be able to show in a single view host
    
    // get menuitem tag
    int tag = [menuItem tag];
    
    // ------------ modules ---------------
    if(tag == ModuleMenuOpenCurrent) {
        // get module
        OutlineListObject *clicked = [outlineView itemAtRow:[outlineView clickedRow]];
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

- (IBAction)moduleMenuClicked:(id)sender {
	MBLOGV(MBLOG_DEBUG, @"[ModuleOutlineViewController -moduleMenuClicked:] %@", [sender description]);
    
    int tag = [sender tag];
    
    // get module
    SwordModule *mod = nil;
    OutlineListObject *clicked = [outlineView itemAtRow:[outlineView clickedRow]];
    if([clicked objectType] == OutlineItemModule) {
        mod = [clicked listObject];
    }
    
    switch(tag) {
        case ModuleMenuOpenSingle:
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
        }
    }
}

#pragma mark - Bookmark methods

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
            NSArray *indexes = [treeController selectionIndexPaths];
            [treeController removeObjectsAtArrangedObjectIndexPaths:indexes];
            [bookmarkManager saveBookmarks];
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
        if([[treeController selectedObjects] count] > 0) {
            Bookmark *selected = [[treeController selectedObjects] objectAtIndex:0];
            if(selected == nil) {
                // we add to root
                [treeController addObject:bm];
            } else {
                NSIndexPath *ip = [treeController selectionIndexPath];
                [treeController insertObject:bm atArrangedObjectIndexPath:[ip indexPathByAddingIndex:0]];
            }
        } else {
            // we add to root
            [treeController addObject:bm];
        }
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

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if(item != nil) {
        OutlineListObject *o = [item representedObject];
        int t = [o objectType];
        if(t == OutlineItemModuleRoot || t == OutlineItemBookmarkRoot) {
            NSFont *font = FontLargeBold;
            [cell setFont:font];
            //float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
            //float pointSize = [font pointSize];
            //[aOutlineView setRowHeight:pointSize+6];            
        } else {
            NSFont *font = FontStd;
            [cell setFont:font];            
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
