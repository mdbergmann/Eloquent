//
//  SingleViewHostController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 16.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <HostableViewController.h>
#import <BibleCombiViewController.h>
#import <Indexer.h>
#import <SwordModule.h>

#define SINGLEVIEWHOST_NIBNAME   @"SingleViewHost"

@interface SingleViewHostController : NSWindowController <NSCoding> {
    IBOutlet NSBox *placeHolderView;
        
    HostableViewController *viewController;
    
	// we need a dictionary for all our toolbar identifiers
	NSMutableDictionary *tbIdentifiers;
    
    // the popup button
    NSPopUpButton *searchTypePopup;
    // selected search type
    SearchType searchType;
    // search text
    NSString *searchQuery;
}

// initializers
- (id)initForViewType:(ModuleType)aType;

// methods
- (NSView *)view;
- (void)setView:(NSView *)aView;

// method called by subview
- (void)contentViewInitFinished:(HostableViewController *)aView;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
