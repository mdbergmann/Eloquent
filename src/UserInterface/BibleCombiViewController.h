//
//  BibleCombiViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProtocolHelper.h"
#import "ModuleCommonsViewController.h"

#define BIBLECOMBIVIEW_NIBNAME   @"BibleCombiView"

@class SwordModule, SwordBible, SwordCommentary, ScrollSynchronizableView;

@interface BibleCombiViewController : ModuleCommonsViewController <NSCoding, ModuleProviding, SubviewHosting> {
    IBOutlet NSTextField *lookupTF;
    IBOutlet NSButton *okBtn;
    
    IBOutlet NSSplitView *horiSplitView;
    IBOutlet NSSplitView *parBibleSplitView;
    IBOutlet NSSplitView *parMiscSplitView;
        
    NSMutableArray *parBibleViewControllers;
    NSMutableArray *parMiscViewControllers;
    
    // default width parMiscSplitView
    float defaultMiscViewHeight;
    
    // the current right ScrollSynchronizableView
    ScrollSynchronizableView *currentSyncView;
    
    // progressAction
    BOOL progressControl;
    int progressStartedCounter;
}

// initializers
- (id)initWithDelegate:(id)aDelegate;
- (id)initWithModule:(SwordBible *)aBible delegate:(id)aDelegate;

// methods
- (void)addNewBibleViewWithModule:(SwordBible *)aModule;
- (void)addNewCommentViewWithModule:(SwordCommentary *)aModule;
- (NSArray *)openBibleModules;
- (NSArray *)openMiscModules;
- (NSNumber *)bibleViewCount;

// ModuleProviding
- (SwordModule *)module;

// SubviewHosting
- (void)addContentViewController:(ContentDisplayingViewController *)aViewController;
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;

@end
