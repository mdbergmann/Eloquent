//
//  SingleViewHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 16.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SingleViewHostController.h"
#import "BibleCombiViewController.h"
#import "HostableViewController.h"
#import "SearchOptionsViewController.h"
#import "BibleSearchOptionsViewController.h"
#import "SwordManager.h"
#import "SwordModule.h"

// toolbar identifiers
#define TB_ADD_BIBLE_ITEM       @"IdAddBible"
#define TB_SEARCH_TYPE_ITEM     @"IdSearchType"
#define TB_SEARCH_TEXT_ITEM     @"IdSearchText"

@interface SingleViewHostController (/* */)
- (void)setupToolbar;
- (void)showSearchOptionsView:(BOOL)flag;
- (NSString *)searchTextForType:(SearchType)aType;
- (void)setSearchText:(NSString *)aText forSearchType:(SearchType)aType;

@property (retain, readwrite) NSMutableDictionary *searchTextsForTypes;
@property (readwrite) SearchType searchType;

@end

@implementation SingleViewHostController

#pragma mark - getter/setter

@synthesize delegate;
@synthesize searchTextsForTypes;
@synthesize searchType;

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
        
        // enable global options for testing
        [[SwordManager defaultManager] setGlobalOption:SW_OPTION_STRONGS value:SW_ON];
        [[SwordManager defaultManager] setGlobalOption:SW_OPTION_SCRIPTREFS value:SW_ON];
        
        self.searchTextsForTypes = [NSMutableDictionary dictionary];
        showingOptions = NO;
        
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
            
            // init search view controller
            searchOptionsViewController = [[BibleSearchOptionsViewController alloc] initWithDelegate:self andTarget:viewController];
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

    // check for options view loaded
    if(searchOptionsViewController.viewLoaded == YES) {
        // add to placeholder
        [placeHolderSearchOptionsView setContentView:[searchOptionsViewController optionsViewForSearchType:searchType]];
        // set 0 height for place holder at first
        NSSize s = [placeHolderSearchOptionsView frame].size;
        [placeHolderSearchOptionsView setFrameSize:NSMakeSize(s.width, 0)];
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
    mItem = [[NSMenuItem alloc] initWithTitle:@"View" action:@selector(searchType:) keyEquivalent:@""];
    [mItem setTag:ViewSearchType];
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
    searchTextField = [[NSSearchField alloc] initWithFrame:NSMakeRect(0,0,350,32)];
    [searchTextField sizeToFit];
    [searchTextField setTarget:self];
    [searchTextField setAction:@selector(searchInput:)];
    [searchTextField setContinuous:NO];
    [[searchTextField cell] setSendsSearchStringImmediately:NO];
    [[searchTextField cell] setSendsActionOnEndEditing:YES];
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
    
    // if a reference is stored, we should load it
    NSString *referenceText = [self searchTextForType:ReferenceSearchType];
    if([referenceText length] > 0) {
        if([viewController isKindOfClass:[BibleCombiViewController class]]) {
            [(BibleCombiViewController *)viewController displayTextForReference:referenceText searchType:ReferenceSearchType];
        }
    }
    
    // This is the last selected search type and the text for it
    NSString *currentSearchText = [self searchTextForType:searchType];
    if([currentSearchText length] > 0) {
        [searchTextField setStringValue:currentSearchText];
        [searchTypePopup selectItemWithTag:searchType];
        if([viewController isKindOfClass:[BibleCombiViewController class]]) {
            [(BibleCombiViewController *)viewController displayTextForReference:currentSearchText searchType:searchType];
        }
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
    
    NSString *searchText = [sender stringValue];
    [self setSearchText:searchText forSearchType:searchType];
    
    if([viewController isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)viewController displayTextForReference:searchText searchType:searchType];
    }
}

- (void)searchType:(id)sender {
    MBLOGV(MBLOG_DEBUG, @"search type: %@", [sender title]);
    
    searchType = [sender tag];
    
    // set text according search type
    NSString *text = [self searchTextForType:searchType];
    [searchTextField setStringValue:text];
    
    // if search type is view then show search options
    // else hide
    if(searchType == ViewSearchType) {
        [self showSearchOptionsView:YES];
        showingOptions = YES;
    } else {
        //[searchOptionsView removeFromSuperview];
        [self showSearchOptionsView:NO];
        showingOptions = NO;
    }
}

#pragma mark - methods

- (void)showSearchOptionsView:(BOOL)flag {
    
    if(showingOptions != flag) {
        float fullHeight = [[[self window] contentView] frame].size.height;
        //float fullWidth = [[[self window] contentView] frame].size.width;

        // set frame size of placeholder box according to view
        searchOptionsView = [searchOptionsViewController optionsViewForSearchType:searchType];
        [placeHolderSearchOptionsView setContentView:searchOptionsView];
        NSSize viewSize = [searchOptionsViewController optionsViewSizeForSearchType:searchType];
        
        if(searchOptionsView != nil) {
            float margin = 25;
            float optionsBoxHeight = viewSize.height + 5;
            NSSize newSize = NSMakeSize([placeHolderSearchOptionsView frame].size.width, optionsBoxHeight);
            [placeHolderSearchOptionsView setFrameSize:newSize];
            //[searchOptionsView setFrameSize:NSMakeSize([placeHolderSearchOptionsView frame].size.width, viewSize.height)];
            
            // change sizes of views
            // calculate new size
            NSRect newUpperRect = [placeHolderSearchOptionsView frame];
            NSRect newLowerRect = [placeHolderView frame];
            // full height
            if(flag) {
                // lower
                newLowerRect.size.height = fullHeight - optionsBoxHeight - margin;
                // upper
                newUpperRect.size.height = optionsBoxHeight;
                newUpperRect.origin.y = fullHeight - optionsBoxHeight;
            } else {
                newLowerRect.size.height = fullHeight - margin;
                // upper
                newUpperRect.size.height = 0.0;
                newUpperRect.origin.y = fullHeight;
            }
            
            // set new sizes
            [placeHolderSearchOptionsView setFrame:newUpperRect];
            [placeHolderView setFrame:newLowerRect];
            
            // redisplay the whole view
            [placeHolderSearchOptionsView setHidden:!flag];
            [[[self window] contentView] setNeedsDisplay:YES];
        }
    }
}

/**
 return the search text for the given type
 */
- (NSString *)searchTextForType:(SearchType)aType {
    NSString *searchText = [searchTextsForTypes objectForKey:[NSNumber numberWithInt:aType]];
    if(searchText == nil) {
        searchText = @"";
        [self setSearchText:searchText forSearchType:aType];
    }
    
    return searchText;
}

/**
 sets search text for search type
 */
- (void)setSearchText:(NSString *)aText forSearchType:(SearchType)aType {
    [searchTextsForTypes setObject:aText forKey:[NSNumber numberWithInt:aType]];
}

#pragma mark - delegate methods

- (void)contentViewInitFinished:(HostableViewController *)aView {    
    MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -contentViewInitFinished:]");
    
    if([aView isKindOfClass:[SearchOptionsViewController class]]) {
        // add to placeholder
        [placeHolderSearchOptionsView setContentView:[searchOptionsViewController optionsViewForSearchType:searchType]];
    } else {
        // add the webview as contentvew to the placeholder
        [placeHolderView setContentView:[aView view]];    
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    MBLOG(MBLOG_DEBUG, @"[SingleViewHotController -windowWillClose:]");
    // tell delegate that we are closing
    if(delegate && [delegate respondsToSelector:@selector(hostClosing:)]) {
        [delegate performSelector:@selector(hostClosing:) withObject:self];
    } else {
        MBLOG(MBLOG_WARN, @"[SingleViewHostController -windowWillClose:] delegate does not respond to selector!");
    }
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        // decode viewController
        viewController = [decoder decodeObjectForKey:@"HostableViewControllerEncoded"];
        // set delegate
        [viewController setDelegate:self];
        // decode searchtype
        self.searchType = [decoder decodeIntForKey:@"SearchTypeEncoded"];
        // decode searchQuery
        self.searchTextsForTypes = [decoder decodeObjectForKey:@"SearchTextsForTypesEncoded"];
        
        if([viewController isKindOfClass:[BibleCombiViewController class]]) {
            // init search view controller
            searchOptionsViewController = [[BibleSearchOptionsViewController alloc] initWithDelegate:self andTarget:viewController];
        }
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:SINGLEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SingleViewHostController -init] unable to load nib!");
        }
        
        // set window frame
        NSRect frame;
        frame.origin = [decoder decodePointForKey:@"WindowOriginEncoded"];
        frame.size = [decoder decodeSizeForKey:@"WindowSizeEncoded"];
        if(frame.size.width > 0 && frame.size.height > 0) {
            [[self window] setFrame:frame display:YES];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode hostableviewcontroller
    [encoder encodeObject:viewController forKey:@"HostableViewControllerEncoded"];
    // encode searchType
    [encoder encodeInt:searchType forKey:@"SearchTypeEncoded"];
    // encode searchQuery
    [encoder encodeObject:searchTextsForTypes forKey:@"SearchTextsForTypesEncoded"];
    // encode window frame
    [encoder encodePoint:[[self window] frame].origin forKey:@"WindowOriginEncoded"];
    [encoder encodeSize:[[self window] frame].size forKey:@"WindowSizeEncoded"];
}

@end
