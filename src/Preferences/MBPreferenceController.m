
#import "MBPreferenceController.h"
#import "ObjCSword/SwordManager.h"
#import "IndexingManager.h"
#import "globals.h"
#import "NSDictionary+ModuleDisplaySettings.h"
#import "NSMutableDictionary+ModuleDisplaySettings.h"
#import "NSDictionary+Additions.h"

@interface MBPreferenceController ()

- (void)applyFontPreviewText;
- (void)applyFontTextFieldPreviewHeight;
- (void)moduleFontsTableViewDoubleClick:(id)sender;

@end

@implementation MBPreferenceController

@synthesize delegate;
@synthesize sheetWindow;

static MBPreferenceController *instance;

+ (MBPreferenceController *)defaultPrefsController {
    if(instance == nil) {
        instance = [[MBPreferenceController alloc] init];
    }
    
    return instance;
}

+ (void)registerDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSMutableDictionary *defaultsDict = [NSMutableDictionary dictionary];

    // text container margins
    [defaultsDict setObject:[NSNumber numberWithFloat:5.0] forKey:DefaultsTextContainerVerticalMargins];
    [defaultsDict setObject:[NSNumber numberWithFloat:5.0] forKey:DefaultsTextContainerHorizontalMargins];

    // printing
    [defaultsDict setObject:[NSNumber numberWithFloat:1.5] forKey:DefaultsPrintLeftMargin];
    [defaultsDict setObject:[NSNumber numberWithFloat:1.0] forKey:DefaultsPrintRightMargin];
    [defaultsDict setObject:[NSNumber numberWithFloat:1.5] forKey:DefaultsPrintTopMargin];
    [defaultsDict setObject:[NSNumber numberWithFloat:2.0] forKey:DefaultsPrintBottomMargin];
    [defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:DefaultsPrintCenterHorizontally];
    [defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:DefaultsPrintCenterVertically];

    // defaults for BibleText display
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextShowBookNameKey];
    [defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:DefaultsBibleTextShowBookAbbrKey];
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextVersesOnOneLineKey];
    [defaultsDict setObject:[NSNumber numberWithInt:FullVerseNumbering] forKey:DefaultsBibleTextVerseNumberingTypeKey];
    [defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:DefaultsBibleTextHighlightBookmarksKey];

    [defaultsDict setObject:@"Helvetica Bold" forKey:DefaultsBibleTextDisplayBoldFontFamilyKey];
    [defaultsDict setObject:@"Helvetica" forKey:DefaultsBibleTextDisplayFontFamilyKey];
    [defaultsDict setObject:[NSNumber numberWithInt:14] forKey:DefaultsBibleTextDisplayFontSizeKey];

	[defaultsDict setObject:@"Lucida Grande" forKey:DefaultsHeaderViewFontFamilyKey];
    [defaultsDict setObject:[NSNumber numberWithInt:10] forKey:DefaultsHeaderViewFontSizeKey];
    [defaultsDict setObject:[NSNumber numberWithInt:12] forKey:DefaultsHeaderViewFontSizeBigKey];

    // full screen font size addition
    [defaultsDict setObject:[NSNumber numberWithInt:2] forKey:DefaultsFullscreenFontSizeAddKey];

    // module display settings
    [defaultsDict setObject:[NSDictionary dictionary] forKey:DefaultsModuleDisplaySettingsKey];

    // set default bible
    [defaultsDict setObject:@"KJV" forKey:DefaultsBibleModule];
    [defaultsDict setObject:@"StrongsGreek" forKey:DefaultsStrongsGreekModule];
    [defaultsDict setObject:@"StrongsHebrew" forKey:DefaultsStrongsHebrewModule];

    // indexer stuff
    [defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:DefaultsBackgroundIndexerEnabled];
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsRemoveIndexOnModuleRemoval];

    // UI defaults
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsShowLSBWorkspace];
    [defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:DefaultsShowLSBSingle];
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsShowRSBWorkspace];
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsShowRSBSingle];
    [defaultsDict setObject:[NSNumber numberWithInt:200] forKey:DefaultsLSBWidth];
    [defaultsDict setObject:[NSNumber numberWithInt:110] forKey:DefaultsRSBWidth];
    [defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:DefaultsShowHUDPreview];
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsShowDailyDevotionOnStartupKey];
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsShowPreviewToolTip];
    NSColor *bgCol = [NSColor colorWithCalibratedRed:0.7852 green:0.8242 blue:1.0 alpha:1.0];
    NSColor *fgCol = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    NSColor *lkCol = [NSColor colorWithCalibratedRed:0.2862 green:0.2862 blue:0.2862 alpha:1.0];
    NSColor *hfCol = [NSColor colorWithCalibratedRed:0.2862 green:0.2862 blue:0.2862 alpha:1.0];
    NSColor *thCol = [NSColor colorWithCalibratedRed:0.7764 green:0.3176 blue:0.0 alpha:1.0];
    [defaultsDict setColor:bgCol forKey:DefaultsTextBackgroundColor];
    [defaultsDict setColor:fgCol forKey:DefaultsTextForegroundColor];
    [defaultsDict setColor:thCol forKey:DefaultsTextHighlightColor];
    [defaultsDict setColor:lkCol forKey:DefaultsLinkForegroundColor];
    [defaultsDict setColor:bgCol forKey:DefaultsLinkBackgroundColor];
    [defaultsDict setColor:hfCol forKey:DefaultsHeadingsForegroundColor];
    [defaultsDict setObject:[NSNumber numberWithInt:NSUnderlineStyleNone] forKey:DefaultsLinkUnderlineAttribute];

    // cipher keys
    [defaultsDict setObject:[NSDictionary dictionary] forKey:DefaultsModuleCipherKeysKey];

	// register the defaults
	[defaults registerDefaults:defaultsDict];
}

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
	CocoLog(LEVEL_DEBUG,@"");
	
	self = [super initWithWindowNibName:@"Preferences" owner:self];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot init!");		
	} else {
        instance = self;
        delegate = aDelegate;
        moduleFontAction = NO;
        currentModuleName = nil;
	}
	
	return self;
}

- (void)windowWillClose:(NSNotification *)notification {
    CocoLog(LEVEL_DEBUG, @"");
    // tell delegate that we are closing
    if(delegate && [delegate respondsToSelector:@selector(auxWindowClosing:)]) {
        [delegate performSelector:@selector(auxWindowClosing:) withObject:self];
    } else {
        CocoLog(LEVEL_WARN, @"delegate does not respond to selector!");
    }
}

- (void)dealloc {
    [sheetWindow release];
    [super dealloc];
}

- (NSArray *)moduleNamesOfTypeBible {
    return [[SwordManager defaultManager] modulesForType:Bible];
}

- (NSArray *)moduleNamesOfTypeDictionary {
    return [[SwordManager defaultManager] modulesForType:Dictionary];
}

- (NSArray *)moduleNamesOfTypeStrongsGreek {
    return [[SwordManager defaultManager] modulesForFeature:SWMOD_CONF_FEATURE_GREEKDEF];
}

- (NSArray *)moduleNamesOfTypeStrongsHebrew {
    return [[SwordManager defaultManager] modulesForFeature:SWMOD_CONF_FEATURE_HEBREWDEF];
}

- (NSArray *)moduleNamesOfTypeMorphHebrew {
    return [[SwordManager defaultManager] modulesForFeature:SWMOD_CONF_FEATURE_HEBREWPARSE];
}

- (NSArray *)moduleNamesOfTypeMorphGreek {
    return [[SwordManager defaultManager] modulesForFeature:SWMOD_CONF_FEATURE_GREEKPARSE];
}

- (NSArray *)moduleNamesOfTypeDailyDevotion {
    return [[SwordManager defaultManager] modulesForFeature:SWMOD_CONF_FEATURE_DAILYDEVOTION];
}

- (WebPreferences *)defaultWebPreferences {
    return [self defaultWebPreferencesForModuleName:nil];
}

- (WebPreferences *)defaultWebPreferencesForModuleName:(NSString *)aModName {
    // init web preferences
    WebPreferences *webPreferences = [[[WebPreferences alloc] init] autorelease];
    [webPreferences setAutosaves:NO];
    // set defaults
    [webPreferences setJavaEnabled:NO];
    [webPreferences setJavaScriptEnabled:NO];
    [webPreferences setPlugInsEnabled:NO];
    // set default font
    if(aModName == nil) {
        [webPreferences setStandardFontFamily:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey]];
        [webPreferences setDefaultFontSize:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];                
    } else {
        NSFont *defaultFont = [self normalDisplayFontForModuleName:aModName];
        [webPreferences setStandardFontFamily:[defaultFont familyName]];
        [webPreferences setDefaultFontSize:(int)[defaultFont pointSize]];
    }
    
    return webPreferences;    
}

- (NSFont *)normalDisplayFontForModuleName:(NSString *)aModName {
    NSString *fontFamily = [userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey];
    int fontSize = [userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey];
    NSFont *displayFont = [NSFont fontWithName:fontFamily size:(float)fontSize];

    NSDictionary *settings = [[userDefaults objectForKey:DefaultsModuleDisplaySettingsKey] objectForKey:[aModName lowercaseString]];
    if(settings) {
        displayFont = [settings displayFont];
    }
    
    return displayFont;
}

- (NSFont *)boldDisplayFontForModuleName:(NSString *)aModName {
    NSString *fontFamily = [userDefaults stringForKey:DefaultsBibleTextDisplayBoldFontFamilyKey];
    int fontSize = [userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey];
    NSFont *displayFont = [NSFont fontWithName:fontFamily size:(float)fontSize];
    
    NSDictionary *settings = [[userDefaults objectForKey:DefaultsModuleDisplaySettingsKey] objectForKey:[aModName lowercaseString]];
    if(settings) {
        displayFont = [settings displayFontBold];
    }
    
    return displayFont;    
}

- (void)awakeFromNib {
	CocoLog(LEVEL_DEBUG,@"[MBPreferenceController -awakeFromNib]");
	
    generalViewRect = [generalView frame];
    bibleDisplayViewRect = [bibleDisplayView frame];
    moduleFontsViewRect = [moduleFontsView frame];
    printPrefsViewRect = [printPrefsView frame];
    
    [moduleFontsTableView setTarget:self];
    [moduleFontsTableView setDoubleAction:@selector(moduleFontsTableViewDoubleClick:)];
    
    // calculate margins
    southMargin = (int)[prefsTabView frame].origin.y;
    northMargin = (int)([[self window] frame].size.height - [prefsTabView frame].size.height + 50.0);
    sideMargin = (int)([[self window] frame].size.width - [prefsTabView frame].size.width) / 2;
    
    // topTabViewmargin
    topTabViewMargin = (int)([prefsTabView frame].size.height - [prefsTabView contentRect].size.height);
    
    // init tabview
    //preselect tabitem general
    NSTabViewItem *tvi = [prefsTabView tabViewItemAtIndex:0];
    [prefsTabView selectTabViewItem:tvi];
    // call delegate directly
    [self tabView:prefsTabView didSelectTabViewItem:tvi];
    
    [self applyFontPreviewText];
}

- (void)changeFont:(id)sender {
	CocoLog(LEVEL_DEBUG,@"[MBPreferenceController -changeFont]");
    
    NSFont *newFont = [sender convertFont:bibleDisplayFont];
    // get font data
    //NSString *displayName = [newFont displayName];
    NSString *fontFamily = [newFont familyName];
    float fontSize = [newFont pointSize];
    NSString *fontBoldName = [NSString stringWithString:fontFamily];
    if(![fontBoldName hasSuffix:@"Bold"]) {
        NSString *fontBoldNameTemp = [NSString stringWithFormat:@"%@ Bold", fontFamily];
        if([[fontManager availableFontFamilies] containsObject:fontBoldNameTemp]) {
            fontBoldName = fontBoldNameTemp;
        }
    }
    
    if(!moduleFontAction) {
        [userDefaults setObject:fontFamily forKey:DefaultsBibleTextDisplayFontFamilyKey];
        [userDefaults setObject:fontBoldName forKey:DefaultsBibleTextDisplayBoldFontFamilyKey];
        [userDefaults setObject:[NSNumber numberWithInt:(int)fontSize] forKey:DefaultsBibleTextDisplayFontSizeKey];
        
        [self applyFontPreviewText];        
    } else {
        NSMutableDictionary *moduleSettings = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:DefaultsModuleDisplaySettingsKey]];
        NSMutableDictionary *settings = [moduleSettings objectForKey:currentModuleName];
        if(!settings) {
            settings = [NSMutableDictionary dictionary];
        } else {
            settings = [[settings mutableCopy] autorelease];
        }
        [settings setDisplayFont:[NSFont fontWithName:fontFamily size:(float)fontSize]];
        [settings setDisplayFontBold:[NSFont fontWithName:fontBoldName size:(float)fontSize]];

        [moduleSettings setObject:settings forKey:currentModuleName];
        [userDefaults setObject:moduleSettings forKey:DefaultsModuleDisplaySettingsKey];
        
        [moduleFontsTableView noteNumberOfRowsChanged];
        [moduleFontsTableView reloadData];
    }
}

- (void)applyFontPreviewText {
    NSString *fontFamily = [userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey];
    int fontSize = [userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey];
    NSString *fontText = [NSString stringWithFormat:@"%@ - %i", fontFamily, fontSize];
    bibleDisplayFont = [NSFont fontWithName:fontFamily size:(float)fontSize];
    [bibleFontTextField setStringValue:fontText];
    
    [self applyFontTextFieldPreviewHeight];
}

- (void)applyFontTextFieldPreviewHeight {
    CGFloat newHeight = [bibleDisplayFont pointSize] + ([bibleDisplayFont pointSize] / 1.3);
    CGFloat heightDiff = [bibleFontTextField frame].size.height - newHeight;
    NSRect previewRect = [bibleFontTextField frame];
    previewRect.size.height = newHeight;
    previewRect.origin.y = previewRect.origin.y + heightDiff;
    [bibleFontTextField setFrame:previewRect];
}

//--------------------------------------------------------------------
// NSTabView delegates
//--------------------------------------------------------------------
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
	// alter the size of the sheet to display the tab
	NSRect viewframe;
    viewframe.size.height = 0;
    viewframe.size.width = 0;
    
	NSView *prefsView = nil;
	
	// set nil contentview
	//[tabViewItem setView:prefsView];
	
	if([[tabViewItem identifier] isEqualToString:@"general"]) {
		// set view
		viewframe = generalViewRect;
		prefsView = generalView;
	} else if([[tabViewItem identifier] isEqualToString:@"bibledisplay"]) {
		// set view
		viewframe = bibleDisplayViewRect;
		prefsView = bibleDisplayView;
	} else if([[tabViewItem identifier] isEqualToString:@"modulefonts"]) {
		// set view
		viewframe = moduleFontsViewRect;
		prefsView = moduleFontsView;
	} else if([[tabViewItem identifier] isEqualToString:@"printing"]) {
		// set view
		viewframe = printPrefsViewRect;
		prefsView = printPrefsView;
    }
	
	// calculate the difference in size
	//NSRect contentFrame = [[sheet contentView] frame];
	NSRect newFrame = [[self window] frame];
	newFrame.size.height = viewframe.size.height + northMargin + southMargin;
	newFrame.size.width = viewframe.size.width + (2 * sideMargin) + 20;
	
	// set new origin
	newFrame.origin.x = [[self window] frame].origin.x - ((newFrame.size.width - [[self window] frame].size.width) / 2);
	newFrame.origin.y = [[self window] frame].origin.y - (newFrame.size.height - [[self window] frame].size.height);
	
	// set new frame
	[[self window] setFrame:newFrame display:YES animate:YES];
	
	// set frame of box
	//NSRect boxFrame = [prefsViewBox frame];
	[prefsTabView setFrameSize:NSMakeSize((viewframe.size.width + 20),(viewframe.size.height + topTabViewMargin))];
	[prefsTabView setNeedsDisplay:YES];
	
	// set new view
	[tabViewItem setView:prefsView];	
	
	// display complete sheet again
	[[self window] display];
}

//--------------------------------------------------------------------
//----------- sheet stuff --------------------------------------
//--------------------------------------------------------------------
/**
 \brief the sheet return code
*/
- (int)sheetReturnCode {
	return sheetReturnCode;
}

/**
 \brief bring up this sheet. if docWindow is nil this will be an Window
*/
- (void)beginSheetForWindow:(NSWindow *)docWindow {
	[self setSheetWindow:docWindow];
	
	[NSApp beginSheet:[self window]
	   modalForWindow:docWindow
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:nil];
}

/**
 \brief end this sheet
*/
- (void)endSheet {
	[NSApp endSheet:[self window] returnCode:0];
}

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	// hide sheet
	[sSheet orderOut:nil];
	
	sheetReturnCode = returnCode;
}

//--------------------------------------------------------------------
//----------- Actions ---------------------------------------
//--------------------------------------------------------------------
- (IBAction)toggleBackgroundIndexer:(id)sender {
    if([userDefaults boolForKey:DefaultsBackgroundIndexerEnabled]) {
        [[IndexingManager sharedManager] triggerBackgroundIndexCheck];
    } else {
        [[IndexingManager sharedManager] invalidateBackgroundIndexer];
    }
}

/**
 \brief opens the system fonts panel
 */
- (IBAction)openFontsPanel:(id)sender {
    moduleFontAction = NO;
	NSFontPanel *fp = [NSFontPanel sharedFontPanel];
	[fp setIsVisible:YES];
    
    // set current font to FontManager
    NSFont *font = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                   size:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];
    [fontManager setSelectedFont:font isMultiple:NO];
}

#pragma mark - ModuleFont NSTableView

- (void)moduleFontsTableViewDoubleClick:(id)sender {
    moduleFontAction = YES;
	NSFontPanel *fp = [NSFontPanel sharedFontPanel];
	[fp setIsVisible:YES];
    
    NSInteger clickedRow = [moduleFontsTableView clickedRow];
    currentModuleName = [[[SwordManager defaultManager] sortedModuleNames] objectAtIndex:(NSUInteger)clickedRow];
    
    [fontManager setSelectedFont:[self normalDisplayFontForModuleName:currentModuleName] isMultiple:NO];
}

- (IBAction)resetModuleFont:(id)sender {
    NSInteger clickedRow = [moduleFontsTableView clickedRow];
    NSString *moduleName = [[[SwordManager defaultManager] sortedModuleNames] objectAtIndex:(NSUInteger)clickedRow];
    
    // remove from user defaults. this will apply the default font
    NSMutableDictionary *moduleSettings = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:DefaultsModuleDisplaySettingsKey]];
    [moduleSettings removeObjectForKey:moduleName];
    [userDefaults setObject:moduleSettings forKey:DefaultsModuleDisplaySettingsKey];
    
    [moduleFontsTableView noteNumberOfRowsChanged];
    [moduleFontsTableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [[[SwordManager defaultManager] moduleNames] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if([[aTableColumn identifier] isEqualToString:@"module"]) {
        return [[[SwordManager defaultManager] sortedModuleNames] objectAtIndex:(NSUInteger)rowIndex];
    } else if([[aTableColumn identifier] isEqualToString:@"font"]) {
        NSString *moduleName = [[[SwordManager defaultManager] sortedModuleNames] objectAtIndex:(NSUInteger)rowIndex];
        NSFont *displayFont = [self normalDisplayFontForModuleName:moduleName];
        return [NSString stringWithFormat:@"%@ - %i", [displayFont familyName], (int)[displayFont pointSize]];
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if([[aTableColumn identifier] isEqualToString:@"module"] || 
       [[aTableColumn identifier] isEqualToString:@"font"]) {
        NSString *moduleName = [[[SwordManager defaultManager] sortedModuleNames] objectAtIndex:(NSUInteger)rowIndex];
        NSFont *displayFont = [self normalDisplayFontForModuleName:moduleName];
        [aCell setFont:displayFont];        
    }     
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    NSString *moduleName = [[[SwordManager defaultManager] sortedModuleNames] objectAtIndex:(NSUInteger)row];
    
    CGFloat pointSize = [[self normalDisplayFontForModuleName:moduleName] pointSize];
    CGFloat newHeight = pointSize + (pointSize / 1.3);
    return newHeight;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return NO;
}

@end
