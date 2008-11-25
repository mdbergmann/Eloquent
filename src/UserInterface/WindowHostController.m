//
//  WindowHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 05.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WindowHostController.h"
#import "SearchTextObject.h"

@implementation WindowHostController

@synthesize delegate;
@synthesize searchType;
@synthesize currentSearchText;

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        // enable global options for testing
        //[[SwordManager defaultManager] setGlobalOption:SW_OPTION_STRONGS value:SW_ON];
        //[[SwordManager defaultManager] setGlobalOption:SW_OPTION_SCRIPTREFS value:SW_ON];
        
        [self setCurrentSearchText:[[SearchTextObject alloc] init]];
        
        showingOptions = NO;        
    }
    
    return self;
}

- (void)awakeFromNib {
    // set vertical splitview
    [splitView setVertical:YES];
    [splitView setDividerStyle:NSSplitViewDividerStyleThin];    

    // init toolbar identifiers
    tbIdentifiers = [[NSMutableDictionary alloc] init];
    
    NSToolbarItem *item = nil;
    NSImage *image = nil;
    
    // ----------------------------------------------------------------------------------------
    // toggle module list view
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_TOGGLE_MODULES_ITEM];
    [item setLabel:NSLocalizedString(@"ToggleModulesLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"ToggleModulesLabel", @"")];
    [item setToolTip:NSLocalizedString(@"ToggleModulesToolTip", @"")];
    image = [NSImage imageNamed:@"fifteenpieces.png"];
    [item setImage:image];
    [item setTarget:self];
    [item setAction:@selector(toggleModulesTB:)];
    [tbIdentifiers setObject:item forKey:TB_TOGGLE_MODULES_ITEM];
    
    if([self moduleType] == bible) {
        // add bibleview
        item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_ADD_BIBLE_ITEM];
        [item setLabel:NSLocalizedString(@"AddBibleLabel", @"")];
        [item setPaletteLabel:NSLocalizedString(@"AddBibleLabel", @"")];
        [item setToolTip:NSLocalizedString(@"AddBibleToolTip", @"")];
        image = [NSImage imageNamed:@"add.png"];
        [item setImage:image];
        [item setTarget:self];
        [item setAction:@selector(addBibleTB:)];
        [tbIdentifiers setObject:item forKey:TB_ADD_BIBLE_ITEM];
    }
    
    /*
     // search type
     searchTypePopup = [[NSPopUpButton alloc] init];
     [searchTypePopup setFrame:NSMakeRect(0,0,140,32)];
     [searchTypePopup setPullsDown:NO];
     //[[searchTypePopup cell] setUsesItemFromMenu:YES];
     // create menu
     NSMenu *searchTypeMenu = [[NSMenu alloc] init];
     NSMenuItem *mItem = [[NSMenuItem alloc] initWithTitle:@"Reference" action:@selector(searchType:) keyEquivalent:@""];
     [mItem setTag:ReferenceSearchType];
     [searchTypeMenu addItem:mItem];
     mItem = [[NSMenuItem alloc] initWithTitle:@"Index" action:@selector(searchType:) keyEquivalent:@""];
     [mItem setTag:IndexSearchType];
     [searchTypeMenu addItem:mItem];
     //    mItem = [[NSMenuItem alloc] initWithTitle:@"View" action:@selector(searchType:) keyEquivalent:@""];
     //    [mItem setTag:ViewSearchType];
     //    [searchTypeMenu addItem:mItem];
     [searchTypePopup setMenu:searchTypeMenu];
     [searchTypePopup selectItemWithTitle:@"Reference"];
     // item toolbaritem
     item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_SEARCH_TYPE_ITEM];
     [item setLabel:NSLocalizedString(@"SearchTypeLabel", @"")];
     [item setPaletteLabel:NSLocalizedString(@"SearchTypePalette", @"")];
     [item setToolTip:NSLocalizedString(@"SearchTypeTooltip", @"")];
     // use popUpButton as view
     [item setView:searchTypePopup];
     [item setMinSize:[searchTypePopup frame].size];
     [item setMaxSize:[searchTypePopup frame].size];
     // add toolbar item to dict
     [tbIdentifiers setObject:item forKey:TB_SEARCH_TYPE_ITEM];
     */
    
    float segmentControlHeight = 32.0;
    float segmentControlWidth = (2*64.0);
    NSSegmentedControl *segmentedControl = [[NSSegmentedControl alloc] init];
    [segmentedControl setFrame:NSMakeRect(0.0,0.0,segmentControlWidth,segmentControlHeight)];
    [segmentedControl setSegmentCount:2];
    // set tracking style
    [[segmentedControl cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
    // insert text only segments
    [segmentedControl setLabel:@"Ref" forSegment:0];
    //[segmentedControl setImage:[NSImage imageNamed:@"list"] forSegment:0];		
    [segmentedControl setLabel:@"Index" forSegment:1];
    //[segmentedControl setImage:[NSImage imageNamed:@"search"] forSegment:1];
    [[segmentedControl cell] setTag:ReferenceSearchType forSegment:0];
    [[segmentedControl cell] setTag:IndexSearchType forSegment:1];
    if([self moduleType] == genbook) {
        [[segmentedControl cell] setEnabled:NO forSegment:0];
        [[segmentedControl cell] setEnabled:YES forSegment:1];
        [[segmentedControl cell] setSelected:NO forSegment:0];
        [[segmentedControl cell] setSelected:YES forSegment:1];        
    } else {        
        [[segmentedControl cell] setEnabled:YES forSegment:0];
        [[segmentedControl cell] setEnabled:YES forSegment:1];
        [[segmentedControl cell] setSelected:YES forSegment:0];
        [[segmentedControl cell] setSelected:NO forSegment:1];
    }
    [segmentedControl sizeToFit];
    // resize the height to what we have defined
    [segmentedControl setFrameSize:NSMakeSize([segmentedControl frame].size.width,segmentControlHeight)];
    [segmentedControl setTarget:self];
    [segmentedControl setAction:@selector(searchType:)];
    
    // add detailview toolbaritem
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_SEARCH_TYPE_ITEM];
    [item setLabel:NSLocalizedString(@"SearchTypeLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"SearchTypePalette", @"")];
    [item setToolTip:NSLocalizedString(@"SearchTypeTooltip", @"")];
    [item setMinSize:[segmentedControl frame].size];
    [item setMaxSize:[segmentedControl frame].size];
    // set the segmented control as the view of the toolbar item
    [item setView:segmentedControl];
    [segmentedControl release];
    [tbIdentifiers setObject:item forKey:TB_SEARCH_TYPE_ITEM];
    
    // search text
    searchTextField = [[NSSearchField alloc] initWithFrame:NSMakeRect(0,0,350,32)];
    [searchTextField sizeToFit];
    [searchTextField setTarget:self];
    [searchTextField setAction:@selector(searchInput:)];
    if([self moduleType] == dictionary) {
        [searchTextField setContinuous:YES];
        [[searchTextField cell] setSendsSearchStringImmediately:YES];
        //[[searchTextField cell] setSendsWholeSearchString:NO];        
    } else {
        [searchTextField setContinuous:NO];
        [[searchTextField cell] setSendsSearchStringImmediately:NO];
        [[searchTextField cell] setSendsWholeSearchString:YES];        
    }
    // the item itself
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_SEARCH_TEXT_ITEM];
    [item setLabel:NSLocalizedString(@"TextSearchLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"TextSearchLabel", @"")];
    [item setToolTip:NSLocalizedString(@"TextSearchToolTip", @"")];
    [item setView:searchTextField];
    [item setMinSize:NSMakeSize(100, NSHeight([searchTextField frame]))];
    [item setMaxSize:NSMakeSize(350, NSHeight([searchTextField frame]))];
    [tbIdentifiers setObject:item forKey:TB_SEARCH_TEXT_ITEM];
    
    // add std items
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarFlexibleSpaceItemIdentifier];
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarSpaceItemIdentifier];
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarSeparatorItemIdentifier];
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarPrintItemIdentifier];
    
    [self setupToolbar];
    
    // activate mouse movement in subviews
    [[self window] setAcceptsMouseMovedEvents:YES];
}

#pragma mark - toolbar stuff

// ============================================================
// NSToolbar Related Methods
// ============================================================
/**
 \brief create a toolbar and add it to the window. Set the delegate to this object.
 */
- (void)setupToolbar {
    
    MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -setupToolbar]");
    
    // Create a new toolbar instance, and attach it to our document window 
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier: @"SingleViewHostToolbar"];
    
    // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults 
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
	//[toolbar setSizeMode:NSToolbarSizeModeRegular];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    
    // We are the delegate
    [toolbar setDelegate:self];
    
    // Attach the toolbar to the document window 
    [[self window] setToolbar:toolbar];
}

/**
 \brief returns array with allowed toolbar item identifiers
 */
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar  {
	return [tbIdentifiers allKeys];
}

/**
 \brief returns array with all default toolbar item identifiers
 */
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar  {
	NSArray *defaultItemArray = [NSArray arrayWithObjects:
                                 TB_ADD_BIBLE_ITEM,
                                 NSToolbarFlexibleSpaceItemIdentifier,
                                 TB_SEARCH_TYPE_ITEM,
                                 TB_SEARCH_TEXT_ITEM,
                                 NSToolbarFlexibleSpaceItemIdentifier,
                                 nil];
	
	return defaultItemArray;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar 
     itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag {
    NSToolbarItem *item = nil;
    
	item = [tbIdentifiers valueForKey:itemIdentifier];
	
    return item;
}

#pragma mark - toolbar actions

/** abstract method */
- (void)addBibleTB:(id)sender {
}

- (void)searchInput:(id)sender {
    // buffer search text string
    NSString *searchText = [sender stringValue];
    [currentSearchText setSearchText:searchText forSearchType:searchType];
    
    // add to recent searches
    NSMutableArray *recentSearches = [currentSearchText recentSearchsForType:searchType];
    [recentSearches addObject:searchText];
    // remove everything above 10 searches
    int len = [recentSearches count];
    if(len > 10) {
        [recentSearches removeObjectAtIndex:0];
    }
}

- (void)searchType:(id)sender {

    if([(NSSegmentedControl *)sender selectedSegment] == 0) {
        searchType = ReferenceSearchType;
    } else {
        searchType = IndexSearchType;
    }
    
    // set text according search type
    NSString *text = [currentSearchText searchTextForType:searchType];
    [searchTextField setStringValue:text];
    
    // switch recentSearches
    NSArray *recentSearches = [currentSearchText recentSearchsForType:searchType];
    [searchTextField setRecentSearches:recentSearches];
    
    // change searchfield behaviour for dictionary
    if([self moduleType] == dictionary || [self moduleType] == genbook) {
        if(searchType == ReferenceSearchType) {
            [searchTextField setContinuous:YES];
            [[searchTextField cell] setSendsSearchStringImmediately:YES];
            //[[searchTextField cell] setSendsWholeSearchString:NO];            
        } else {
            // <CR> required
            [searchTextField setContinuous:NO];
            [[searchTextField cell] setSendsSearchStringImmediately:NO];
            [[searchTextField cell] setSendsWholeSearchString:YES];            
        }
    }
}

#pragma mark - Methods

- (NSView *)view {
    return nil;
}

- (void)setView:(NSView *)aView {
}

/** used to set text to the search field from outside */
- (void)setSearchText:(NSString *)aString {
    [searchTextField setStringValue:aString];
    [self searchInput:searchTextField];
}

- (void)windowWillClose:(NSNotification *)notification {
    MBLOG(MBLOG_DEBUG, @"[WindowHostController -windowWillClose:]");
    // tell delegate that we are closing
    if(delegate && [delegate respondsToSelector:@selector(hostClosing:)]) {
        [delegate performSelector:@selector(hostClosing:) withObject:self];
    } else {
        MBLOG(MBLOG_WARN, @"[WindowHostController -windowWillClose:] delegate does not respond to selector!");
    }
}

#pragma mark - WindowHosting protocol

/** abstract method */
- (ModuleType)moduleType {
    return bible;
}

#pragma mark - SubviewHosting protocol

/** abstract method */
- (void)contentViewInitFinished:(HostableViewController *)aView {
}

/** abstract method */
- (void)removeSubview:(HostableViewController *)aViewController {
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {

    // decode searchtype
    self.searchType = [decoder decodeIntForKey:@"SearchTypeEncoded"];
    // decode searchQuery
    self.currentSearchText = [decoder decodeObjectForKey:@"SearchTextObject"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode searchType
    [encoder encodeInt:searchType forKey:@"SearchTypeEncoded"];
    // encode searchQuery
    [encoder encodeObject:currentSearchText forKey:@"SearchTextObject"];
    // encode window frame
    [encoder encodePoint:[[self window] frame].origin forKey:@"WindowOriginEncoded"];
    [encoder encodeSize:[[self window] frame].size forKey:@"WindowSizeEncoded"];
}

@end
