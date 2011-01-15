
#import "AppController.h"
#import "MBPreferenceController.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "MBAboutWindowController.h"
#import "MBThreadedProgressSheetController.h"
#import "ProgressOverlayViewController.h"
#import "IndexingManager.h"
#import "globals.h"
#import "BookmarkManager.h"
#import "HUDPreviewController.h"
#import "FileRepresentation.h"
#import "NotesManager.h"
#import "NSDictionary+Additions.h"
#import "ContentDisplayingViewControllerFactory.h"
#import "DailyDevotionPanelController.h"
#import "SwordUrlProtocol.h"

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
- (void)addInternalModules;

@end

@implementation AppController (privateAPI)

+ (void)initialize {
    [[Configuration config] setClass:[OSXConfiguration class]];

	NSString *logPath = LOGFILE;
	
#ifdef DEBUG
	[CocoLogger initLogger:logPath 
                 logPrefix:@"[Eloquent]" 
            logFilterLevel:LEVEL_DEBUG 
              appendToFile:YES 
              logToConsole:YES];
#endif
#ifdef RELEASE
	[CocoLogger initLogger:logPath 
                 logPrefix:@"[Eloquent]" 
            logFilterLevel:LEVEL_DEBUG 
              appendToFile:YES 
              logToConsole:NO];	
#endif
	CocoLog(LEVEL_DEBUG, @"logging initialized");    
}

- (void)registerDefaults {
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
    [defaultsDict setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextHighlightBookmarksKey];
    
    [defaultsDict setObject:@"Helvetica Bold" forKey:DefaultsBibleTextDisplayBoldFontFamilyKey];
    [defaultsDict setObject:@"Helvetica" forKey:DefaultsBibleTextDisplayFontFamilyKey];
    [defaultsDict setObject:[NSNumber numberWithInt:14] forKey:DefaultsBibleTextDisplayFontSizeKey];
    
	[defaultsDict setObject:@"Lucida Grande" forKey:DefaultsHeaderViewFontFamilyKey];
    [defaultsDict setObject:[NSNumber numberWithInt:10] forKey:DefaultsHeaderViewFontSizeKey];
    [defaultsDict setObject:[NSNumber numberWithInt:12] forKey:DefaultsHeaderViewFontSizeBigKey];
    
    // fullscreen font size additon
    [defaultsDict setObject:[NSNumber numberWithInt:2 forKey:DefaultsFullscreenFontSizeAddKey]];
    
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

/**
 sets up all needed folders so the application can work
 */
- (BOOL)setupFolders {
    BOOL ret = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // get app support path
	NSString *path = pathForFolderType(kApplicationSupportFolderType, kUserDomain, true);
	if(path == nil) {
		CocoLog(LEVEL_ERR, @"Cannot get path to Application Support!");
	} else {
        CocoLog(LEVEL_INFO, @"Have path to AppSupport, ok.");
        
        // add path for application path in Application Support
        path = [path stringByAppendingPathComponent:APPNAME];
        // check if dir for application exists
        NSFileManager *manager = [NSFileManager defaultManager];
        if([manager fileExistsAtPath:path] == NO) {
            CocoLog(LEVEL_INFO, @"path to Eloquent does not exist, creating it!");
            // create APP dir
            if([manager createDirectoryAtPath:path attributes:nil] == NO) {
                CocoLog(LEVEL_ERR,@"Cannot create Eloquent folder in Application Support!");
                ret = NO;
            }
        }
        
        // on no error continue
        if(ret) {
            // create IndexFolder folder
            NSString *indexPath = [path stringByAppendingPathComponent:@"Index"];
            if([manager fileExistsAtPath:indexPath] == NO) {
                CocoLog(LEVEL_INFO, @"path to IndexFolder does not exist, creating it!");
                if([manager createDirectoryAtPath:indexPath attributes:nil] == NO) {
                    CocoLog(LEVEL_ERR,@"Cannot create index folder in Application Support!");
                }
            }
            // put to defaults
            [defaults setObject:indexPath forKey:DEFAULTS_SWINDEX_PATH_KEY];
            [defaults synchronize];
            
            // create default modules folder which is Sword
            path = DEFAULT_NOTES_PATH;
            if([manager fileExistsAtPath:path] == NO) {
                CocoLog(LEVEL_INFO, @"path to notes does not exist, creating it!");
                if([manager createDirectoryAtPath:path attributes:nil] == NO) {
                    CocoLog(LEVEL_ERR,@"Cannot create notes folder in Application Support!");
                }
            }
            // put to defaults
            [defaults setObject:path forKey:DEFAULTS_NOTES_PATH_KEY];
            [defaults synchronize];
        }
        
        // create default modules folder which is Sword
        path = DEFAULT_MODULE_PATH;
        if([manager fileExistsAtPath:path] == NO) {
            CocoLog(LEVEL_INFO, @"path to swmodules does not exist, creating it!");
            if([manager createDirectoryAtPath:path attributes:nil] == NO) {
                CocoLog(LEVEL_ERR,@"Cannot create swmodules folder in Application Support!");
                ret = NO;
            }
            
            // check for "mods.d" folder
            NSString *modsFolder = [path stringByAppendingPathComponent:@"mods.d"];
            if([manager fileExistsAtPath:modsFolder] == NO) {
                // create it
                if([manager createDirectoryAtPath:modsFolder attributes:nil] == NO) {
                    CocoLog(LEVEL_ERR, @"Could not create mods.d folder!");
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
                CocoLog(LEVEL_INFO, @"path to imstallmgr does not exist, creating it!");
                if([manager createDirectoryAtPath:installMgrPath attributes:nil] == NO) {
                    CocoLog(LEVEL_ERR,@"Cannot create installmgr folder in Application Support!");
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

- (void)addInternalModules {
    NSString *modulesFolder = [[[NSBundle mainBundle] resourcePath]stringByAppendingPathComponent:@"Modules"];

    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *subDirs = [fm directoryContentsAtPath:modulesFolder];
    // for all sub directories add module
    BOOL directory;
    NSString *fullSubDir = nil;
    NSString *subDir = nil;
    for(subDir in subDirs) {
        if([subDir hasSuffix:@"swd"]) {
            fullSubDir = [modulesFolder stringByAppendingPathComponent:subDir];
            
            //if its a directory
            if([fm fileExistsAtPath:fullSubDir isDirectory:&directory]) {
                if(directory) {
                    CocoLog(LEVEL_DEBUG, @"augmenting folder: %@", fullSubDir);
                    [[SwordManager defaultManager] addPath:fullSubDir];
                    CocoLog(LEVEL_DEBUG, @"augmenting folder done");
                }
            }
        }
    }
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
		CocoLog(LEVEL_ERR,@"cannot alloc AppController!");		
    } else {
        CocoLog(LEVEL_DEBUG, @"Initializing application");

        // first thing we do is check for system version
        if([(NSString *)OSVERSION compare:@"10.5.0"] == NSOrderedAscending) {
            NSLog(@"[Eloquent] can't run here, you need Mac OSX Leopard to run!");
            // we can't run here
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                             defaultButton:NSLocalizedString(@"OK", @"") 
                                           alternateButton:nil 
                                               otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"EloquentNeedsLeopard", @"")];
            [alert runModal];
            [[NSApplication sharedApplication] terminate:nil];
        }

        // set singleton
        singleton = self;

        // init window Hosts array
        windowHosts = [[NSMutableArray alloc] init];        

        NSFileManager *fm = [NSFileManager defaultManager];
        // check whether this is the first start of Eloquent
        NSString *prefsPath = [@"~/Library/Preferences/org.crosswire.Eloquent.plist" stringByExpandingTildeInPath];
        if(![fm fileExistsAtPath:prefsPath] && [fm fileExistsAtPath:DEFAULT_MODULE_PATH]) {
            // show Alert
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"") 
                                             defaultButton:NSLocalizedString(@"Yes", @"") 
                                           alternateButton:NSLocalizedString(@"No", @"") 
                                               otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Info_OldModuleDatabaseDetected", @"")];
            if([alert runModal] == NSAlertDefaultReturn) {
                [fm removeItemAtPath:DEFAULT_MODULE_PATH error:nil];
            }
        }
        
        [self registerDefaults];
        [self setupFolders];
        
        // load session path from defaults
        sessionPath = [userDefaults stringForKey:DefaultsSessionPath];
        if(!sessionPath) {
            sessionPath = @"";
        }
        
        // initialize ThreadedProgressSheet
        [MBThreadedProgressSheetController standardProgressSheetController];
        
        // init default progressoverlay controller
        [ProgressOverlayViewController defaultController];
        
        [[SwordLocaleManager defaultManager] initLocale];
        SwordManager *sm = [SwordManager defaultManager];
        
        // check for installed modules, if there are none add our internal module path so that th user at least has one module (ESV)
        if([[sm modules] count] == 0) {
            [self addInternalModules];
        }
        
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
    CocoLog(LEVEL_DEBUG, @"got file names:");
    for(NSString *filename in filenames) {
        CocoLog(LEVEL_DEBUG, @"filename: %@", filename);
                
        NSString *moduleFilename = [filename lastPathComponent];
        NSString *moduleName = [[moduleFilename componentsSeparatedByString:@".swd"] objectAtIndex:0];
        CocoLog(LEVEL_DEBUG, @"Have module name: %@", moduleName);
        
        SwordManager *swMgr = [SwordManager defaultManager];
        
        if([swMgr moduleWithName:moduleName] == nil) {
            CocoLog(LEVEL_DEBUG, @"Don't know module: %@", moduleName);
            // we don't know this module
            // ask user whether to copy this module to the repository for permanent use
            // or to only use it temporarily
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"") 
                                             defaultButton:NSLocalizedString(@"Permanent", @"") 
                                           alternateButton:NSLocalizedString(@"Temporary", @"") 
                                               otherButton:nil 
                                 informativeTextWithFormat:[NSString stringWithFormat:NSLocalizedString(@"ModuleXYNotInRepoWantToCopy", @""), moduleName]];

            NSString *destinationPath = filename;
            if([alert runModal] == NSAlertDefaultReturn) {
                CocoLog(LEVEL_DEBUG, @"User chose to permanently use this module.");
                destinationPath = [DEFAULT_MODULE_PATH stringByAppendingPathComponent:moduleFilename];

                CocoLog(LEVEL_DEBUG, [NSString stringWithFormat:@"Copying module %@ to %@", filename, destinationPath]); 
                NSFileManager *fm = [NSFileManager defaultManager];
                [fm copyItemAtPath:filename toPath:destinationPath error:nil];
            }
            // augment module
            CocoLog(LEVEL_DEBUG, [NSString stringWithFormat:@"Augmenting module at: %@", destinationPath]);
            [swMgr addPath:destinationPath];
            // open single window
            SwordModule *mod = [swMgr moduleWithName:moduleName];
            if(mod) {
                CocoLog(LEVEL_DEBUG, [NSString stringWithFormat:@"Opening module with name %@ in single window...", [mod name]]);
                [self openSingleHostWindowForModule:mod];                
            } else {
                CocoLog(LEVEL_WARN, [NSString stringWithFormat:@"Could not retrieve module with name: %@", moduleName]);
            }
        }
    }
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
    [self openSingleHostWindowForModuleType:Commentary];
}

- (IBAction)openNewSingleDictionaryHostWindow:(id)sender {
    [self openSingleHostWindowForModuleType:Dictionary];
}

- (IBAction)openNewSingleGenBookHostWindow:(id)sender {
    [self openSingleHostWindowForModuleType:Genbook];
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
    ModuleManager *mm = [[ModuleManager alloc] initWithDelegate:self]; 
    [mm showWindow:self];
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

- (IBAction)showDailyDevotionPanel:(id)sender {
    
    NSString *ddModName = [userDefaults stringForKey:DefaultsDailyDevotionModule];

    BOOL show = YES;
    if(dailyDevotionController == nil) {
        // get daily devotion module
        if(ddModName == nil) {
            show = NO;
        } else {
            SwordDictionary *ddMod = (SwordDictionary *)[[SwordManager defaultManager] moduleWithName:ddModName];
            dailyDevotionController = [[DailyDevotionPanelController alloc] initWithDelegate:self andModule:ddMod];
        }
    } else {
        if(ddModName != nil) {
            SwordDictionary *ddMod = (SwordDictionary *)[[SwordManager defaultManager] moduleWithName:ddModName];
            [dailyDevotionController setDailyDevotionModule:ddMod];
        }
    }

    if(show) {
        // show window
        if(!isDailyDevotionShowing) {
            [dailyDevotionController showWindow:self];
            isDailyDevotionShowing = YES;
        } else {
            [dailyDevotionController close];    
            isDailyDevotionShowing = NO;
        }        
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
        CocoLog(LEVEL_ERR, @"Failed to create the authref: %ld", status);
    } else {
        NSString *binFolder = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Contents/Resources/bin"];
        NSString *cmd = [NSString stringWithFormat:@"%@/%@", binFolder, @"link_tools.sh"];
        
        char *args[2];
        args[0] = (char *)[binFolder UTF8String];
        args[1] = NULL;
        int err = AuthorizationExecuteWithPrivileges(authorizationRef, [cmd UTF8String], 0, args, NULL);
        if(err != 0) {
            CocoLog(LEVEL_ERR, @"Error at executeWithPrivileges!");
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
        CocoLog(LEVEL_ERR, @"Failed to create the authref: %ld", status);
    } else {
        NSString *cmd = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Contents/Resources/bin/unlink_tools.sh"];
        
        int err = AuthorizationExecuteWithPrivileges(authorizationRef, [cmd UTF8String], 0, NULL, NULL);
        if(err != 0) {
            CocoLog(LEVEL_ERR, @"Error at executeWithPrivileges!");
        } else {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                             defaultButton:NSLocalizedString(@"OK", @"") alternateButton:nil otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"SWORDToolsUninstalled", @"")];
            [alert runModal];
        }
    }    
}

#ifdef USE_SPARKLE
- (IBAction)checkForUpdates:(id)sender {
    [sparkleUpdater checkForUpdates:sender];
}
#endif

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
    if([aController isKindOfClass:[MBPreferenceController class]]) {
        isPreferencesShowing = NO;
    } else if([aController isKindOfClass:[HUDPreviewController class]]) {
        isPreviewShowing = NO;
    } else if([aController isKindOfClass:[DailyDevotionPanelController class]]) {
        isDailyDevotionShowing = NO;
    }
}

#pragma mark - app delegate methods

- (void)handleURLEvent:(NSAppleEventDescriptor *) event withReplyEvent:(NSAppleEventDescriptor *) replyEvent {
    NSString *urlString = [[event descriptorAtIndex:1] stringValue];

	CocoLog(LEVEL_DEBUG, @"handling URL event for: %@", urlString);
    
    NSDictionary *linkData = [SwordManager linkDataForLinkURL:[NSURL URLWithString:urlString]];
    NSString *moduleName = [linkData objectForKey:ATTRTYPE_MODULE];
    NSString *passage = [linkData objectForKey:ATTRTYPE_VALUE];
    
    CocoLog(LEVEL_DEBUG, @"have module: %@", moduleName);
    CocoLog(LEVEL_DEBUG, @"have passage: %@", passage);
    
    if(moduleName && passage) {
        SwordModule *mod = [[SwordManager defaultManager] moduleWithName:moduleName];
        if(mod) {
            SingleViewHostController *host = [self openSingleHostWindowForModule:mod];
            [host setSearchText:passage];
        }
    } else {
        CocoLog(LEVEL_WARN, @"have nil moduleName or passage");
    }
}

/**
 \brief gets called if the nib file has been loaded. all gfx objacts are available now.
 */
- (void)awakeFromNib {

#ifdef USE_SPARKLE
    sparkleUpdater = [[SUUpdater alloc] init];
    
    // add sparkle "Check for updates..." menu item to help menu
    [helpMenu addItem:[NSMenuItem separatorItem]];
    [helpMenu addItemWithTitle:NSLocalizedString(@"Menu_CheckForUpdates", @"") action:@selector(checkForUpdates:) keyEquivalent:@""];
#endif
    
    if([sessionPath length] == 0) {
        sessionPath = DEFAULT_SESSION_PATH;
    }
}

/**
 \brief is called when application loading is nearly finished
 */
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    if([userDefaults boolForKey:DefaultsBackgroundIndexerEnabled]) {
        [[IndexingManager sharedManager] triggerBackgroundIndexCheck];    
    }    
}

/**
 \brief is called when application loading is finished
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self loadSessionFromFile:sessionPath];

    // if there is no window in the session open add a new workspace
    if([windowHosts count] == 0) {
        WorkspaceViewHostController *svh = [[WorkspaceViewHostController alloc] init];
        svh.delegate = self;
        [windowHosts addObject:svh];

        [svh showWindow:self];
    }
    
    // show HUD preview if set
    if([userDefaults boolForKey:DefaultsShowHUDPreview]) {
        [self showPreviewPanel:nil];
    }
    
    // show HUD daily devotion if set
    if([userDefaults boolForKey:DefaultsShowDailyDevotionOnStartupKey]) {
        [self showDailyDevotionPanel:nil];
    }
    
    //initialise url handlers
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self 
                                                       andSelector:@selector( handleURLEvent:withReplyEvent: ) 
                                                     forEventClass:kInternetEventClass 
                                                        andEventID:kAEGetURL];    
    [SwordUrlProtocol setup];
    
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
        @try {
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
        @catch (NSException *e) {
            CocoLog(LEVEL_ERR, @"Error on loading session: %@", [e reason]);
            
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"SessionLoadError", @"")
                                             defaultButton:NSLocalizedString(@"Ok", @"") 
                                           alternateButton:nil
                                               otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"SessionLoadErrorText", @"")];
            [alert runModal];
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
	[CocoLogger closeLogger];
	
	// we want to terminate NOW
	return NSTerminateNow;
}

@end
