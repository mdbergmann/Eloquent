//
//  WindowHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 05.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WindowHostController.h"
#import "AppController.h"
#import "SearchTextObject.h"
#import "LeftSideBarViewController.h"
#import "RightSideBarViewController.h"
#import "SwordManager.h"

@implementation WindowHostController

@synthesize delegate;
@synthesize searchType;
@synthesize currentSearchText;

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        // enable global options for testing
        [[SwordManager defaultManager] setGlobalOption:SW_OPTION_STRONGS value:SW_ON];
        [[SwordManager defaultManager] setGlobalOption:SW_OPTION_SCRIPTREFS value:SW_ON];
        [[SwordManager defaultManager] setGlobalOption:SW_OPTION_FOOTNOTES value:SW_ON];
        
        [self setCurrentSearchText:[[SearchTextObject alloc] init]];

        // load leftSideBar
        lsbWidth = 200;
        lsbViewController = [[LeftSideBarViewController alloc] initWithDelegate:self];
        [lsbViewController setHostingDelegate:self];
        showingLSB = NO;

        // load rightSideBar
        rsbWidth = 200;
        rsbViewController = [[RightSideBarViewController alloc] initWithDelegate:self];
        [rsbViewController setHostingDelegate:self];
        showingRSB = NO;
    }
    
    return self;
}

- (void)awakeFromNib {
    // set main split vertical
    [mainSplitView setVertical:YES];
    [mainSplitView setDividerStyle:NSSplitViewDividerStyleThin];

    // set content split vertical
    [contentSplitView setVertical:YES];
    [contentSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    
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
    image = [NSImage imageNamed:@"agt_add-to-autorun.png"];
    [item setImage:image];
    [item setTarget:self];
    [item setAction:@selector(toggleModulesTB:)];
    [tbIdentifiers setObject:item forKey:TB_TOGGLE_MODULES_ITEM];
    
    /*
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
     */
    
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
    searchTypeSegControl = [[NSSegmentedControl alloc] init];
    [searchTypeSegControl setFrame:NSMakeRect(0.0,0.0,segmentControlWidth,segmentControlHeight)];
    [searchTypeSegControl setSegmentCount:2];
    // style
    [[searchTypeSegControl cell] setSegmentStyle:NSSegmentStyleTexturedRounded];
    // set tracking style
    [[searchTypeSegControl cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
    // insert text only segments
    [searchTypeSegControl setLabel:NSLocalizedString(@"Reference", @"") forSegment:0];
    //[searchTypeSegControl setImage:[NSImage imageNamed:@"list"] forSegment:0];		
    [searchTypeSegControl setLabel:NSLocalizedString(@"Index", "") forSegment:1];
    //[searchTypeSegControl setImage:[NSImage imageNamed:@"search"] forSegment:1];
    [[searchTypeSegControl cell] setTag:ReferenceSearchType forSegment:0];
    [[searchTypeSegControl cell] setTag:IndexSearchType forSegment:1];
    if([self moduleType] == genbook) {
        [[searchTypeSegControl cell] setEnabled:NO forSegment:0];
        [[searchTypeSegControl cell] setEnabled:YES forSegment:1];
        [[searchTypeSegControl cell] setSelected:NO forSegment:0];
        [[searchTypeSegControl cell] setSelected:YES forSegment:1];        
    } else {        
        [[searchTypeSegControl cell] setEnabled:YES forSegment:0];
        [[searchTypeSegControl cell] setEnabled:YES forSegment:1];
        [[searchTypeSegControl cell] setSelected:YES forSegment:0];
        [[searchTypeSegControl cell] setSelected:NO forSegment:1];
    }
    [searchTypeSegControl sizeToFit];
    // resize the height to what we have defined
    [searchTypeSegControl setFrameSize:NSMakeSize([searchTypeSegControl frame].size.width,segmentControlHeight)];
    [searchTypeSegControl setTarget:self];
    [searchTypeSegControl setAction:@selector(searchType:)];
    
    // add detailview toolbaritem
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_SEARCH_TYPE_ITEM];
    [item setLabel:NSLocalizedString(@"SearchTypeLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"SearchTypePalette", @"")];
    [item setToolTip:NSLocalizedString(@"SearchTypeTooltip", @"")];
    [item setMinSize:[searchTypeSegControl frame].size];
    [item setMaxSize:[searchTypeSegControl frame].size];
    // set the segmented control as the view of the toolbar item
    [item setView:searchTypeSegControl];
    [searchTypeSegControl release];
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
    [item setToolTip:NSLocalizedString(@"TextSearchTooltip", @"")];
    [item setView:searchTextField];
    [item setMinSize:NSMakeSize(100, NSHeight([searchTextField frame]))];
    [item setMaxSize:NSMakeSize(350, NSHeight([searchTextField frame]))];
    [tbIdentifiers setObject:item forKey:TB_SEARCH_TEXT_ITEM];
    
    // add button
    
    // module installer item
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_MODULEINSTALLER_ITEM];
    [item setLabel:NSLocalizedString(@"ModuleInstallerLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"ModuleInstallerLabel", @"")];
    [item setToolTip:NSLocalizedString(@"ModuleInstallerTooltip", @"")];
    image = [NSImage imageNamed:@"ModuleManager.png"];
    [item setImage:image];
    [item setTarget:[AppController defaultAppController]];
    [item setAction:@selector(showModuleManager:)];
    [tbIdentifiers setObject:item forKey:TB_MODULEINSTALLER_ITEM];
    
    // add std items
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarFlexibleSpaceItemIdentifier];
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarSpaceItemIdentifier];
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarSeparatorItemIdentifier];
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarPrintItemIdentifier];
    
    [self setupToolbar];
    
    // activate mouse movement in subviews
    [[self window] setAcceptsMouseMovedEvents:YES];
    // set window status bar
	[self.window setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
	[self.window setContentBorderThickness:30.0f forEdge:NSMinYEdge];
    
    // set up left and right side bar
    if([lsbViewController viewLoaded]) {
        [mainSplitView addSubview:[lsbViewController view] positioned:NSWindowBelow relativeTo:nil];
    }
    if([rsbViewController viewLoaded]) {
        [contentSplitView addSubview:[rsbViewController view] positioned:NSWindowAbove relativeTo:nil];
    }    
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
                                 TB_TOGGLE_MODULES_ITEM,
                                 NSToolbarFlexibleSpaceItemIdentifier,
                                 TB_SEARCH_TYPE_ITEM,
                                 TB_SEARCH_TEXT_ITEM,
                                 NSToolbarFlexibleSpaceItemIdentifier,
                                 TB_MODULEINSTALLER_ITEM,
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

- (void)addBibleTB:(id)sender {
}

- (void)toggleModulesTB:(id)sender {
    if(showingLSB) {
        [self hideLeftSideBar];
    } else {
        [self showLeftSideBar];
    }
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
    return view;
}

- (void)setView:(NSView *)aView {
    view = aView;
}

- (void)showLeftSideBar {
    if(!showingLSB) {
        // change size of view
        NSView *v = [lsbViewController view];
        NSSize size = [v frame].size;
        size.width = lsbWidth;
        [[v animator] setFrameSize:size];
        
        showingLSB = YES;
    }
}

- (void)hideLeftSideBar {
    if(showingLSB) {
        // shrink the view
        NSView *v = [lsbViewController view];
        NSSize size = [v frame].size;
        lsbWidth = size.width;
        size.width = 0;
        [[v animator] setFrameSize:size];
        
        showingLSB = NO;
    }
}

- (void)showRightSideBar {
    if(!showingRSB) {
        // change size of view
        NSView *v = [rsbViewController view];
        NSSize size = [v frame].size;
        size.width = rsbWidth;
        [[v animator] setFrameSize:size];
        
        showingRSB = YES;
    }    
}

- (void)hideRightSideBar {
    if(showingRSB) {
        // shrink the view
        NSView *v = [rsbViewController view];
        NSSize size = [v frame].size;
        rsbWidth = size.width;
        size.width = 0;
        [[v animator] setFrameSize:size];
        
        showingRSB = NO;
    }    
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

- (void)adaptUIToCurrentlyDisplayingModuleType {
    
    ModuleType type = [self moduleType];
    if(type == dictionary) {
        [searchTextField setContinuous:YES];
        [[searchTextField cell] setSendsSearchStringImmediately:YES];
        //[[searchTextField cell] setSendsWholeSearchString:NO];        
    } else {
        [searchTextField setContinuous:NO];
        [[searchTextField cell] setSendsSearchStringImmediately:NO];
        [[searchTextField cell] setSendsWholeSearchString:YES];        
    }
    
    if(type == genbook) {
        [[searchTypeSegControl cell] setEnabled:NO forSegment:0];
        [[searchTypeSegControl cell] setEnabled:YES forSegment:1];
        [[searchTypeSegControl cell] setSelected:NO forSegment:0];
        [[searchTypeSegControl cell] setSelected:YES forSegment:1];        
    } else {        
        [[searchTypeSegControl cell] setEnabled:YES forSegment:0];
        [[searchTypeSegControl cell] setEnabled:YES forSegment:1];
        [[searchTypeSegControl cell] setSelected:YES forSegment:0];
        [[searchTypeSegControl cell] setSelected:NO forSegment:1];
    }    
}

#pragma mark - WindowHosting protocol

/** abstract method */
- (ModuleType)moduleType {
    return bible;   // default is bible
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOG(MBLOG_DEBUG, @"[WindowHostController -contentViewInitFinished:]");

    if([aView isKindOfClass:[LeftSideBarViewController class]]) {
        [mainSplitView addSubview:[aView view] positioned:NSWindowBelow relativeTo:placeHolderView];
    } else if([aView isKindOfClass:[RightSideBarViewController class]]) {
        [contentSplitView addSubview:[aView view] positioned:NSWindowAbove relativeTo:nil];
    }    
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [[aViewController view] removeFromSuperview];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {

    // decode searchtype
    self.searchType = [decoder decodeIntForKey:@"SearchTypeEncoded"];
    // decode searchQuery
    self.currentSearchText = [decoder decodeObjectForKey:@"SearchTextObject"];
    // load lsb view
    lsbViewController = [[LeftSideBarViewController alloc] initWithDelegate:self];
    [lsbViewController setHostingDelegate:self];
    showingLSB = NO;    
    // load rsb view
    rsbViewController = [[RightSideBarViewController alloc] initWithDelegate:self];
    [rsbViewController setHostingDelegate:self];
    showingRSB = NO;    
    
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
