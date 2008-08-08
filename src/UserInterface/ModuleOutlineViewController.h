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

@interface ModuleOutlineViewController : HostableViewController {
    IBOutlet NSOutlineView *moduleOutlineView;
}

// initialitazion
- (id)initWithDelegate:(id)aDelegate;

@end
