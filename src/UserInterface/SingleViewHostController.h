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

@class SearchOptionsViewController;
@class HostableViewController;
@class ModuleOutlineViewController;

@interface SingleViewHostController : NSWindowController <NSCoding> {
    
    // splitView to add and remove modules view. splitview hosts placeHolderView
    IBOutlet NSSplitView *splitView;
    // default View
    IBOutlet NSView *defaultView;    
    // placeholder for the main content view
    IBOutlet NSBox *placeHolderView;
    // the main view for placeHolderView
    HostableViewController *viewController;

    // placeholder for the search options
    IBOutlet NSBox *placeHolderSearchOptionsView;
    
    // our delegate
    id delegate;
    
    // the type of view
    ModuleType type;
    
    // every host has a module list view
    ModuleOutlineViewController *modulesViewController;
    BOOL showingModules;
    
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
    // recent search arrays for search type
    NSMutableDictionary *recentSearchesForTypes;
}

@property (readwrite) id delegate;

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
