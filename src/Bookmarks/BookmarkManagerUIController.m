//
//  BookmarkManagerUIController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 16.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "BookmarkManagerUIController.h"
#import "WindowHostController.h"
#import "SingleViewHostController.h"
#import "LeftSideBarViewController.h"
#import "AppController.h"
#import "Bookmark.h"
#import "BookmarkManager.h"
#import "SearchTextObject.h"

#define BOOKMARKMANAGER_UI_NIBNAME @"BookmarkManagerUI"

enum BookmarkMenu_Items{
    BookmarkMenuAddNewBM = 1,
    BookmarkMenuAddNewBMFolder,
    BookmarkMenuEditBM,
    BookmarkMenuRemoveBM,
    BookmarkMenuOpenBMInNew,
    BookmarkMenuOpenBMInCurrent,
}BookMarkMenuItems;

@interface BookmarkManagerUIController ()

- (void)updateBookmarkSelection;

@end

@implementation BookmarkManagerUIController

@synthesize delegate;
@synthesize hostingDelegate;
@synthesize bookmarkMenu;

- (id)init {
    self = [super init];
    if(self) {
        bookmarkSelection = [[NSMutableArray alloc] init];
        bookmarkManager = [BookmarkManager defaultManager];

        BOOL stat = [NSBundle loadNibNamed:BOOKMARKMANAGER_UI_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BookmarkManagerUIController -init] unable to load nib!");
        }        
    }
    return self;
}

- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate {
    self = [self init];
    self.delegate = aDelegate;
    self.hostingDelegate = aHostingDelegate;
    
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)awakeFromNib {
    
}

#pragma mark - Methods

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
    [NSApp beginSheet:bookmarkDetailPanel
       modalForWindow:window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
          contextInfo:nil];
}

- (void)updateBookmarkSelection {
    id clicked = [(LeftSideBarViewController *)delegate objectForClickedRow];
    if([bookmarkSelection count] == 0 || [bookmarkSelection count] == 1) {
        // get current selected module of clicked row
        if(clicked && [clicked isKindOfClass:[Bookmark class]]) {
            // replace any old selected with the clicked one
            [bookmarkSelection removeAllObjects];
            [bookmarkSelection addObject:clicked];
        }
    }    
}

#pragma mark - Menu Validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	MBLOGV(MBLOG_DEBUG, @"[BookmarkManagerUIController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = NO;
    
    if(delegate && hostingDelegate) {
        int tag = [menuItem tag];        
        switch(tag) {
            case BookmarkMenuAddNewBM:
            case BookmarkMenuAddNewBMFolder:
            case BookmarkMenuOpenBMInNew:
                ret = YES;
                break;
            case BookmarkMenuRemoveBM:
            case BookmarkMenuEditBM:
                [self updateBookmarkSelection];
                if([bookmarkSelection count] > 0) {
                    ret = YES;
                }
                break;
            case BookmarkMenuOpenBMInCurrent:
                // we can only open in current, if it is a commentary or bible view
                if([hostingDelegate isKindOfClass:[SingleViewHostController class]] && 
                   ([(SingleViewHostController *)hostingDelegate moduleType] == bible || [(SingleViewHostController *)hostingDelegate moduleType] == commentary)) {
                    ret = YES;
                }
                break;
        }
    } else {
        MBLOG(MBLOG_ERR, @"[BookmarkManagerUIController -validateMenuItem:] delegate and hostingDelegate are not available!");
    }
    
    return ret;
}

#pragma mark - Actions

- (IBAction)bookmarkMenuClicked:(id)sender {
	MBLOGV(MBLOG_DEBUG, @"[BookmarkManagerUIController -menuClicked:] %@", [sender description]);
        
    Bookmark *clickedObj = [(LeftSideBarViewController *)delegate objectForClickedRow];
    int tag = [sender tag];
    bookmarkAction = tag;
    switch(tag) {
        case BookmarkMenuAddNewBM:
        {
            Bookmark *new = [[Bookmark alloc] init];
            // set as content
            [bmObjectController setContent:new];
            // bring up bookmark panel
            [bookmarkDetailPanel makeFirstResponder:bookmarkNameTextField];
            NSWindow *window = [(NSWindowController *)hostingDelegate window];
            [NSApp beginSheet:bookmarkDetailPanel
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
            // set as content
            [bmObjectController setContent:clickedObj];
            // bring up bookmark panel
            [bookmarkDetailPanel makeFirstResponder:bookmarkNameTextField];
            NSWindow *window = [(NSWindowController *)hostingDelegate window];
            [NSApp beginSheet:bookmarkDetailPanel 
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
                [self updateBookmarkSelection];
                for(Bookmark *b in bookmarkSelection) {
                    [bookmarkManager deleteBookmark:b];
                }
                [bookmarkManager saveBookmarks];
                [delegate reload];
            }
            break;
        }
        case BookmarkMenuOpenBMInNew:
        {
            // open new window
            SingleViewHostController *newC = [[AppController defaultAppController] openSingleHostWindowForModule:nil];
            [newC setSearchText:[clickedObj reference]];
        }
            break;
        case BookmarkMenuOpenBMInCurrent:
            [delegate doubleClick];
            break;
    }    
}

- (IBAction)bmWindowCancel:(id)sender {
    [NSApp endSheet:bookmarkDetailPanel];
}

- (IBAction)bmWindowOk:(id)sender {
    [NSApp endSheet:bookmarkDetailPanel];
    
    // get bookmark
    Bookmark *bm = [bmObjectController content];
    if([[bm name] length] > 0) {
        if(bookmarkAction == BookmarkMenuAddNewBM) {
            [self updateBookmarkSelection];
            
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
        
        [bookmarkManager saveBookmarks];
    }    
    [delegate reload];
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
        [self updateBookmarkSelection];
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
    
    [bookmarkManager saveBookmarks];
    [delegate reloadData];    
}

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	// hide sheet
	[sSheet orderOut:nil];
}

#pragma mark - NSControl delegate methods

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if([aNotification object] == bookmarkFolderNameTextField) {
        if([[bookmarkFolderNameTextField stringValue] length] == 0) {
            [bookmarkFolderOkButton setEnabled:NO];
        } else {
            [bookmarkFolderOkButton setEnabled:YES];        
        }
    }
}

@end
