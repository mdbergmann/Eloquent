//
//  ModuleOutlineViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 08.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <HostableViewController.h>

#define MODULEOUTLINEVIEW_NIBNAME   @"ModuleOutlineView"

@class SwordManager;

@interface ModuleOutlineViewController : HostableViewController {
    IBOutlet NSOutlineView *moduleOutlineView;
    IBOutlet NSMenu *moduleMenu;
    
    // the SwordManager instance
    SwordManager *manager;
    
    // the data structure that holds the outline view items
    NSMutableArray *data;
}

@property (readwrite) SwordManager *manager;

// initialitazion
- (id)initWithDelegate:(id)aDelegate;

// module menu
//--------------------------------------------------------------------
//----------- NSMenu validation --------------------------------
//--------------------------------------------------------------------
/**
 \brief validate menu
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem;
- (IBAction)moduleMenuClicked:(id)sender;

@end
