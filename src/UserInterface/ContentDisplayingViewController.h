//
//  ContentDisplayingViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 18.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HostableViewController.h"

typedef enum _ContentViewType {
    SwordBibleContentType = 1,
    SwordCommentaryContentType,
    SwordDictionaryContentType,
    SwordGenBookContentType,
    SwordModuleContentType = 99,
    NoteContentType = 100,
}ContentViewType;

enum TextContextMenuItems {
    AddBookmark = 90,
    AddVersesToBookmark = 91,
    LookUpInIndexDefault = 100,
    LookUpInIndexList,
    LookUpInDictionaryDefault = 300,
    LookUpInDictionaryList
};

enum LinkContextMenuItems {
    OpenLink = 10,
    RemoveLink
};

typedef enum _ProgressActionType {
    ReferenceLookupAction,
    IndexSearchAction,
    IndexCreateAction
}ProgressActionType;

@class CacheObject;
@class ModulesUIController;
@class ProgressOverlayViewController;

@interface ContentDisplayingViewController : HostableViewController <ProgressIndicating, TextDisplayable, ContextMenuProviding> {
    IBOutlet NSView *topAccessoryView;
    IBOutlet id contentDisplayController;    
    CacheObject *contentCache;
    
    ProgressOverlayViewController *progressController;
    ProgressActionType progressActionType;
    
    // content context menues
    IBOutlet NSMenu *textContextMenu;
    IBOutlet NSMenu *linkContextMenu;
    IBOutlet NSMenu *imageContextMenu;
    
    // context menu clicked
    NSEvent *lastEvent;
    NSURL *contextMenuClickedLink;
    NSRange clickedLinkTextRange;

    BOOL forceRedisplay;
}

@property (readwrite) BOOL forceRedisplay;
@property (retain, readwrite) NSEvent *lastEvent;
@property (retain, readwrite) CacheObject *contentCache;
@property (readonly) ProgressOverlayViewController *progressController;
@property (readwrite) ProgressActionType progressActionType;

- (void)commonInit;

- (ModulesUIController *)modulesUIController;

// delegate method of ContentDisplayController, called for context menu selection
- (NSMenu *)menuForEvent:(NSEvent *)event;

// printing
- (NSView *)printViewForInfo:(NSPrintInfo *)printInfo;

// Clicked links
- (BOOL)linkClicked:(id)link;
- (NSString *)processPreviewDisplay:(NSURL *)aUrl;

// ProgressIndicating
- (void)beginIndicateProgress;
- (void)endIndicateProgress;

- (id)progressIndicator;
- (void)setProgressActionType:(ProgressActionType)aType;
- (ProgressActionType)progressActionType;
- (void)putProgressOverlayView;
- (void)removeProgressOverlayView;

- (IBAction)saveDocument:(id)sender;

// ContextMenuProviding
- (NSMenu *)textContextMenu;
- (NSMenu *)linkContextMenu;
- (NSMenu *)imageContextMenu;

// TextDisplayable
- (void)displayText;
- (void)displayTextForReference:(NSString *)aReference;
- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType;

// context menu actions
- (IBAction)lookUpInIndex:(id)sender;
- (IBAction)lookUpInIndexOfBible:(id)sender;
- (IBAction)lookUpInDictionary:(id)sender;
- (IBAction)lookUpInDictionaryOfModule:(id)sender;
- (IBAction)openLink:(id)sender;
- (IBAction)removeLink:(id)sender;

// convenience methods
- (void)hostingDelegateShowRightSideBar:(BOOL)aFlag;
- (ContentViewType)contentViewType;
- (BOOL)isSwordModuleContentType;
- (BOOL)isNoteContentType;

@end
