//
//  GenBookViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 25.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ModuleViewController.h"

@class SwordBook;

#define GENBOOKVIEW_NIBNAME   @"GenBookView"

/** the view of this view controller is a ScrollSynchronizableView */
@interface GenBookViewController : ModuleViewController <NSCoding, NSOutlineViewDataSource, NSOutlineViewDelegate> {
    IBOutlet NSPopUpButton *modulePopBtn;
    IBOutlet NSOutlineView *entriesOutlineView;
}

// ---------- initializers ---------
- (id)initWithModule:(SwordBook *)aModule;
- (id)initWithModule:(SwordBook *)aModule delegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
