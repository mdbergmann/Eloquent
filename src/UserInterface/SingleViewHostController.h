//
//  SingleViewHostController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 16.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <Indexer.h>
#import <SwordModule.h>

#define SINGLEVIEWHOST_NIBNAME   @"SingleViewHost"

@class SearchOptionsViewController, HostableViewController;

@interface SingleViewHostController : NSWindowController <NSCoding> {
    
    // placeholder for the main content view
    IBOutlet NSBox *placeHolderView;
    // the main view for placeHolderView
    HostableViewController *viewController;

    // placeholder for the search options
    IBOutlet NSBox *placeHolderSearchOptionsView;
    
    // view controller for search options
    SearchOptionsViewController *searchOptionsViewController;
    NSSearchField *searchTextField;
    NSView *searchOptionsView;
    BOOL showingOptions;
    
	// we need a dictionary for all our toolbar identifiers
	NSMutableDictionary *tbIdentifiers;
    
    // the popup button
    NSPopUpButton *searchTypePopup;
    // selected search type
    SearchType searchType;
    // texts for search type
    NSMutableDictionary *searchTextsForTypes;
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
