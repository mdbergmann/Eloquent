//
//  SingleViewHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 16.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SingleViewHostController.h"
#import "BibleCombiViewController.h"
#import "SwordModule.h"

// toolbar identifiers
#define TB_ADD_BIBLE_ITEM       @"IdAddBible"
#define TB_SEARCH_TYPE_ITEM     @"IdSearchType"
#define TB_SEARCH_TEXT_ITEM     @"IdSearchText"

@interface SingleViewHostController (/* */)
- (void)setupToolbar;
@end

@implementation SingleViewHostController

#pragma mark - getter/setter

- (NSView *)view {
    return [placeHolderView contentView];
}

- (void)setView:(NSView *)aView {
    [placeHolderView setContentView:aView];
}

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -init] loading nib");
        // load nib
        BOOL stat = [NSBundle loadNibNamed:SINGLEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SingleViewHostController -init] unable to load nib!");
        }
    }
    
    return self;
}

- (id)initForViewType:(ModuleType)aType {
    self = [self init];
    if(self) {
        if(aType == bible) {
            viewController = [[BibleCombiViewController alloc] initWithDelegate:self];
            searchType = ReferenceSearchType;
        }
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -awakeFromNib]");
    // check if view has loaded
    if(viewController.viewLoaded == YES) {
        // add content view
        [placeHolderView setContentView:[viewController view]];
    }

    // init toolbar identifiers
    tbIdentifiers = [[NSMutableDictionary alloc] init];
    
    NSToolbarItem *item = nil;
    NSImage *image = nil;
    
    // ----------------------------------------------------------------------------------------
    // add is
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_ADD_BIBLE_ITEM];
    [item setLabel:NSLocalizedString(@"AddBibleLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"AddBibleLabel", @"")];
    [item setToolTip:NSLocalizedString(@"AddBibleToolTip", @"")];
    image = [NSImage imageNamed:@"add.png"];
    [item setImage:image];
    [item setTarget:self];
    [item setAction:@selector(addBibleTB:)];
    [tbIdentifiers setObject:item forKey:TB_ADD_BIBLE_ITEM];

    // ---------------------------------------------------------------------------------------
    // search type
    NSPopUpButton *searchTypePopup = [[NSPopUpButton alloc] init];
    [searchTypePopup setFrame:NSMakeRect(0,0,140,32)];
    [searchTypePopup setPullsDown:NO];
    //[[searchTypePopup cell] setUsesItemFromMenu:YES];
    // create menu
    NSMenu *searchTypeMenu = [[NSMenu alloc] init];
    NSMenuItem *mItem = [[NSMenuItem alloc] initWithTitle:@"Reference" action:@selector(searchType:) keyEquivalent:@""];
    [mItem setTag:ReferenceSearchType];
    [searchTypeMenu addItem:mItem];
    mItem = [[NSMenuItem alloc] initWithTitle:@"Word" action:@selector(searchType:) keyEquivalent:@""];
    [mItem setTag:WordSearchType];
    [searchTypeMenu addItem:mItem];
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
    
    // search text
    NSSearchField *searchField = [[NSSearchField alloc] initWithFrame:NSMakeRect(0,0,350,32)];
    [searchField sizeToFit];
    [searchField setTarget:self];
    [searchField setAction:@selector(searchInput:)];
    [searchField setContinuous:NO];
    [searchField sendActionOn:0];
    // the item itself
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_SEARCH_TEXT_ITEM];
    [item setLabel:NSLocalizedString(@"TextSearchLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"TextSearchLabel", @"")];
    [item setToolTip:NSLocalizedString(@"TextSearchToolTip", @"")];
    [item setView:searchField];
    [item setMinSize:NSMakeSize(100,NSHeight([searchField frame]))];
    [item setMaxSize:NSMakeSize(350,NSHeight([searchField frame]))];
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

- (void)addBibleTB:(id)sender {
    if([viewController isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)viewController addNewBibleViewWithModule:nil];
    }
}

- (void)searchInput:(id)sender {
    MBLOGV(MBLOG_DEBUG, @"search input: %@", [sender stringValue]);
    
    if([viewController isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)viewController displayTextForReference:[sender stringValue] searchType:searchType];
    }
}

- (void)searchType:(id)sender {
    MBLOGV(MBLOG_DEBUG, @"search type: %@", [sender title]);
    
    searchType = [sender tag];
}
     
#pragma mark - delegate methods

- (void)contentViewInitFinished:(HostableViewController *)aView {    
    MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -contentViewInitFinished:]");
    // add the webview as contentvew to the placeholder
    [placeHolderView setContentView:[aView view]];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if(self) {
        // decode viewController
        viewController = [decoder decodeObjectForKey:@"HostableViewControllerEncoded"];
        // set delegate
        [viewController setDelegate:self];
        // decode searchtype
        searchType = [decoder decodeIntForKey:@"SearchTypeEncoded"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode hostableviewcontroller
    [encoder encodeObject:viewController forKey:@"HostableViewControllerEncoded"];
    // encode searchType
    [encoder encodeInt:searchType forKey:@"SearchTypeEncoded"];
}

@end
