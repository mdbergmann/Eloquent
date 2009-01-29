#import "MBPreferenceController.h"
#import "SwordManager.h"
#import "globals.h"

@implementation MBPreferenceController

@synthesize delegate;
@synthesize sheetWindow;
@synthesize webPreferences;

static MBPreferenceController *instance;

+ (MBPreferenceController *)defaultPrefsController {
    if(instance == nil) {
        instance = [[MBPreferenceController alloc] init];
    }
    
    return instance;
}

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
	MBLOG(MBLOG_DEBUG,@"[MBPreferenceController -init]");
	
	self = [super initWithWindowNibName:@"Preferences" owner:self];
	if(self == nil) {
		MBLOG(MBLOG_ERR, @"[MBPreferenceController -init] cannot init!");		
	} else {        
        instance = self;
        delegate = aDelegate;
        
		// init web preferences
        webPreferences = [[WebPreferences alloc] init];
        [webPreferences setAutosaves:NO];
        // set defaults
        [webPreferences setJavaEnabled:NO];
        [webPreferences setJavaScriptEnabled:NO];
        [webPreferences setPlugInsEnabled:NO];
        // set default font
        [webPreferences setStandardFontFamily:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey]];
        [webPreferences setDefaultFontSize:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];        
	}
	
	return self;
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

/**
\brief dealloc of this class is called on closing this document
 */
- (void)finalize {
	// dealloc object
	[super finalize];
}

- (NSArray *)moduleNamesOfTypeBible {
    return [[SwordManager defaultManager] modulesForType:SWMOD_CATEGORY_BIBLES];
}

- (NSArray *)moduleNamesOfTypeStrongsGreek {
    return [[SwordManager defaultManager] modulesForFeature:SWMOD_CONF_FEATURE_GREEKDEF];
}

- (NSArray *)moduleNamesOfTypeStrongsHebrew {
    return [[SwordManager defaultManager] modulesForFeature:SWMOD_CONF_FEATURE_HEBREWDEF];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib {
	MBLOG(MBLOG_DEBUG,@"[MBPreferenceController -awakeFromNib]");
	
    generalViewRect = [generalView frame];
    bibleDisplayViewRect = [bibleDisplayView frame];
    
    // calculate margins
    northMargin = [[self window] frame].size.height - southMargin - [prefsTabView frame].size.height;
    southMargin = [prefsTabView frame].origin.y;
    sideMargin = ([[self window] frame].size.width - [prefsTabView frame].size.width) / 2;
    //sideMargin = 0;
    
    // topTabViewmargin
    topTabViewMargin = [prefsTabView frame].size.height - [prefsTabView contentRect].size.height;
    
    // init tabview
    //preselect tabitem general
    NSTabViewItem *tvi = [prefsTabView tabViewItemAtIndex:0];
    [prefsTabView selectTabViewItem:tvi];
    // call delegate directly
    [self tabView:prefsTabView didSelectTabViewItem:tvi];
    
    // set font family and size in bible text
    NSString *fontFamily = [userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey];
    int fontSize = [userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey];
    NSString *fontText = [NSString stringWithFormat:@"%@ - %i", fontFamily, fontSize];
    [bibleFontTextField setStringValue:fontText];
    bibleDisplayFont = [NSFont fontWithName:fontFamily size:(float)fontSize];
}

- (void)changeFont:(id)sender {
	MBLOG(MBLOG_DEBUG,@"[MBPreferenceController -changeFont]");
    
    NSFont *newFont = [sender convertFont:bibleDisplayFont];
    // get font data
    NSString *fontFamily = [newFont familyName];
    float fontSize = [newFont pointSize];
    
    // update user defaults
    [userDefaults setObject:fontFamily forKey:DefaultsBibleTextDisplayFontFamilyKey];
    [userDefaults setObject:[NSString stringWithFormat:@"%@ Bold"] forKey:DefaultsBibleTextDisplayBoldFontFamilyKey];
    [userDefaults setObject:[NSNumber numberWithInt:(int)fontSize] forKey:DefaultsBibleTextDisplayFontSizeKey];
    // update webPreferences
    [webPreferences setStandardFontFamily:fontFamily];
    [webPreferences setDefaultFontSize:(int)fontSize];        
    
    NSString *fontText = [NSString stringWithFormat:@"%@ - %i", fontFamily, (int)fontSize];
    [bibleFontTextField setStringValue:fontText];
    bibleDisplayFont = newFont;
}

//--------------------------------------------------------------------
// NSTabView delegates
//--------------------------------------------------------------------
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
	// alter the size of the sheet to display the tab
	NSRect viewframe;
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
    }
	
	// calculate the difference in size
	//NSRect contentFrame = [[sheet contentView] frame];
	NSRect newFrame = [[self window] frame];
	newFrame.size.height = viewframe.size.height + southMargin + northMargin;
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
- (IBAction)okButton:(id)sender {
	[self endSheet];
    [self close];
}

@end
