//
//  WindowHostController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 05.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ProtocolHelper.h>
#import <Indexer.h>

// toolbar identifiers
#define TB_ADD_BIBLE_ITEM       @"IdAddBible"
#define TB_TOGGLE_MODULES_ITEM  @"IdToggleModules"
#define TB_SEARCH_TYPE_ITEM     @"IdSearchType"
#define TB_SEARCH_TEXT_ITEM     @"IdSearchText"

@class SearchTextObject;

@interface WindowHostController : NSWindowController <NSCoding, SubviewHosting, WindowHosting> {
    // splitView to add and remove modules view. splitview hosts placeHolderView
    IBOutlet NSSplitView *splitView;
    // default View
    IBOutlet NSView *defaultView;    
    // placeholder for the main content view
    IBOutlet NSBox *placeHolderView;
    // placeholder for the search options
    IBOutlet NSBox *placeHolderSearchOptionsView;
    
    // our delegate
    id delegate;

    NSSearchField *searchTextField;
    NSView *searchOptionsView;
    BOOL showingOptions;
    
	// we need a dictionary for all our toolbar identifiers
	NSMutableDictionary *tbIdentifiers;

    // selected search type
    SearchType searchType;
    // the search text helper object
    SearchTextObject *currentSearchText;
}

@property (readwrite) id delegate;
@property (readwrite) SearchType searchType;
@property (retain, readwrite) SearchTextObject *currentSearchText;

// methods
- (NSView *)view;
- (void)setView:(NSView *)aView;

- (void)setupToolbar;

/** sets the text string into the search text field */
- (void)setSearchText:(NSString *)aString;

/** action of any input to the search text field */
- (void)searchInput:(id)sender;

// WindowHosting
- (ModuleType)moduleType;

// SubviewHosting
- (void)contentViewInitFinished:(HostableViewController *)aView;
- (void)removeSubview:(HostableViewController *)aViewController;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
