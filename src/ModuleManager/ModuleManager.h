//
//  ModuleManager.h
//  Eloquent
//
//  Created by Manfred Bergmann on 26.12.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ModuleManageViewController;

@interface ModuleManager : NSWindowController <NSToolbarDelegate> {

    // the module view controller
    ModuleManageViewController *moduleViewController;
    
    // delegate
    id delegate;
    
	// we need a dictionary for all our toolbar identifiers
	NSMutableDictionary *tbIdentifiers;
}

@property (assign, readwrite) id delegate;

- (id)initWithDelegate:(id)aDelegate;

- (void)setupToolbar;

@end
