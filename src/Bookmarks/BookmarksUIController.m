//
//  BookmarksUIController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 16.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "LeftSideBarAccessoryUIController.h"
#import "BookmarksUIController.h"
#import "HostableViewController.h"
#import "WindowHostController.h"
#import "SingleViewHostController.h"
#import "AppController.h"
#import "Bookmark.h"
#import "BookmarkManager.h"
#import "SearchTextObject.h"

#define BOOKMARKMANAGER_UI_NIBNAME @"BookmarkManagerUI"

enum BookmarkMenu_Items {
    BookmarkMenuAddNewBM = 1,
    BookmarkMenuAddNewBMFolder,
    BookmarkMenuEditBM,
    BookmarkMenuRemoveBM,
    BookmarkMenuOpenBMInNew,
    BookmarkMenuOpenBMInCurrent,
    BookmarkMenuEditBMFolder,    
}BookMarkMenuItems;

@interface BookmarksUIController ()

- (void)_createMenuStructure:(NSMenu *)menu fromBookmarkTree:(NSArray *)bookmarkList menuTarget:(id)aTarget menuSelector:(SEL)aSelector;
- (void)updateBookmarkSelection;

@end

@implementation BookmarksUIController

@synthesize bookmarkMenu;

- (id)init {
    return [super init];
}

- (id)initWithDelegate:(id<LeftSideBarDelegate>)aDelegate hostingDelegate:(WindowHostController *)aHostingDelegate {
    self = [super initWithDelegate:aDelegate hostingDelegate:aHostingDelegate];
    if(self) {
        bookmarkSelection = [[NSMutableArray alloc] init];
        bookmarkManager = [BookmarkManager defaultManager];
        
        BOOL stat = [NSBundle loadNibNamed:BOOKMARKMANAGER_UI_NIBNAME owner:self];
        if(!stat) {
            CocoLog(LEVEL_ERR, @"[BookmarkManagerUIController -init] unable to load nib!");
        }        
    }
    return self;
}

- (void)dealloc {
    [bookmarkSelection release];
    [super dealloc];
}


- (void)awakeFromNib {
}

#pragma mark - Methods

/**
 generate a menu structure
 
 @params[in|out] subMenuItem is the start of the menustructure.
 @params[in] aTarget the target object of the created menuitem
 @params[in] aSelector the selector of the target that should be called
 */
- (void)generateBookmarkMenu:(NSMenu **)itemMenu 
              withMenuTarget:(id)aTarget 
              withMenuAction:(SEL)aSelector {
    [self _createMenuStructure:*itemMenu 
              fromBookmarkTree:[[BookmarkManager defaultManager] bookmarks] 
                    menuTarget:aTarget
                  menuSelector:aSelector];
}

- (void)_createMenuStructure:(NSMenu *)menu fromBookmarkTree:(NSArray *)bookmarkList menuTarget:(id)aTarget menuSelector:(SEL)aSelector {
    // loop over bookmarks in list
    for(Bookmark *bm in bookmarkList) {
        if([bm isLeaf]) {
            NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
            [item setTitle:[bm name]];
            [item setTarget:aTarget];
            [item setAction:aSelector];
            [item setEnabled:YES];
            [item setRepresentedObject:bm];
            [menu addItem:item];
        } else {
            NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
            [item setTitle:[bm name]];
            [item setSubmenu:[[[NSMenu alloc] init] autorelease]];
            [menu addItem:item];
            [self _createMenuStructure:[item submenu] fromBookmarkTree:[bm subGroups] menuTarget:aTarget menuSelector:aSelector];
        }
    }
}

- (void)bookmarkDialog:(id)sender {    
    // create new bookmark instance
    Bookmark *new = [[[Bookmark alloc] init] autorelease];
    NSString *refText = [[hostingDelegate currentSearchText] searchTextForType:ReferenceSearchType];
    [new setReference:refText];
    [new setName:refText];
    
    // set as content
    [bmObjectController setContent:new];
    
    // bring up bookmark panel
    bookmarkAction = BookmarkMenuAddNewBM;
    NSWindow *window = [hostingDelegate window];
    [NSApp beginSheet:bookmarkDetailPanel
       modalForWindow:window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
          contextInfo:nil];
}

- (void)bookmarkDialogForVerseList:(NSArray *)aVerseList {
    Bookmark *new = [[[Bookmark alloc] init] autorelease];
    
    NSString *verseString = [aVerseList componentsJoinedByString:@";"];    
    [new setReference:verseString];
    [new setName:@""];
    
    [bmObjectController setContent:new];
    
    bookmarkAction = BookmarkMenuAddNewBM;
    NSWindow *window = [hostingDelegate window];
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
	CocoLog(LEVEL_DEBUG, @"[BookmarkManagerUIController -validateMenuItem:] %@", [menuItem description]);
    
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
        CocoLog(LEVEL_ERR, @"[BookmarkManagerUIController -validateMenuItem:] delegate and hostingDelegate are not available!");
    }
    
    return ret;
}

#pragma mark - Actions

- (IBAction)bookmarkMenuClicked:(id)sender {
	CocoLog(LEVEL_DEBUG, @"[BookmarkManagerUIController -menuClicked:] %@", [sender description]);
        
    Bookmark *clickedObj = (Bookmark *)[self delegateSelectedObject];
    int tag = [sender tag];
    bookmarkAction = tag;
    switch(tag) {
        case BookmarkMenuAddNewBM:
        {
            Bookmark *new = [[[Bookmark alloc] init] autorelease];
            // set as content
            [bmObjectController setContent:new];
            // bring up bookmark panel
            [bookmarkDetailPanel makeFirstResponder:bookmarkNameTextField];
            NSWindow *window = [hostingDelegate window];
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
            NSWindow *window = [hostingDelegate window];
            [NSApp beginSheet:bookmarkFolderWindow
               modalForWindow:window
                modalDelegate:self
               didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
                  contextInfo:nil];
            break;
        }
        case BookmarkMenuEditBM:
        {
            Bookmark *bm = clickedObj;
            if([bm isLeaf]) {
                // set as content
                [bmObjectController setContent:clickedObj];
                // bring up bookmark panel
                [bookmarkDetailPanel makeFirstResponder:bookmarkNameTextField];
                [bookmarkOkButton setEnabled:YES];
                NSWindow *window = [hostingDelegate window];
                [NSApp beginSheet:bookmarkDetailPanel 
                   modalForWindow:window 
                    modalDelegate:self 
                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
                      contextInfo:nil];                
            } else {
                bookmarkAction = BookmarkMenuEditBMFolder;
                [bookmarkFolderWindow makeFirstResponder:bookmarkFolderNameTextField];
                [bookmarkFolderNameTextField setStringValue:[bm name]];
                [bookmarkOkButton setEnabled:NO];
                NSWindow *window = [hostingDelegate window];
                [NSApp beginSheet:bookmarkFolderWindow
                   modalForWindow:window
                    modalDelegate:self
                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
                      contextInfo:nil];                
            }
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

    if(bookmarkAction == BookmarkMenuAddNewBMFolder) {
        // create new bookmark folder
        Bookmark *bm = [[[Bookmark alloc] initWithName:[bookmarkFolderNameTextField stringValue]] autorelease];
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
    } else {
        if([bookmarkSelection count] > 0) {
            Bookmark *selected = [bookmarkSelection objectAtIndex:0];
            if(selected != nil) {
                [selected setName:[bookmarkFolderNameTextField stringValue]];
            }
        }
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
