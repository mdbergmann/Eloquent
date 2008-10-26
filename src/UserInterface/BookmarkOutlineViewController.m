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
#import "BookmarkManager.h"
#import "Bookmark.h"

enum BookmarkMenu_Items{
    BookmarkMenuAddNewBM = 1,
    BookmarkMenuOpenBMInNew,
    BookmarkMenuOpenBMInCurrent,
    BookmarkMenuRemoveBM
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
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:BOOKMARKOUTLINEVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BookmarkOutlineViewController -init] unable to load nib!");
        } else {
            // get the default manager
            self.manager = [BookmarkManager defaultManager];
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

#pragma mark - Module menu

//--------------------------------------------------------------------
//----------- NSMenu validation --------------------------------
//--------------------------------------------------------------------
/**
 \brief validate menu
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	MBLOGV(MBLOG_DEBUG, @"[BookmarkOutlineViewController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = YES; // all of the module stype should be able to show in a single view host
    
    // get menuitem tag
    int tag = [menuItem tag];
    
    if(tag == BookmarkMenuAddNewBM) {
        ret = NO;
    } else if(tag == BookmarkMenuOpenBMInNew) {
        // get module
        id clicked = [outlineView itemAtRow:[outlineView clickedRow]];
    } else if(tag == BookmarkMenuOpenBMInCurrent) {
    } else if(tag == BookmarkMenuRemoveBM) {
        // get module
        id clicked = [outlineView itemAtRow:[outlineView clickedRow]];
    }
    
    return ret;
}

- (IBAction)bookmarkMenuClicked:(id)sender {
	MBLOGV(MBLOG_DEBUG, @"[BookmarkOutlineViewController -menuClicked:] %@", [sender description]);
    
    int tag = [sender tag];
    
    switch(tag) {
        case BookmarkMenuAddNewBM:
            [self doubleClick];
            break;
        case BookmarkMenuOpenBMInNew:
            // do nothing
            break;
        case BookmarkMenuOpenBMInCurrent:
        {
            id clicked = [outlineView itemAtRow:[outlineView clickedRow]];
        }
            break;
        case BookmarkMenuRemoveBM:
            break;
    }    
}

#pragma mark - outline delegate methods

- (void)doubleClick {
    // get clicked row
    int clickedRow = [outlineView clickedRow];
    
    id clickedObj = [outlineView itemAtRow:clickedRow];
    if([clickedObj isKindOfClass:[SwordModule class]]) {
        // default action on this is open another single view host with this module
        [[AppController defaultAppController] openSingleHostWindowForModule:(SwordModule *)clickedObj];
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
 
 NSIndexSet *selectedRows = [oview selectedRowIndexes];
 int len = [selectedRows count];
 NSMutableArray *selection = [NSMutableArray arrayWithCapacity:len];
 NSDictionary *item = nil;
 if(len > 0) {
 unsigned int indexes[len];
 [selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
 
 for(int i = 0;i < len;i++) {
 item = [oview itemAtRow:indexes[i]];
 
 // add to array
 [selection addObject:item];
 }
 
 // set install source menu
 //[oview setMenu:installSourceMenu];
 }
 
 // update modules
 NSArray *selected = [NSArray arrayWithArray:selection];
 [self setSelectedInstallSources:selected];
 [modListViewController setInstallSources:selected];
 [modListViewController refreshModulesList];
 } else {
 MBLOG(MBLOG_WARN,@"[ModuleOutlineViewController outlineViewSelectionDidChange:] have a nil notification object!");
 }
 } else {
 MBLOG(MBLOG_WARN,@"[ModuleOutlineViewController outlineViewSelectionDidChange:] have a nil notification!");
 }
 }
 */

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
        count = [[[BookmarkManager defaultManager] bookmarks] count];
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
        ret = [[[BookmarkManager defaultManager] bookmarks] objectAtIndex:index];
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

@end
