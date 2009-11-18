//
//  BibleCombiViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <CocoPCRE/CocoPCRE.h>
#import <ModuleCommonsViewController.h>
#import <ModuleViewController.h>
#import <ProtocolHelper.h>
#import <Indexer.h>

#define BIBLECOMBIVIEW_NIBNAME   @"BibleCombiView"

@class SwordModule, SwordBible, SwordCommentary, ScrollSynchronizableView;

@interface BibleCombiViewController : ModuleCommonsViewController <NSCoding, ModuleProviding, SubviewHosting> {
    // the lookup field
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
    
    // the regex that will find out the versekey
    MBRegex *regex;
        
    // progressAction
    BOOL progressControl;
    int progressStartedCounter;
}

// initializers
- (id)initWithDelegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate andInitialModule:(SwordBible *)aBible;

// methods
- (void)addNewBibleViewWithModule:(SwordBible *)aModule;
- (void)addNewCommentViewWithModule:(SwordCommentary *)aModule;
- (NSArray *)openBibleModules;
- (NSArray *)openMiscModules;
- (NSNumber *)bibleViewCount;

// ModuleProviding
- (SwordModule *)module;

// SubviewHosting
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
