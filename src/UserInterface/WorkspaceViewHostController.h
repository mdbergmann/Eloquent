//
//  WorkspaceViewHostController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 06.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WindowHostController.h>
#import <Indexer.h>
#import <SwordModule.h>
#import <ProtocolHelper.h>

#define WORKSPACEVIEWHOST_NIBNAME   @"WorkspaceViewHost"

@class HostableViewController;
@class SwordModule;

@interface WorkspaceViewHostController : WindowHostController <NSCoding, SubviewHosting, WindowHosting> {

    /** the view switcher */
    IBOutlet NSSegmentedControl *tabControl;
    /** each segment should have this menu */
    IBOutlet NSMenu *segmentMenu;

    /** one view controller for each tab */
    NSMutableArray *viewControllers;
        
    /** the current selected view contoller */
    HostableViewController *activeViewController;
    
    /** array of search text objects */
    NSMutableArray *searchTextObjs;
}

// methods
- (NSView *)view;
- (void)setView:(NSView *)aView;
- (HostableViewController *)contentViewController;
- (void)addTabContentForModule:(SwordModule *)aModule;
- (void)addTabContentForModuleType:(ModuleType)aType;

// actions
- (IBAction)segmentButtonChange:(id)sender;
- (IBAction)menuItemSelected:(id)sender;

// WindowHosting
- (ModuleType)moduleType;

// SubviewHosting
- (void)contentViewInitFinished:(HostableViewController *)aView;
- (void)removeSubview:(HostableViewController *)aViewController;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
