//
//  GenBookViewController.h
//  MacSword
//
//  Created by Manfred Bergmann on 25.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <CocoPCRE/CocoPCRE.h>
#import <HostableViewController.h>
#import <ModuleViewController.h>
#import <ProtocolHelper.h>

@class SwordBook, ExtTextViewController;

#define GENBOOKVIEW_NIBNAME   @"GenBookView"

/** the view of this view controller is a ScrollSynchronizableView */
@interface GenBookViewController : ModuleViewController <NSCoding, TextDisplayable, SubviewHosting> {
    // module popup button
    IBOutlet NSPopUpButton *modulePopBtn;
    // status line
    IBOutlet NSTextField *statusLine;
    // the outlineview view for the dictionary items
    IBOutlet NSOutlineView *entriesOutlineView;
    
    NSMutableArray *selection;
}

// ---------- initializers ---------
- (id)initWithModule:(SwordBook *)aModule;
- (id)initWithModule:(SwordBook *)aModule delegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate;

// ---------- methods --------------

// the outline view of the genbook content
- (NSView *)listContentView;

// method called by subview
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;
- (void)adaptUIToHost;
- (void)setStatusText:(NSString *)aText;

// protocol definitions
- (void)displayTextForReference:(NSString *)aReference;
- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType;

// selector called by menuitems
- (void)moduleSelectionChanged:(id)sender;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

// actions
- (IBAction)moduleSelectionChanged:(id)sender;

@end
