//
//  ModuleManager.h
//  Eloquent
//
//  Created by Manfred Bergmann on 26.12.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <ModuleManageViewController.h>

@interface ModuleManager : NSWindowController {
    
    // the module view controller
    ModuleManageViewController *moduleViewController;
    
	// we need a dictionary for all our toolbar identifiers
	NSMutableDictionary *tbIdentifiers;
}

- (void)setupToolbar;

@end
