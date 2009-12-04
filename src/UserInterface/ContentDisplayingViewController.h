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

@interface ContentDisplayingViewController : HostableViewController <AccessoryViewProviding, ProgressIndicating> {
    IBOutlet NSView *topAccessoryView;
}

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

// convenience methods
- (void)hostingDelegateShowRightSideBar:(BOOL)aFlag;
- (ContentViewType)contentViewType;
- (BOOL)isSwordModuleContentType;
- (BOOL)isNoteContentType;

@end
