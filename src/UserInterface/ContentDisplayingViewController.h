//
//  ContentDisplayingViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 18.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HostableViewController.h>
#import <ProtocolHelper.h>

typedef enum _ContentViewType {
    SwordBibleContentType = 1,
    SwordCommentaryContentType,
    SwordDictionaryContentType,
    SwordGenBookContentType,
    SwordModuleContentType = 99,
    NoteContentType = 100,
}ContentViewType;

enum TextContextMenuItems {
    LookUpInIndexDefault = 100,
    LookUpInIndexList,
    LookUpInDictionaryDefault = 300,
    LookUpInDictionaryList
};

enum LinkContextMenuItems {
    OpenLink = 10,
    RemoveLink
};

@class CacheObject;

@interface ContentDisplayingViewController : HostableViewController <AccessoryViewProviding, ProgressIndicating, ContextMenuProviding, ContentSaving> {
    IBOutlet NSView *topAccessoryView;
    IBOutlet id contentDisplayController;    
    CacheObject *contentCache;
    
    // content context menues
    IBOutlet NSMenu *textContextMenu;
    IBOutlet NSMenu *linkContextMenu;
    IBOutlet NSMenu *imageContextMenu;
    
    // context menu clicked
    NSEvent *lastEvent;
    NSURL *contextMenuClickedLink;
    NSRange clickedLinkTextRange;

    BOOL forceRedisplay;
    SearchType searchType;
    NSString *reference;
}

@property (readwrite) BOOL forceRedisplay;
@property (readwrite) SearchType searchType;
@property (retain, readwrite) NSString *reference;
@property (retain, readwrite) NSEvent *lastEvent;
@property (retain, readwrite) CacheObject *contentCache;

// delegate method of ContentDisplayController, called for context menu selection
- (NSMenu *)menuForEvent:(NSEvent *)event;

// printing
- (NSView *)printViewForInfo:(NSPrintInfo *)printInfo;

// AccessoryViewProviding protocol
- (NSView *)topAccessoryView;
- (NSView *)rightAccessoryView;
- (void)adaptTopAccessoryViewComponentsForSearchType:(SearchType)aType;
- (BOOL)showsRightSideBar;

// ProgressIndicating
- (void)beginIndicateProgress;
- (void)endIndicateProgress;

// ContextMenuProviding
- (NSMenu *)textContextMenu;
- (NSMenu *)linkContextMenu;
- (NSMenu *)imageContextMenu;

// ContentSaving
- (BOOL)hasUnsavedContent;
- (void)saveContent;
- (IBAction)saveDocument:(id)sender;

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
