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

@synthesize bookmarkMenu;

- (id)init {
    return [super init];
}

- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate {
    self = [super initWithDelegate:aDelegate hostingDelegate:aHostingDelegate];
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
    Bookmark *clickedObj = (Bookmark *)[self delegateSelectedObject];
    if([bookmarkSelection count] == 0 || [bookmarkSelection count] == 1) {
        // get current selected module of clicked row
        if(clickedObj && [clickedObj isKindOfClass:[Bookmark class]]) {
            // replace any old selected with the clicked one
            [bookmarkSelection removeAllObjects];
            [bookmarkSelection addObject:clickedObj];
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
                   ([(SingleViewHostController *)hostingDelegate contentViewType] == SwordBibleContentType || 
                    [(SingleViewHostController *)hostingDelegate contentViewType] == SwordCommentaryContentType)) {
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
        
    Bookmark *clickedObj = (Bookmark *)[self delegateSelectedObject];
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
            [bookmarkOkButton setEnabled:NO];
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
            [bookmarkOkButton setEnabled:YES];
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
                                           alternateButton:NSLocalizedString(@"No", @"") 
                                               otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"ConfirmBookmarkDeleteText", @"")];
            if([alert runModal] == NSAlertDefaultReturn) {
                [self updateBookmarkSelection];
                for(Bookmark *b in bookmarkSelection) {
                    [bookmarkManager deleteBookmark:b];
                }
                [bookmarkManager saveBookmarks];
                [self delegateReload];
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
            [self delegateDoubleClick];
            break;
    }    
}

- (IBAction)bmWindowCancel:(id)sender {
    [NSApp endSheet:bookmarkDetailPanel];
}

- (IBAction)bmWindowOk:(id)sender {
    [NSApp endSheet:bookmarkDetailPanel];
    
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
    
    [self delegateReload];
}

- (IBAction)bmFolderWindowCancel:(id)sender {
    [NSApp endSheet:bookmarkFolderWindow];
}

- (IBAction)bmFolderWindowOk:(id)sender {
    [NSApp endSheet:bookmarkFolderWindow];
    
    [self updateBookmarkSelection];

    // create new bookmark folder
    Bookmark *bm = [[Bookmark alloc] initWithName:[bookmarkFolderNameTextField stringValue]];
    [bm setSubGroups:[NSMutableArray array]];   // this will get a folder 
    
    if([bookmarkSelection count] > 0) {
        Bookmark *selected = [bookmarkSelection objectAtIndex:0];
        if(selected == nil) {
            [[bookmarkManager bookmarks] addObject:bm];
        } else {
            if(![selected isLeaf]) {
                [[selected subGroups] addObject:bm];            
            } else {
                [[bookmarkManager bookmarks] addObject:bm];            
            }
        }
    } else {
        [[bookmarkManager bookmarks] addObject:bm];
    }
    
    [bookmarkManager saveBookmarks];
    [self delegateReload];
}

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	// hide sheet
	[sSheet orderOut:nil];
}

#pragma mark - NSControl delegate methods

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if([aNotification object] == bookmarkFolderNameTextField) {
        [bookmarkFolderOkButton setEnabled:[[bookmarkFolderNameTextField stringValue] length] > 0];
    } else if([aNotification object] == bookmarkNameTextField) {
        [bookmarkOkButton setEnabled:[[bookmarkNameTextField stringValue] length] > 0];        
    }
}

@end
