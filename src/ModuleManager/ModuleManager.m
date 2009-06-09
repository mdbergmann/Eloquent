//
//  ModuleManager.m
//  Eloquent
//
//  Created by Manfred Bergmann on 26.12.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ModuleManager.h"

// toolbar identifiers
#define TB_SYNC_ISLIST_ITEM             @"ISSyncFromMaster"
#define TB_INSTALLSOURCE_DELETE_ITEM    @"ISDelete"
#define TB_INSTALLSOURCE_ADD_ITEM       @"ISAdd"
#define TB_INSTALLSOURCE_EDIT_ITEM      @"ISEdit"
#define TB_INSTALLSOURCE_REFRESH_ITEM   @"ISRefresh"
#define TB_TASK_PROCESS_ITEM            @"ProcessTasks"
#define TB_TASK_PREVIEW_ITEM            @"PreviewTasks"

@implementation ModuleManager

@synthesize delegate;

- (id)init {
	return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
	self = [super initWithWindowNibName:@"ModuleManager" owner:self];
	if(self == nil) {
		MBLOG(MBLOG_ERR,@"[ModuleManager -init]");		
	}
	else {
        delegate = aDelegate;
        // init module manage view controller
        moduleViewController = [[ModuleManageViewController alloc] initWithDelegate:self parent:[self window]];
	}
	
	return self;    
}

/**
 \brief finalize called by the GC
 */
- (void)dealloc {
	MBLOG(MBLOG_DEBUG,@"[ModuleManager -finalize]");
    
	// dealloc object
	[super dealloc];
}

/** action overriden */
- (void)showWindow:(id)sender {
    
    [super showWindow:sender];

    // do some additional stuff here
    NSView *view = [moduleViewController contentView];
    if(view != nil) {
        MBLOGV(MBLOG_DEBUG, @"[ModuleManager -moduleManageViewInitialized] view width: %f, height: %f", [view bounds].size.width, [view bounds].size.height);
    } else {
        MBLOG(MBLOG_ERR, @"[ModuleManager -moduleManageViewInitialized] view is nil");
    }
    [[self window] setContentView:[moduleViewController contentView]];
    
    // show disclaimer if needed
    [moduleViewController showDisclaimer];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib {
    
	MBLOG(MBLOG_DEBUG,@"[ModuleManager -awakeFromNib]");
    
    // init toolbar identifiers
    tbIdentifiers = [[NSMutableDictionary alloc] init];
    
    // set parent window
    [moduleViewController setParentWindow:[self window]];
    
    NSToolbarItem *item = nil;
    NSImage *image = nil;
    
    // ----------------------------------------------------------------------------------------
    // sync is list
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_SYNC_ISLIST_ITEM];
    [item setLabel:NSLocalizedString(@"SyncISFromMasterLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"SyncISFromMasterLabel", @"")];
    [item setToolTip:NSLocalizedString(@"SyncISFromMasterToolTip", @"")];
    image = [NSImage imageNamed:@"ModuleManager.png"];
    [item setImage:image];
    //[item setTarget:[AppController defaultAppController]];
    [item setAction:@selector(syncISListFromMasterTB:)];
    [tbIdentifiers setObject:item forKey:TB_SYNC_ISLIST_ITEM];

    // add is
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_INSTALLSOURCE_ADD_ITEM];
    [item setLabel:NSLocalizedString(@"AddInstallSourceLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"AddInstallSourceLabel", @"")];
    [item setToolTip:NSLocalizedString(@"AddInstallSourceToolTip", @"")];
    image = [NSImage imageNamed:@"add.png"];
    [item setImage:image];
    //[item setTarget:delegate];
    [item setAction:@selector(addInstallSourceTB:)];
    [tbIdentifiers setObject:item forKey:TB_INSTALLSOURCE_ADD_ITEM];

    // edit is
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_INSTALLSOURCE_EDIT_ITEM];
    [item setLabel:NSLocalizedString(@"EditInstallSourceLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"EditInstallSourceLabel", @"")];
    [item setToolTip:NSLocalizedString(@"EditInstallSourceToolTip", @"")];
    image = [NSImage imageNamed:@"edit.png"];
    [item setImage:image];
    //[item setTarget:delegate];
    [item setAction:@selector(editInstallSourceTB:)];
    [tbIdentifiers setObject:item forKey:TB_INSTALLSOURCE_EDIT_ITEM];
    
    // refresh is
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_INSTALLSOURCE_REFRESH_ITEM];
    [item setLabel:NSLocalizedString(@"RefreshInstallSourceLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"RefreshInstallSourceLabel", @"")];
    [item setToolTip:NSLocalizedString(@"RefreshInstallSourceToolTip", @"")];
    image = [NSImage imageNamed:@"reload.png"];
    [item setImage:image];
    //[item setTarget:delegate];
    [item setAction:@selector(refreshInstallSourceTB:)];
    [tbIdentifiers setObject:item forKey:TB_INSTALLSOURCE_REFRESH_ITEM];
    
    // delete is
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_INSTALLSOURCE_DELETE_ITEM];
    [item setLabel:NSLocalizedString(@"DeleteInstallSourceLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"DeleteInstallSourceLabel", @"")];
    [item setToolTip:NSLocalizedString(@"DeleteInstallSourceToolTip", @"")];
    image = [NSImage imageNamed:@"remove.png"];
    [item setImage:image];
    //[item setTarget:delegate];
    [item setAction:@selector(deleteInstallSourceTB:)];
    [tbIdentifiers setObject:item forKey:TB_INSTALLSOURCE_DELETE_ITEM];

    // preview tasks
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_TASK_PREVIEW_ITEM];
    [item setLabel:NSLocalizedString(@"PreviewTasksLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"PreviewTasksLabel", @"")];
    [item setToolTip:NSLocalizedString(@"PreviewTasksToolTip", @"")];
    image = [NSImage imageNamed:@"preview.png"];
    [item setImage:image];
    //[item setTarget:delegate];
    [item setAction:@selector(previewTasksTB:)];
    [tbIdentifiers setObject:item forKey:TB_TASK_PREVIEW_ITEM];
    
    // preview tasks
    item = [[NSToolbarItem alloc] initWithItemIdentifier:TB_TASK_PROCESS_ITEM];
    [item setLabel:NSLocalizedString(@"ProcessTasksLabel", @"")];
    [item setPaletteLabel:NSLocalizedString(@"ProcessTasksLabel", @"")];
    [item setToolTip:NSLocalizedString(@"ProcessTasksToolTip", @"")];
    image = [NSImage imageNamed:@"exec.png"];
    [item setImage:image];
    //[item setTarget:delegate];
    [item setAction:@selector(processTasksTB:)];
    [tbIdentifiers setObject:item forKey:TB_TASK_PROCESS_ITEM];
    
    // add std items
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarFlexibleSpaceItemIdentifier];
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarSpaceItemIdentifier];
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarSeparatorItemIdentifier];
    [tbIdentifiers setObject:[NSNull null] forKey:NSToolbarPrintItemIdentifier];
    
    [self setupToolbar];    
}

- (void)windowWillClose:(NSNotification *)notification {
    MBLOG(MBLOG_DEBUG, @"[WindowHostController -windowWillClose:]");
    // tell delegate that we are closing
    if(delegate && [delegate respondsToSelector:@selector(auxWindowClosing:)]) {
        [delegate performSelector:@selector(auxWindowClosing:) withObject:self];
    } else {
        MBLOG(MBLOG_WARN, @"[WindowHostController -windowWillClose:] delegate does not respond to selector!");
    }
}

// ============================================================
// NSToolbar Related Methods
// ============================================================
/**
 \brief create a toolbar and add it to the window. Set the delegate to this object.
 */
- (void)setupToolbar
{
    // Create a new toolbar instance, and attach it to our document window 
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier: @"modinstalltoolbar"];
    
    // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults 
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
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
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar 
{
	return [tbIdentifiers allKeys];
}

/**
 \brief returns array with all default toolbar item identifiers
 */
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar 
{
	NSArray *defaultItemArray = [NSArray arrayWithObjects:
                                 TB_SYNC_ISLIST_ITEM,
                                 TB_INSTALLSOURCE_ADD_ITEM,
                                 TB_INSTALLSOURCE_DELETE_ITEM,
                                 TB_INSTALLSOURCE_EDIT_ITEM,
                                 TB_INSTALLSOURCE_REFRESH_ITEM,
                                 NSToolbarSeparatorItemIdentifier,
                                 TB_TASK_PREVIEW_ITEM,
                                 TB_TASK_PROCESS_ITEM,
                                 NSToolbarFlexibleSpaceItemIdentifier,
                                 nil];
	
	return defaultItemArray;
}

- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar 
	  itemForItemIdentifier:(NSString *)itemIdentifier
  willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *item = nil;
    
	item = [tbIdentifiers valueForKey:itemIdentifier];
	
    return item;
}

/** toolbar item */

- (void)syncISListFromMasterTB:(id)sender {
    [moduleViewController syncInstallSourcesFromMasterList:sender];
}

- (void)addInstallSourceTB:(id)sender {
    [moduleViewController addInstallSource:sender];
}

- (void)editInstallSourceTB:(id)sender {
    [moduleViewController editInstallSource:sender];    
}

- (void)refreshInstallSourceTB:(id)sender {
    [moduleViewController refreshInstallSource:sender];    
}

- (void)deleteInstallSourceTB:(id)sender {
    [moduleViewController deleteInstallSource:sender];    
}

/*
- (void)previewTasksTB:(id)sender {
    [moduleViewController processTasks];
}
*/

- (void)processTasksTB:(id)sender {
    [moduleViewController processTasks];
}

@end
