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
#import <HostableViewController.h>
#import <ModuleViewController.h>
#import <ProtocolHelper.h>
#import <Indexer.h>

#define BIBLECOMBIVIEW_NIBNAME   @"BibleCombiView"

@class SwordModule, ScrollSynchronizableView;

@interface BibleCombiViewController : HostableViewController <NSCoding, TextDisplayable, SubviewHosting, MouseTracking> {
    // the lookup field
    IBOutlet NSTextField *lookupTF;
    IBOutlet NSButton *okBtn;
    
    IBOutlet NSSplitView *horiSplitView;
    IBOutlet NSSplitView *parBibleSplitView;
    
    NSMutableArray *parBibleViewControllers;
    
    // the current right ScrollSynchronizableView
    ScrollSynchronizableView *currentSyncView;
    
    // the regex that will find out the versekey
    MBRegex *regex;
    
    // search type
    SearchType searchType;
    // view search direction
    BOOL viewSearchDirRight;
}

// initializers
- (id)initWithDelegate:(id)aDelegate;

// methods
- (void)addNewBibleViewWithModule:(SwordModule *)aModule;

// method called by subview
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;

// protocol
- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType;

// view search delegate methods
- (void)viewSearchPrevious;
- (void)viewSearchNext;

// Mouse tracking protocol implementation
- (void)mouseEntered:(NSView *)theView;
- (void)mouseExited:(NSView *)theView;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
