#import "AppController.h"
#import <ObjCSword/SwordUtil.h>
#import "MBPreferenceController.h"
#import "HostableViewController.h"
#import "WindowHostController.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "MBAboutWindowController.h"
#import "MBThreadedProgressSheetController.h"
#import "SwordModule+SearchKitIndex.h"
#import "ProgressOverlayViewController.h"
#import "IndexingManager.h"
#import "HUDPreviewController.h"
#import "FileRepresentation.h"
#import "NotesManager.h"
#import "ContentDisplayingViewControllerFactory.h"
#import "DailyDevotionPanelController.h"
#import "SwordUrlProtocol.h"
#import "SessionManager.h"
#import "globals.h"
#import "ModuleManager.h"
#import "EloquentFilterProvider.h"
#import "FolderUtil.h"

@interface AppController ()

@property (nonatomic) BOOL appIsTerminating;
@property (nonatomic, copy) NSString *pendingURLString;

@end

@implementation AppController

+ (void)initialize {
    [Configuration configWithImpl:[OSXConfiguration new]];
    
    NSString *logPath = [[FolderUtil urlForLogfile] path];
    
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

/**
 sets up all needed folders so the application can work

 !!! Do not create the "Sword" folder here. This is created by ObjCSword including the required 'modules' and 'mods.d' folders.

 */
- (BOOL)setupFolders {
    NSString *folder = [[FolderUtil urlForAppInAppSupport] path];
    if(folder == nil) {
        CocoLog(LEVEL_ERR, @"Unable to retrieve app folder!");
        return NO;
    }
    
    folder = [[FolderUtil urlForIndexFolder] path];
    if(folder == nil) {
        CocoLog(LEVEL_ERR, @"Unable to retrieve index folder!");
        return NO;
    }
    
    folder = [[FolderUtil urlForNotesFolder] path];
    if(folder == nil) {
        CocoLog(LEVEL_ERR, @"Unable to retrieve notes folder!");
        return NO;
    }
    
    return YES;
}

- (void)addInternalModules {
    NSString *modulesFolder = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Modules"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *subDirs = [fm contentsOfDirectoryAtPath:modulesFolder error:NULL];
    // for all sub directories add module
    BOOL directory;
    NSString *fullSubDir;
    NSString *subDir;
    for(subDir in subDirs) {
        if([subDir hasSuffix:@"swd"]) {
            fullSubDir = [modulesFolder stringByAppendingPathComponent:subDir];
            
            //if its a directory
            if([fm fileExistsAtPath:fullSubDir isDirectory:&directory]) {
                if(directory) {
                    CocoLog(LEVEL_DEBUG, @"augmenting folder: %@", fullSubDir);
                    [[SwordManager defaultManager] addModulesPath:fullSubDir];
                    CocoLog(LEVEL_DEBUG, @"augmenting folder done");
                }
            }
        }
    }
}

/** the singleton */
static AppController *singleton;

+ (AppController *)defaultAppController {
    return singleton;
}

- (id)init {
	self = [super init];
	if(self) {
        // set singleton
        singleton = self;

#ifndef APPSTORE
        NSFileManager *fm = [NSFileManager defaultManager];

        // check whether this is the first start of Eloquent
        NSString *prefsPath = PREFS_FILE;
        NSString *moduleFolder = [[Configuration config] defaultModulePath];
        if(![fm fileExistsAtPath:prefsPath] && [fm fileExistsAtPath:moduleFolder]) {
            // show Alert
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"Warning", @"")];
            [alert setInformativeText:NSLocalizedString(@"Info_OldModuleDatabaseDetected", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"Yes", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"No", @"")];
            if([alert runModal] == NSAlertFirstButtonReturn) {
                [fm removeItemAtPath:moduleFolder error:nil];
            }
        }
#endif
        [MBPreferenceController registerDefaults];

        [self setupFolders];

        // init SessionManager
        [SessionManager defaultManager];

        // initialize ThreadedProgressSheet
        [MBThreadedProgressSheetController standardProgressSheetController];
        
        // init default progress overlay controller
        [ProgressOverlayViewController defaultController];
        
        [[SwordLocaleManager defaultManager] initLocale];
        [[FilterProviderFactory factory] initWith:[[EloquentFilterProvider alloc] init]];
        
        SwordManager *sm = [self setupDefaultSwordManager];
                
        // make available all cipher keys to SwordManager
        NSDictionary *cipherKeys = [UserDefaults objectForKey:DefaultsModuleCipherKeysKey];
        for(NSString *modName in cipherKeys) {
            NSString *key = cipherKeys[modName];
            [sm setCipherKey:key forModuleNamed:modName];
        }
        
        // init indexing manager, set base index path
        IndexingManager *im = [IndexingManager sharedManager];
        [im setBaseIndexPath:[[FolderUtil urlForIndexFolder] path]];
        [im setSwordManager:sm];
        
        
//        => Installing one module seems to hide the bundled KJV module!
    }
    
    return self;
}

- (SwordManager *)setupDefaultSwordManager {
    SwordManager *sm = [[SwordManager alloc] initWithPath:[[Configuration config] defaultModulePath]];
    [sm useAsDefaultManager];
    
    // check for installed modules, if there are none add our internal module path so that the user at least has one module (KJV)
    NSDictionary *allModules = [sm allModules];
    if([allModules count] == 0) {
        [self addInternalModules];
    } else {
        // we also want the KJV to be added if there are installed modules but not the KJV
        if([allModules count] > 0 && allModules[@"KJV"] == nil) {
            [self addInternalModules];
        }
    }
    return sm;
}


- (void)awakeFromNib {

#ifndef APPSTORE
    sparkleUpdater = [[SUUpdater alloc] init];

    // add sparkle "Check for updates..." menu item to help menu
    [helpMenu addItem:[NSMenuItem separatorItem]];
    [helpMenu addItemWithTitle:NSLocalizedString(@"Menu_CheckForUpdates", @"") action:@selector(checkForUpdates:) keyEquivalent:@""];

    // add linking of Sword utilities
    [helpMenu addItem:[NSMenuItem separatorItem]];
    [helpMenu addItemWithTitle:NSLocalizedString(@"Menu_LinkSwordUtils", @"") action:@selector(linkSwordUtils:) keyEquivalent:@""];
    [helpMenu addItemWithTitle:NSLocalizedString(@"Menu_UnLinkSwordUtils", @"") action:@selector(unlinkSwordUtils:) keyEquivalent:@""];

#endif
}

- (SingleViewHostController *)openSingleHostWindowForModuleType:(ModuleType)aModuleType {
    SingleViewHostController *svh = [[SingleViewHostController alloc] init];
    [[SessionManager defaultManager] addWindow:svh];
    svh.delegate = self;
    
    ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModuleType:aModuleType];
    [svh addContentViewController:hc];
    
    [svh showWindow:self];
    
    return svh;
}

/** opens a new single host window for the given module */
- (SingleViewHostController *)openSingleHostWindowForModule:(SwordModule *)mod {
    if(mod == nil) {
        NSString *sBible = [UserDefaults stringForKey:DefaultsBibleModule];
        if(sBible == nil) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"Information", @"")];
            [alert setInformativeText:NSLocalizedString(@"NoDefaultBibleSelectedText", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"")];
            [alert runModal];
        } else {
            mod = [[SwordManager defaultManager] moduleWithName:sBible];
        }
    }
    
    SingleViewHostController *svh = [[SingleViewHostController alloc] init];
    [[SessionManager defaultManager] addWindow:svh];
    svh.delegate = self;
    
    ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:mod];
    [svh addContentViewController:hc];

    [svh showWindow:self];

    return svh;
}

- (SingleViewHostController *)openSingleHostWindowForNote:(FileRepresentation *)fileRep {
    SingleViewHostController *svh = [[SingleViewHostController alloc] init];
    [[SessionManager defaultManager] addWindow:svh];
    svh.delegate = self;
    
    ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createNotesViewControllerForFileRep:fileRep];
    [svh addContentViewController:hc];    
    
    [svh showWindow:self];

    return svh;
}

#pragma mark - NSApplication delegates

- (void)application:(NSApplication *)sender openFiles:(NSArray *)fileNames {
    CocoLog(LEVEL_DEBUG, @"got file names:");
    for(NSString *filename in fileNames) {
        CocoLog(LEVEL_DEBUG, @"filename: %@", filename);
                
        NSString *moduleFilename = [filename lastPathComponent];
        NSString *moduleName = [moduleFilename componentsSeparatedByString:@".swd"][0];
        CocoLog(LEVEL_DEBUG, @"Have module name: %@", moduleName);
        
        SwordManager *swMgr = [SwordManager defaultManager];
        
        if([swMgr moduleWithName:moduleName] == nil) {
            CocoLog(LEVEL_DEBUG, @"Don't know module: %@", moduleName);
            // we don't know this module
            // ask user whether to copy this module to the repository for permanent use
            // or to only use it temporarily
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"Information", @"")];
            [alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"ModuleXYNotInRepoWantToCopy", @""), moduleName]];
            [alert addButtonWithTitle:NSLocalizedString(@"Permanent", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"Temporary", @"")];

            NSString *destinationPath = filename;
            if([alert runModal] == NSAlertFirstButtonReturn) {
                CocoLog(LEVEL_DEBUG, @"User chose to permanently use this module.");
                destinationPath = [[[FolderUtil urlForModulesFolder] path] stringByAppendingPathComponent:moduleFilename];

                CocoLog(LEVEL_DEBUG, @"Copying module %@ to %@", filename, destinationPath);
                NSFileManager *fm = [NSFileManager defaultManager];
                [fm copyItemAtPath:filename toPath:destinationPath error:nil];
            }
            // augment module
            CocoLog(LEVEL_DEBUG, @"Augmenting module at: %@", destinationPath);
            [swMgr addModulesPath:destinationPath];
            // open single window
            SwordModule *mod = [swMgr moduleWithName:moduleName];
            if(mod) {
                CocoLog(LEVEL_DEBUG, @"Opening module with name %@ in single window...", [mod name]);
                [self openSingleHostWindowForModule:mod];                
            } else {
                CocoLog(LEVEL_WARN, @"Could not retrieve module with name: %@", moduleName);
            }
        }
    }
	[sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
}

- (void)handleURLEvent:(NSAppleEventDescriptor *) event withReplyEvent:(NSAppleEventDescriptor *) replyEvent {
    NSString *urlString = [[event descriptorAtIndex:1] stringValue];
    // Normalize incoming URL string: trim whitespace/newlines and replace any newlines with spaces
    if (urlString != nil) {
        // Trim whitespace and newlines
        urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // Replace embedded newlines with spaces to keep URL parser happy
        urlString = [urlString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        // If the app receives custom eloquent:// links, convert them to sword:// which SwordUtil expects
        if ([urlString hasPrefix:@"eloquent://"]) {
            urlString = [@"sword://" stringByAppendingString:[urlString substringFromIndex:[@"eloquent://" length]]];
        }
        
        // Ensure URL is valid by adding percent-encoding if needed
        NSURL *testURL = [NSURL URLWithString:urlString];
        if (testURL == nil || testURL.scheme == nil) {
            // Try to percent-encode the path/query portion while preserving the scheme and host
            NSRange schemeRange = [urlString rangeOfString:@"://"];
            if (schemeRange.location != NSNotFound) {
                NSString *prefix = [urlString substringToIndex:schemeRange.location + schemeRange.length];
                NSString *rest = [urlString substringFromIndex:schemeRange.location + schemeRange.length];
                NSString *encodedRest = [rest stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
                if (encodedRest.length > 0) {
                    urlString = [prefix stringByAppendingString:encodedRest];
                }
            }
        }
    }
	
    // If windows/session aren't ready yet (cold launch), stash the URL and handle after launch
    if (![[SessionManager defaultManager] hasWindows]) {
        self.pendingURLString = urlString;
        CocoLog(LEVEL_DEBUG, @"Stashed pending URL for post-launch handling: %@", urlString);
        return;
    }

    NSDictionary *linkData = [SwordUtil dictionaryFromUrl:[NSURL URLWithString:urlString]];
    NSString *moduleName = linkData[ATTRTYPE_MODULE];
    NSString *passage = linkData[ATTRTYPE_VALUE];
    CocoLog(LEVEL_DEBUG, @"have module: %@", moduleName);
    CocoLog(LEVEL_DEBUG, @"have passage: %@", passage);

    if(moduleName && passage) {
        SwordModule *mod = [[SwordManager defaultManager] moduleWithName:moduleName];
        if(mod) {
            SingleViewHostController *host = [self openSingleHostWindowForModule:mod];
            [host setSearchText:passage];
            [NSApp activateIgnoringOtherApps:YES];
            [[host window] makeKeyAndOrderFront:self];
        }
    } else {
        CocoLog(LEVEL_WARN, @"have nil moduleName or passage");
    }
}

/**
 \brief is called when application loading is nearly finished
 */
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    // Register URL handler as early as possible for cold launches
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector( handleURLEvent:withReplyEvent: )
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
    if([UserDefaults boolForKey:DefaultsBackgroundIndexerEnabled]) {
        [[IndexingManager sharedManager] triggerBackgroundIndexCheck];
    }
}

/**
 \brief is called when application loading is finished
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[SessionManager defaultManager] loadSession];

    // if there is no window in the session open add a new workspace
    if(![[SessionManager defaultManager] hasWindows]) {
        WorkspaceViewHostController *svh = [[WorkspaceViewHostController alloc] init];
        svh.delegate = self;
        [[SessionManager defaultManager] addWindow:svh];
    } else {
        [[SessionManager defaultManager] addDelegateToHosts:self];
    }

    if([UserDefaults boolForKey:DefaultsShowHUDPreview]) {
        [self showPreviewPanel:nil];
    }

    if([UserDefaults boolForKey:DefaultsShowDailyDevotionOnStartupKey]) {
        [self showDailyDevotionPanel:nil];
    }

    // Removed URL handler registration here as it is done earlier in applicationWillFinishLaunching

    [SwordUrlProtocol setup];

    [[SessionManager defaultManager] showAllWindows];
    
    // Handle any URL that arrived before windows were ready (cold start)
    if (self.pendingURLString.length > 0) {
        CocoLog(LEVEL_DEBUG, @"Processing pending URL after launch: %@", self.pendingURLString);
        NSString *urlString = self.pendingURLString;
        self.pendingURLString = nil;
        // Defer to next runloop to ensure windows are fully shown
        dispatch_async(dispatch_get_main_queue(), ^{
            // Ensure there is at least one window/host
            if (![[SessionManager defaultManager] hasWindows]) {
                WorkspaceViewHostController *svh = [[WorkspaceViewHostController alloc] init];
                svh.delegate = self;
                [[SessionManager defaultManager] addWindow:svh];
                [svh showWindow:self];
            }
            NSDictionary *linkData = [SwordUtil dictionaryFromUrl:[NSURL URLWithString:urlString]];
            NSString *moduleName = linkData[ATTRTYPE_MODULE];
            NSString *passage = linkData[ATTRTYPE_VALUE];
            if (moduleName && passage) {
                SwordModule *mod = [[SwordManager defaultManager] moduleWithName:moduleName];
                if (mod) {
                    SingleViewHostController *host = [self openSingleHostWindowForModule:mod];
                    [host setSearchText:passage];
                    [NSApp activateIgnoringOtherApps:YES];
                    [[host window] makeKeyAndOrderFront:self];
                } else {
                    // Open a default Bible host window and bring it to front
                    NSString *sBible = [UserDefaults stringForKey:DefaultsBibleModule];
                    SwordModule *fallbackMod = nil;
                    if (sBible != nil) {
                        fallbackMod = [[SwordManager defaultManager] moduleWithName:sBible];
                    }
                    SingleViewHostController *fallbackHost = [self openSingleHostWindowForModule:fallbackMod];
                    [NSApp activateIgnoringOtherApps:YES];
                    [[fallbackHost window] makeKeyAndOrderFront:self];
                }
            } else if (moduleName) {
                // Open module even if passage missing
                SwordModule *mod = [[SwordManager defaultManager] moduleWithName:moduleName];
                if (mod) {
                    (void)[self openSingleHostWindowForModule:mod];
                }
            }
        });
    }
}

/**
\brief is called when application is terminated
*/
- (NSApplicationTerminateReply)applicationShouldTerminate:(id)sender {

    self.appIsTerminating = YES;
    
    NSUInteger termInfo = [self shutdownWindowAndSession];
    if(termInfo == NSTerminateCancel) {
        return termInfo;
    }
    
    // close logger
	[CocoLogger closeLogger];

	// we want to terminate NOW
	return NSTerminateNow;
}

- (NSUInteger)shutdownWindowAndSession {
    // check for any unsaved content
    if([[SessionManager defaultManager] hasUnsavedContent]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"Warning", @"")];
        [alert setInformativeText:NSLocalizedString(@"UnsavedContentQuit", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"Yes", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"No", @"")];
        NSInteger modalResult = [alert runModal];
        if(modalResult == NSAlertFirstButtonReturn) {
            [[SessionManager defaultManager] saveContent];
        } else if(modalResult == NSAlertSecondButtonReturn) {
            return NSTerminateCancel;
        }
    }
    
    [[SessionManager defaultManager] saveSession];
    [[IndexingManager sharedManager] storeSearchBookSets];
    
    return NSTerminateNow;
}

#pragma mark - Actions

- (IBAction)openNewSingleBibleHostWindow:(id)sender {
    NSString *sBible = [UserDefaults stringForKey:DefaultsBibleModule];
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
    [[SessionManager defaultManager] addWindow:wvh];
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
    } else {
        [previewController close];    
        isPreviewShowing = NO;
    }
    [UserDefaults setBool:isPreviewShowing forKey:DefaultsShowHUDPreview];
}

- (IBAction)showDailyDevotionPanel:(id)sender {
    
    NSString *ddModName = [UserDefaults stringForKey:DefaultsDailyDevotionModule];

    if(ddModName == nil) {
        // nothing to do here
        return;
    }
    
    SwordDictionary *ddMod = (SwordDictionary *)[[SwordManager defaultManager] moduleWithName:ddModName];
    if(dailyDevotionController == nil) {
        dailyDevotionController = [[DailyDevotionPanelController alloc] initWithDelegate:self andModule:ddMod];
        
    } else {
        [dailyDevotionController setDailyDevotionModule:ddMod];
        
    }

    // show window
    if(!isDailyDevotionShowing) {
        [dailyDevotionController showWindow:self];
        isDailyDevotionShowing = YES;
        
    } else {
        [dailyDevotionController close];    
        isDailyDevotionShowing = NO;
    }        
}

- (IBAction)showCreateModuleWindow:(id)sender {
    [[NSApplication sharedApplication] runModalForWindow:createModuleWindow];
}

- (IBAction)createCommentaryOk:(id)sender {
    
    // check for module name
    NSString *modName = [createModuleNameTextField stringValue];
    if([[SwordManager defaultManager] moduleWithName:modName] != nil) {
        // module exists already
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"ModuleNameExists", @"")];
        [alert setInformativeText:NSLocalizedString(@"ModuleNameExistsText", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"")];
        [alert runModal];
    } else {
        NSString *modPath = [SwordCommentary createCommentaryWithName:modName];
        if(modPath != nil) {
            [[SwordManager defaultManager] addModulesPath:modPath];
        }        
        
        [createModuleWindow close];
        [NSApp stopModal];
    }
}

- (IBAction)createCommentaryCancel:(id)sender {
    [createModuleWindow close];
    [NSApp stopModal];
}

- (IBAction)openAndComposeEmail:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:support@eloquent-bible-study.eu"]];
}

- (IBAction)openEloquentWikiPage:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://wiki.crosswire.org/Frontends:Eloquent"]];
}

- (IBAction)openEloquentHomePage:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.eloquent-bible-study.eu"]];
}

#ifndef APPSTORE
- (IBAction)linkSwordUtils:(id)sender {
    AuthorizationRef authorizationRef;
    OSStatus status;
    
    /* Create a new authorization reference which will later be passed to the tool. */
    status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, 
                                 kAuthorizationFlagDefaults, &authorizationRef);
    
    if(status != errAuthorizationSuccess) {
        CocoLog(LEVEL_ERR, @"Failed to create the authref: %d", status);
    } else {
        NSString *binFolder = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Contents/Resources/bin"];
        NSString *cmd = [NSString stringWithFormat:@"%@/%@", binFolder, @"link_tools.sh"];
        
        char *args[2];
        args[0] = (char *)[binFolder UTF8String];
        args[1] = NULL;
        int err = AuthorizationExecuteWithPrivileges(authorizationRef, [cmd UTF8String], 0, args, NULL);
        if(err != 0) {
            CocoLog(LEVEL_ERR, @"Error at executeWithPrivileges!");
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"Warning", @"")];
            [alert setInformativeText:NSLocalizedString(@"ErrorSWORDToolsInstallation", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"")];
            [alert runModal];
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"Information", @"")];
            [alert setInformativeText:NSLocalizedString(@"SWORDToolsInstalled", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"")];
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
        CocoLog(LEVEL_ERR, @"Failed to create the authref: %d", status);
    } else {
        NSString *cmd = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Contents/Resources/bin/unlink_tools.sh"];
        
        int err = AuthorizationExecuteWithPrivileges(authorizationRef, [cmd UTF8String], 0, NULL, NULL);
        if(err != 0) {
            CocoLog(LEVEL_ERR, @"Error at executeWithPrivileges!");
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:NSLocalizedString(@"Information", @"")];
            [alert setInformativeText:NSLocalizedString(@"SWORDToolsUninstalled", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"")];
            [alert runModal];
        }
    }    
}

- (IBAction)checkForUpdates:(id)sender {
    [sparkleUpdater checkForUpdates:sender];
}
#endif

/** stores the session to file */
- (IBAction)saveSessionAs:(id)sender {
    [[SessionManager defaultManager] saveSessionAs];
}

/** stores as default session */
- (IBAction)saveAsDefaultSession:(id)sender {
    [[SessionManager defaultManager] saveAsDefaultSession];
}

/** loads session from file */
- (IBAction)openSession:(id)sender {
    [[SessionManager defaultManager] loadSessionFrom];
}

/** open the default session */
- (IBAction)openDefaultSession:(id)sender {
    [[SessionManager defaultManager] loadDefaultSession];
}

#pragma mark - NSControl delegate methods

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if([aNotification object] == createModuleNameTextField) {
        [createModuleOKButton setEnabled:[[createModuleNameTextField stringValue] length] != 0];
    }
}

#pragma mark - host window delegate methods

- (void)hostClosing:(NSWindowController *)aHost {
    [[SessionManager defaultManager] removeWindow:(WindowHostController *)aHost];
}

- (void)auxWindowClosing:(NSWindowController *)aController {
    if([aController isKindOfClass:[MBPreferenceController class]]) {
        isPreferencesShowing = NO;
        
    } else if([aController isKindOfClass:[HUDPreviewController class]]) {
        isPreviewShowing = NO;
        if(!self.appIsTerminating) {
            [UserDefaults setBool:isPreviewShowing forKey:DefaultsShowHUDPreview];
        }
        
    } else if([aController isKindOfClass:[DailyDevotionPanelController class]]) {
        isDailyDevotionShowing = NO;
        
    }
}

@end

