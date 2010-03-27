
#import "AppController.h"
#import "MBPreferenceController.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "MBAboutWindowController.h"
#import "SwordManager.h"
#import "SwordCommentary.h"
#import "SwordInstallSourceController.h"
#import "SwordInstallSource.h"
#import "MBThreadedProgressSheetController.h"
#import "ProgressOverlayViewController.h"
#import "IndexingManager.h"
#import "globals.h"
#import "BookmarkManager.h"
#import "HUDPreviewController.h"
#import "SwordBook.h"
#import "SwordModuleTreeEntry.h"
#import "FileRepresentation.h"
#import "NotesManager.h"
#import "NSDictionary+Additions.h"
#import "ContentDisplayingViewControllerFactory.h"

NSString *pathForFolderType(OSType dir, short domain, BOOL createFolder) {
	OSStatus err = 0;
	FSRef folderRef;
	NSString *path = nil;
	NSURL *url = nil;
	
	err = FSFindFolder(domain, dir, createFolder, &folderRef);
	if(err == 0) {
		url = (NSURL *)CFURLCreateFromFSRef(kCFAllocatorSystemDefault, &folderRef);
		if(url) {
			path = [NSString stringWithString:[url path]];
			[url release];
		}
	}
    
	return path;
}


@interface AppController (privateAPI)

- (void)registerDefaults;
- (BOOL)setupFolders;

@end

@implementation AppController (privateAPI)

+ (void)initialize {
	// get path to "Logs" folder of current user
	NSString *logPath = LOGFILE;
	
#ifdef DEBUG
	// init the logging facility in first place
	[MBLogger initLogger:logPath 
			   logPrefix:@"[MacSword]" 
		  logFilterLevel:MBLOG_DEBUG 
			appendToFile:YES 
			logToConsole:YES];
#endif
#ifdef RELEASE
	// init the logging facility in first place
	[MBLogger initLogger:logPath 
			   logPrefix:@"[MacSword]" 
		  logFilterLevel:MBLOG_DEBUG 
			appendToFile:YES 
			logToConsole:NO];	
#endif
	MBLOG(MBLOG_DEBUG,@"initLogging: logging initialized");    
}

- (void)registerDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// create a dictionary
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
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextShowFullVerseNumberingKey];
    [defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:DefaultsBibleTextShowVerseNumberOnlyKey];
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextHighlightBookmarksKey];
    
    [defaultsDict setObject:@"Helvetica Bold" forKey:DefaultsBibleTextDisplayBoldFontFamilyKey];
    [defaultsDict setObject:@"Helvetica" forKey:DefaultsBibleTextDisplayFontFamilyKey];
    [defaultsDict setObject:[NSNumber numberWithInt:12] forKey:DefaultsBibleTextDisplayFontSizeKey];
    
	[defaultsDict setObject:@"Lucida Grande" forKey:DefaultsHeaderViewFontFamilyKey];
    [defaultsDict setObject:[NSNumber numberWithInt:10] forKey:DefaultsHeaderViewFontSizeKey];
    [defaultsDict setObject:[NSNumber numberWithInt:12] forKey:DefaultsHeaderViewFontSizeBigKey];
    
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
    [defaultsDict setObject:[NSNumber numberWithInt:250] forKey:DefaultsLSBWidth];
    [defaultsDict setObject:[NSNumber numberWithInt:150] forKey:DefaultsRSBWidth];
    [defaultsDict setObject:[NSNumber numberWithBool:NO] forKey:DefaultsShowHUDPreview];
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsShowPreviewToolTip];
    NSColor *bgCol = [NSColor colorWithCalibratedRed:0.6980 green:0.7176 blue:0.6156 alpha:1.0];
    NSColor *fgCol = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    NSColor *lkCol = [NSColor colorWithCalibratedRed:0.2862 green:0.2862 blue:0.2862 alpha:1.0];
    NSColor *hfCol = [NSColor colorWithCalibratedRed:0.2862 green:0.2862 blue:0.2862 alpha:1.0];
    [defaultsDict setColor:bgCol forKey:DefaultsTextBackgroundColor];
    [defaultsDict setColor:fgCol forKey:DefaultsTextForegroundColor];
    [defaultsDict setColor:lkCol forKey:DefaultsLinkForegroundColor];
    [defaultsDict setColor:bgCol forKey:DefaultsLinkBackgroundColor];
    [defaultsDict setColor:hfCol forKey:DefaultsHeadingsForegroundColor];
    [defaultsDict setObject:[NSNumber numberWithInt:NSUnderlineStyleNone] forKey:DefaultsLinkUnderlineAttribute];
    
    // cipher keys
    [defaultsDict setObject:[NSDictionary dictionary] forKey:DefaultsModuleCipherKeysKey];
    
	// register the defaults
	[defaults registerDefaults:defaultsDict];
}

/**
 sets up all needed folders so the application can work
 */
- (BOOL)setupFolders {
    BOOL ret = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // get app support path
	NSString *path = pathForFolderType(kApplicationSupportFolderType, kUserDomain, true);
	if(path == nil) {
		MBLOG(MBLOG_ERR, @"Cannot get path to Application Support!");
	} else {
        MBLOG(MBLOG_INFO, @"Have path to AppSupport, ok.");
        
        // add path for application path in Application Support
        path = [path stringByAppendingPathComponent:APPNAME];
        // check if dir for application exists
        NSFileManager *manager = [NSFileManager defaultManager];
        if([manager fileExistsAtPath:path] == NO) {
            MBLOG(MBLOG_INFO, @"path to MacSword does not exist, creating it!");
            // create APP dir
            if([manager createDirectoryAtPath:path attributes:nil] == NO) {
                MBLOG(MBLOG_ERR,@"Cannot create MacSword folder in Application Support!");
                ret = NO;
            }
        }
        
        // on no error continue
        if(ret) {
            // create IndexFolder folder
            NSString *indexPath = [path stringByAppendingPathComponent:@"Index"];
            if([manager fileExistsAtPath:indexPath] == NO) {
                MBLOG(MBLOG_INFO, @"path to IndexFolder does not exist, creating it!");
                if([manager createDirectoryAtPath:indexPath attributes:nil] == NO) {
                    MBLOG(MBLOG_ERR,@"Cannot create index folder in Application Support!");
                }
            }
            // put to defaults
            [defaults setObject:indexPath forKey:DEFAULTS_SWINDEX_PATH_KEY];
            [defaults synchronize];
            
            // create default modules folder which is Sword
            path = DEFAULT_NOTES_PATH;
            if([manager fileExistsAtPath:path] == NO) {
                MBLOG(MBLOG_INFO, @"path to notes does not exist, creating it!");
                if([manager createDirectoryAtPath:path attributes:nil] == NO) {
                    MBLOG(MBLOG_ERR,@"Cannot create notes folder in Application Support!");
                }
            }
            // put to defaults
            [defaults setObject:path forKey:DEFAULTS_NOTES_PATH_KEY];
            [defaults synchronize];
        }
        
        // create default modules folder which is Sword
        path = DEFAULT_MODULE_PATH;
        if([manager fileExistsAtPath:path] == NO) {
            MBLOG(MBLOG_INFO, @"path to swmodules does not exist, creating it!");
            if([manager createDirectoryAtPath:path attributes:nil] == NO) {
                MBLOG(MBLOG_ERR,@"Cannot create swmodules folder in Application Support!");
                ret = NO;
            }
            
            // check for "mods.d" folder
            NSString *modsFolder = [path stringByAppendingPathComponent:@"mods.d"];
            if([manager fileExistsAtPath:modsFolder] == NO) {
                // create it
                if([manager createDirectoryAtPath:modsFolder attributes:nil] == NO) {
                    MBLOG(MBLOG_ERR, @"Could not create mods.d folder!");
                }
            }            
        }
        // put to defaults
        [defaults setObject:path forKey:DEFAULTS_SWMODULE_PATH_KEY];
        [defaults synchronize];                    
        
        // on no error continue
        if(ret) {
            // create InstallMgr folder
            NSString *installMgrPath = [path stringByAppendingPathComponent:SWINSTALLMGR_NAME];
            if([manager fileExistsAtPath:installMgrPath] == NO) {
                MBLOG(MBLOG_INFO, @"path to imstallmgr does not exist, creating it!");
                if([manager createDirectoryAtPath:installMgrPath attributes:nil] == NO) {
                    MBLOG(MBLOG_ERR,@"Cannot create installmgr folder in Application Support!");
                    ret = NO;
                }                
            }
            // put to defaults
            [defaults setObject:installMgrPath forKey:DEFAULTS_SWINSTALLMGR_PATH_KEY];
            [defaults synchronize];
        }        
	}
    
    return ret;
}

@end


@implementation AppController

/** the singleton */
static AppController *singleton;

+ (AppController *)defaultAppController {
    return singleton;
}

- (id)init {
	self = [super init];
	if(self == nil) {
		MBLOG(MBLOG_ERR,@"cannot alloc AppController!");		
    } else {
                
        // set singleton
        singleton = self;

        isModuleManagerShowing = NO;
        isContentShowing = NO;

        // init window Hosts array
        windowHosts = [[NSMutableArray alloc] init];
        
		// register user defaults
		[self registerDefaults];

        // init AppSupportFolder
        [self setupFolders];
        
        // load session path from defaults
        sessionPath = [userDefaults stringForKey:DefaultsSessionPath];
        if(!sessionPath) {
            sessionPath = @"";
        }
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

- (SingleViewHostController *)openSingleHostWindowForModuleType:(ModuleType)aModuleType {
    SingleViewHostController *svh = [[SingleViewHostController alloc] init];
    [windowHosts addObject:svh];
    svh.delegate = self;
    
    ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModuleType:aModuleType];
    [svh addContentViewController:hc];
    
    [svh showWindow:self];
    
    return svh;
}

/** opens a new single host window for the given module */
- (SingleViewHostController *)openSingleHostWindowForModule:(SwordModule *)mod {
    if(mod == nil) {
        NSString *sBible = [userDefaults stringForKey:DefaultsBibleModule];
        if(sBible == nil) {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"") 
                                             defaultButton:NSLocalizedString(@"OK", @"") 
                                           alternateButton:nil 
                                               otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"NoDefaultBibleSelectedText", @"")];
            [alert runModal];
        } else {
            mod = [[SwordManager defaultManager] moduleWithName:sBible];
        }
    }
    
    SingleViewHostController *svh = [[SingleViewHostController alloc] init];
    [windowHosts addObject:svh];
    svh.delegate = self;
    
    ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:mod];
    [svh addContentViewController:hc];

    [svh showWindow:self];

    return svh;
}

- (SingleViewHostController *)openSingleHostWindowForNote:(FileRepresentation *)fileRep {
    SingleViewHostController *svh = [[SingleViewHostController alloc] init];
    [windowHosts addObject:svh];
    svh.delegate = self;
    
    ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createNotesViewControllerForFileRep:fileRep];
    [svh addContentViewController:hc];    
    
    [svh showWindow:self];

    return svh;
}

- (WorkspaceViewHostController *)openWorkspaceHostWindowForModule:(SwordModule *)mod {
    if(mod == nil) {
        NSString *sBible = [userDefaults stringForKey:DefaultsBibleModule];
        if(sBible == nil) {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"") 
                                             defaultButton:NSLocalizedString(@"OK", @"") 
                                           alternateButton:nil 
                                               otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"NoDefaultBibleSelectedText", @"")];
            [alert runModal];
        } else {
            mod = [[SwordManager defaultManager] moduleWithName:sBible];
        }
    }
    
    WorkspaceViewHostController *svh = [[WorkspaceViewHostController alloc] init];
    [windowHosts addObject:svh];
    svh.delegate = self;
    
    ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:mod];
    [svh addContentViewController:hc];
    
    [svh showWindow:self];    
    
    return svh;    
}

#pragma mark - NSApplication delegates

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
	[sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}


#pragma mark - Actions

- (IBAction)openNewSingleBibleHostWindow:(id)sender {
    NSString *sBible = [userDefaults stringForKey:DefaultsBibleModule];
    SwordModule *mod = nil;
    if(sBible != nil) {
        mod = [[SwordManager defaultManager] moduleWithName:sBible];
    }
    [self openSingleHostWindowForModule:mod];
}

- (IBAction)openNewSingleCommentaryHostWindow:(id)sender {
    [self openSingleHostWindowForModuleType:commentary];
}

- (IBAction)openNewSingleDictionaryHostWindow:(id)sender {
    [self openSingleHostWindowForModuleType:dictionary];
}

- (IBAction)openNewSingleGenBookHostWindow:(id)sender {
    [self openSingleHostWindowForModuleType:genbook];
}

- (IBAction)openNewWorkspaceHostWindow:(id)sender {
    WorkspaceViewHostController *wvh = [[WorkspaceViewHostController alloc] init];
    [windowHosts addObject:wvh];
    [wvh setDelegate:self];
    [wvh showWindow:self];
}

- (IBAction)createAndOpenNewStudyNote:(id)sender {
    FileRepresentation *newNote = [FileRepresentation createWithName:NSLocalizedString(@"NewNote", @"") 
                                                            isFolder:NO 
                                             destinationDirectoryRep:[[NotesManager defaultManager] notesFileRep]];
    if(newNote) {
        [self openSingleHostWindowForNote:newNote];
    }
}

- (IBAction)showPreferenceSheet:(id)sender {
    if(!preferenceController) {
        // show panel
        preferenceController = [[MBPreferenceController alloc] initWithDelegate:self];
    }
    
    // show window
    if(!isPreferencesShowing) {
        [preferenceController showWindow:self];
        isPreferencesShowing = YES;
    } else {
        [preferenceController close];
        isPreferencesShowing = NO;
    }
}

- (IBAction)showAboutWindow:(id)sender {
    if(aboutWindowController == nil) {
        aboutWindowController = [[MBAboutWindowController alloc] init];
    }
    
    [aboutWindowController showWindow:self];
}

/**
 init module manager window controller
 */
- (IBAction)showModuleManager:(id)sender {
    if(moduleManager == nil) {
        moduleManager = [[ModuleManager alloc] initWithDelegate:self]; 
    }
    
    // show window
    if(!isModuleManagerShowing) {
        [moduleManager showWindow:self];
        isModuleManagerShowing = YES;
        
        // we stall the background indexer here
        [[IndexingManager sharedManager] setStalled:YES];
    } else {
        [moduleManager close];    
        isModuleManagerShowing = NO;
        
        // it may run again
        [[IndexingManager sharedManager] setStalled:NO];
    }
}

- (IBAction)showPreviewPanel:(id)sender {
    if(previewController == nil) {
        previewController = [[HUDPreviewController alloc] initWithDelegate:self]; 
    }
    
    // show window
    if(!isPreviewShowing) {
        [previewController showWindow:self];
        isPreviewShowing = YES;
        [userDefaults setBool:YES forKey:DefaultsShowHUDPreview];
    } else {
        [previewController close];    
        isPreviewShowing = NO;
        [userDefaults setBool:NO forKey:DefaultsShowHUDPreview];
    }    
}

- (IBAction)showCreateModuleWindow:(id)sender {
    [[NSApplication sharedApplication] runModalForWindow:createModuleWindow];
}

- (IBAction)createCommentaryOk:(id)sender {
    
    // check for module name
    NSString *modName = [createModuleNameTextField stringValue];
    if([[[SwordManager defaultManager] modules] objectForKey:modName] != nil) {
        // module exists already
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ModuleNameExists", @"") 
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"ModuleNameExistsText", @"")];
        [alert runModal];
    } else {
        NSString *modPath = [SwordCommentary createCommentaryWithName:modName];
        if(modPath != nil) {
            [[SwordManager defaultManager] addPath:modPath];        
        }        
        
        [createModuleWindow close];
        [NSApp stopModal];
    }
}

- (IBAction)createCommentaryCancel:(id)sender {
    [createModuleWindow close];
    [NSApp stopModal];
}

- (IBAction)openMacSwordWikiPage:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.crosswire.org/wiki/Frontends:MacSword"]];    
}

- (IBAction)openMacSwordHomePage:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.macsword.com"]];    
}

- (IBAction)openMacSwordForumPage:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.crosswire.org/forums/mvnforum/listthreads?forum=4"]];    
}

- (IBAction)linkSwordUtils:(id)sender {
    AuthorizationRef authorizationRef;
    OSStatus status;
    
    /* Create a new authorization reference which will later be passed to the tool. */
    status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, 
                                 kAuthorizationFlagDefaults, &authorizationRef);
    
    if(status != errAuthorizationSuccess) {
        MBLOGV(MBLOG_ERR, @"Failed to create the authref: %ld", status);
    } else {
        NSString *cmd = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Contents/Resources/bin/link_tools.sh"];
        
        int err = AuthorizationExecuteWithPrivileges(authorizationRef, [cmd UTF8String], 0, NULL, NULL);
        if(err != 0) {
            MBLOG(MBLOG_ERR, @"Error at executeWithPrivileges!");
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"")
                                             defaultButton:NSLocalizedString(@"OK", @"") alternateButton:nil otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"ErrorSWORDToolsInstallation", @"")];
            [alert runModal];
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                             defaultButton:NSLocalizedString(@"OK", @"") alternateButton:nil otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"SWORDToolsInstalled", @"")];
            [alert runModal];
        }
    }    
}

- (IBAction)unlinkSwordUtils:(id)sender {
    AuthorizationRef authorizationRef;
    OSStatus status;
    
    /* Create a new authorization reference which will later be passed to the tool. */
    status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, 
                                 kAuthorizationFlagDefaults, &authorizationRef);
    
    if(status != errAuthorizationSuccess) {
        MBLOGV(MBLOG_ERR, @"Failed to create the authref: %ld", status);
    } else {
        NSString *cmd = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Contents/Resources/bin/unlink_tools.sh"];
        
        int err = AuthorizationExecuteWithPrivileges(authorizationRef, [cmd UTF8String], 0, NULL, NULL);
        if(err != 0) {
            MBLOG(MBLOG_ERR, @"Error at executeWithPrivileges!");
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                             defaultButton:NSLocalizedString(@"OK", @"") alternateButton:nil otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"SWORDToolsUninstalled", @"")];
            [alert runModal];
        }
    }    
}

#pragma mark - NSControl delegate methods

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if([aNotification object] == createModuleNameTextField) {
        if([[createModuleNameTextField stringValue] length] == 0) {
            [createModuleOKButton setEnabled:NO];
        } else {
            [createModuleOKButton setEnabled:YES];        
        }
    }
}

#pragma mark - host window delegate methods

- (void)hostClosing:(NSWindowController *)aHost {    
    // remove from array
    [windowHosts removeObject:aHost];
}

- (void)auxWindowClosing:(NSWindowController *)aController {
    if([aController isKindOfClass:[ModuleManager class]]) {
        isModuleManagerShowing = NO;
        // it may run again
        [[IndexingManager sharedManager] setStalled:NO];
    } else if([aController isKindOfClass:[MBPreferenceController class]]) {
        isPreferencesShowing = NO;
    } else if([aController isKindOfClass:[HUDPreviewController class]]) {
        isPreviewShowing = NO;
    }
}

#pragma mark - app delegate methods

/**
 \brief gets called if the nib file has been loaded. all gfx objacts are available now.
 */
- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[AppController -awakeFromNib]");
    
    // first thing we do is check for system version
    if([(NSString *)OSVERSION compare:@"10.5.0"] == NSOrderedAscending) {
        NSLog(@"[MacSword] can't run here, you need Mac OSX Leopard to run!");
        // we can't run here
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"MacSwordNeedsLeopard", @"")];
        [alert runModal];
        [[NSApplication sharedApplication] terminate:nil];
    }
    
    // check for session to load
    if([sessionPath length] == 0) {
        sessionPath = DEFAULT_SESSION_PATH;
    }
    // load saved windows
    NSData *data = [NSData dataWithContentsOfFile:sessionPath];
    if(data != nil) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        windowHosts = [unarchiver decodeObjectForKey:@"WindowsEncoded"];
        for(NSWindowController *wc in windowHosts) {
            if([wc isKindOfClass:[WindowHostController class]]) {
                [(WindowHostController *)wc setDelegate:self];
            }
        }
    }
}

/**
 \brief is called when application loading is nearly finished
 */
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    MBLOG(MBLOG_DEBUG, @"[AppController -applicationWillFinishLaunching:]");
    
    // initialize ThreadedProgressSheet
    [MBThreadedProgressSheetController standardProgressSheetController];
    
    // init default progressoverlay controller
    [ProgressOverlayViewController defaultController];
    
    // init default SwordManager
    SwordManager *sm = [SwordManager defaultManager];
    
    // init install manager
    SwordInstallSourceController *sim = [SwordInstallSourceController defaultController];
    [sim setConfigPath:[userDefaults stringForKey:DEFAULTS_SWINSTALLMGR_PATH_KEY]];
    
    // make available all cipher keys to SwordManager
    NSDictionary *cipherKeys = [userDefaults objectForKey:DefaultsModuleCipherKeysKey];
    for(NSString *modName in cipherKeys) {
        NSString *key = [cipherKeys objectForKey:modName];
        [sm setCipherKey:key forModuleNamed:modName];
    }
    
    // init indexingmanager, set base index path
    IndexingManager *im = [IndexingManager sharedManager];
    [im setBaseIndexPath:[userDefaults stringForKey:DEFAULTS_SWINDEX_PATH_KEY]];
    [im setSwordManager:sm];        

    // start background indexer if enabled
    if([userDefaults boolForKey:DefaultsBackgroundIndexerEnabled]) {
        [[IndexingManager sharedManager] triggerBackgroundIndexCheck];    
    }    
}

/**
 \brief is called when application loading is finished
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    // if there is no window in the session open add a new workspace
    if([windowHosts count] == 0) {
        // open a default view
        WorkspaceViewHostController *svh = [[WorkspaceViewHostController alloc] init];
        svh.delegate = self;
        [windowHosts addObject:svh];        
    }
    
    // show svh
    for(id entry in windowHosts) {
        if([entry isKindOfClass:[WindowHostController class]]) {
            [(WindowHostController *)entry showWindow:self];
        }
    }
    
    // show HUD preview if set
    if([userDefaults boolForKey:DefaultsShowHUDPreview]) {
        [self showPreviewPanel:nil];
    }
}

- (void)saveSessionToFile:(NSString *)sessionFile {
    // encode all windows
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeObject:windowHosts forKey:@"WindowsEncoded"];
    [archiver finishEncoding];
    // write data object
    [data writeToFile:sessionFile atomically:NO];    
}

- (void)loadSessionFromFile:(NSString *)sessionFile {
    NSData *data = [NSData dataWithContentsOfFile:sessionFile];
    if(data != nil) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        windowHosts = [unarchiver decodeObjectForKey:@"WindowsEncoded"];
        for(NSWindowController *wc in windowHosts) {
            if([wc isKindOfClass:[WindowHostController class]]) {
                [(WindowHostController *)wc setDelegate:self];
            }
        }
        
        // show svh
        for(id entry in windowHosts) {
            if([entry isKindOfClass:[WindowHostController class]]) {
                [(WindowHostController *)entry showWindow:self];
            }
        }        
    }
}

/** stores the session to file */
- (IBAction)saveSessionAs:(id)sender {
    NSSavePanel *sp = [NSSavePanel savePanel];
    [sp setTitle:NSLocalizedString(@"SaveMSSession", @"")];
    [sp setCanCreateDirectories:YES];
    [sp setRequiredFileType:@"mssess"];
    if([sp runModal] == NSFileHandlingPanelOKButton) {
        sessionPath = [sp filename];
        [self saveSessionToFile:sessionPath];
        // this session we have loaded
        [userDefaults setObject:sessionPath forKey:DefaultsSessionPath];
    }
}

/** stores as default session */
- (IBAction)saveAsDefaultSession:(id)sender {
    [self saveSessionToFile:DEFAULT_SESSION_PATH];
    // this session we have loaded
    [userDefaults setObject:sessionPath forKey:DefaultsSessionPath];    
}

/** loads session from file */
- (IBAction)openSession:(id)sender {

    // if there are any open windows, a session is currently open
    // ask the user if we wants to save the open session first
    if([windowHosts count] > 0) {
        // show Alert
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"SessionStillOpen", @"")
                                         defaultButton:NSLocalizedString(@"Yes", @"") 
                                       alternateButton:NSLocalizedString(@"No", @"") 
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"WantToSaveTheSessionBeforeClosing", @"")];
        if([alert runModal] == NSAlertDefaultReturn) {
            if([sessionPath length] == 0) {
                sessionPath = DEFAULT_SESSION_PATH;
            }    
            // save session
            [self saveSessionToFile:sessionPath];            
        }

        // close all existing windows
        for(NSWindowController *wc in windowHosts) {
            [wc close];
        }
    }
    
    // open load panel
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setCanCreateDirectories:NO];
    [op setRequiredFileType:@"mssess"];
    [op setTitle:NSLocalizedString(@"LoadMSSession", @"")];
    [op setAllowsMultipleSelection:NO];
    [op setCanChooseDirectories:NO];
    [op setAllowsOtherFileTypes:NO];
    if([op runModal] == NSFileHandlingPanelOKButton) {
        // get file
        sessionPath = [op filename];
        // this session we have loaded
        [userDefaults setObject:sessionPath forKey:DefaultsSessionPath];        
        // load session
        [self loadSessionFromFile:sessionPath];
    }    
}

/** open the default session */
- (IBAction)openDefaultSession:(id)sender {

    // if there are any open windows, a session is currently open
    // ask the user if we wants to save the open session first
    if([windowHosts count] > 0) {
        // show Alert
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"SessionStillOpen", @"")
                                         defaultButton:NSLocalizedString(@"Yes", @"") 
                                       alternateButton:NSLocalizedString(@"No", @"") 
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"WantToSaveTheSessionBeforeClosing", @"")];
        if([alert runModal] == NSAlertDefaultReturn) {
            if([sessionPath length] == 0) {
                sessionPath = DEFAULT_SESSION_PATH;
            }    
            // save session
            [self saveSessionToFile:sessionPath];            
        }
        
        // close all existing windows
        for(NSWindowController *wc in windowHosts) {
            [wc close];
        }
    }

    // this session we have to load
    sessionPath = DEFAULT_SESSION_PATH;
    [userDefaults setObject:sessionPath forKey:DefaultsSessionPath];        
    // load session
    [self loadSessionFromFile:sessionPath];
}

/**
\brief is called when application is terminated
*/
- (NSApplicationTerminateReply)applicationShouldTerminate:(id)sender {

    // check for any unsaved content
    BOOL unsavedContent = NO;
    for(WindowHostController *hc in windowHosts) {
        if([hc hasUnsavedContent]) {
            unsavedContent = YES;
            break;
        }
    }
    if(unsavedContent) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"")
                                         defaultButton:NSLocalizedString(@"Yes", @"") 
                                       alternateButton:NSLocalizedString(@"Cancel", @"") 
                                           otherButton:NSLocalizedString(@"No", @"")
                             informativeTextWithFormat:NSLocalizedString(@"UnsavedContentQuit", @"")];    
        NSInteger modalResult = [alert runModal];
        if(modalResult == NSAlertDefaultReturn) {
            for(WindowHostController *hc in windowHosts) {
                if([hc hasUnsavedContent]) {
                    [hc saveContent];
                }
            }        
        } else if(modalResult == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }        
    }
    
    if([sessionPath length] == 0) {
        sessionPath = DEFAULT_SESSION_PATH;
    }    
    // save session
    [self saveSessionToFile:sessionPath];    
    
    // we store on application exit
    [[IndexingManager sharedManager] storeSearchBookSets];
    
    // close logger
	[MBLogger closeLogger];
	
	// we want to terminate NOW
	return NSTerminateNow;
}

@end
