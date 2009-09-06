
#import "ModuleManageViewController.h"
#import "SwordManager.h"
#import "MBThreadedProgressSheetController.h"
#import "SwordInstallSource.h"
#import "SwordModule.h"
#import "ModuleListObject.h"
#import "InstallSourceListObject.h"
#import "IndexingManager.h"
#import "MBPreferenceController.h"
#import "globals.h"

// defaults entyr for disclainer
#define DefaultsUserDisplaimerConfirmed @"DefaultsUserDisplaimerConfirmed"

@interface ModuleManageViewController (PrivateAPI)

- (void)setInstallSourceListObjects:(NSMutableArray *)value;
- (void)setInstallDict:(NSMutableDictionary *)value;
- (void)setRemoveDict:(NSMutableDictionary *)value;

- (void)batchProcessTasks:(NSNumber *)actions;
- (void)refreshInstallSourceListObjects;

@end

@implementation ModuleManageViewController (PrivateAPI)

- (void)setInstallSourceListObjects:(NSMutableArray *)value {
    [value retain];
    [installSourceListObjects release];
    installSourceListObjects = value;    
}

- (void)setInstallDict:(NSMutableDictionary *)value {
    [value retain];
    [installDict release];
    installDict = value;
}

- (void)setRemoveDict:(NSMutableDictionary *)value {
    [value retain];
    [removeDict release];
    removeDict = value;
}

/**
 \brief batch process tasks with seperate thread to show progress in threaded progres indicator
 */
- (void)batchProcessTasks:(NSNumber *)actions {
	// if this method gets it's own ARP
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    // Cancel indicator
    BOOL isCanceled = NO;
    int error = 0;
    
    // get ThreadedProgressSheet
    MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
    [pSheet setSheetWindow:parentWindow];
    [pSheet setMinProgressValue:[NSNumber numberWithDouble:0.0]];
    [pSheet reset];
    [pSheet setShouldKeepTrackOfProgress:[NSNumber numberWithBool:YES]];
    [pSheet setIsThreaded:[NSNumber numberWithBool:YES]];
    
    if([actions intValue] == 1) {
        // set to indeterminate
        [pSheet performSelectorOnMainThread:@selector(setIsIndeterminateProgress:) 
                                 withObject:[NSNumber numberWithBool:YES]
                              waitUntilDone:YES];
    } else if([actions intValue] > 1) {
        // set to indeterminate
        [pSheet performSelectorOnMainThread:@selector(setIsIndeterminateProgress:) 
                                 withObject:[NSNumber numberWithBool:NO]
                              waitUntilDone:YES];
        [pSheet performSelectorOnMainThread:@selector(setMaxProgressValue:)
                                 withObject:actions 
                              waitUntilDone:YES];		
    }
    
    // begin sheet
    [pSheet performSelectorOnMainThread:@selector(beginSheet) 
                             withObject:nil 
                          waitUntilDone:YES];	
    
    // get controllers
    SwordInstallSourceController *sis = [SwordInstallSourceController defaultController];
    SwordManager *sm = [SwordManager defaultManager];
    
    // start animation
    [pSheet performSelectorOnMainThread:@selector(startProgressAnimation) 
                             withObject:nil 
                          waitUntilDone:YES];
    
    // first remove
    [pSheet performSelectorOnMainThread:@selector(setActionMessage:)
                             withObject:NSLocalizedString(@"Action_RemovingModules", @"") 
                          waitUntilDone:YES];
    NSEnumerator *iter = [[removeDict allKeys] objectEnumerator];
    id key;
    while((key = [iter nextObject])) {
        // check return value of sheet, has cancel been pressed?
        if([pSheet sheetReturnCode] != 0) {
            // cancel has been pressed, break import process
            isCanceled = YES;
        } else {
            // increment progress
            [pSheet performSelectorOnMainThread:@selector(incrementProgressBy:)
                                     withObject:[NSNumber numberWithDouble:1.0]
                                  waitUntilDone:YES];		
            
            ModuleListObject *modObj = [removeDict objectForKey:key];
            
            // give some messages
            [pSheet performSelectorOnMainThread:@selector(setCurrentStepMessage:)
                                     withObject:[[modObj module] name] 
                                  waitUntilDone:YES];
            // uninstall
            int stat = [sis uninstallModule:[modObj module] fromManager:sm];
            if(stat != 0) {
                error++;
            } else {
                // shall we remove the index as well?
                if([userDefaults boolForKey:DefaultsRemoveIndexOnModuleRemoval]) {
                    [[IndexingManager sharedManager] removeIndexForModuleName:[[modObj module] name]];
                }
            }
        }
    }
    [removeDict removeAllObjects];
    
    if(isCanceled == NO) {
        // then install
        [pSheet performSelectorOnMainThread:@selector(setActionMessage:)
                                 withObject:NSLocalizedString(@"Action_InstallingModules", @"") 
                              waitUntilDone:YES];
        NSEnumerator *iter = [[installDict allKeys] objectEnumerator];
        while((key = [iter nextObject])) {
            // check returnvalue of sheet, has cancel been pressed?
            if([pSheet sheetReturnCode] != 0) {
                // cancel has been pressed, break import process
                isCanceled = YES;
            } else {
                // increment progress
                [pSheet performSelectorOnMainThread:@selector(incrementProgressBy:)
                                         withObject:[NSNumber numberWithDouble:1.0]
                                      waitUntilDone:YES];		
                
                ModuleListObject *modObj = [installDict objectForKey:key];
                
                // give some messages
                [pSheet performSelectorOnMainThread:@selector(setCurrentStepMessage:)
                                         withObject:[[modObj module] name] 
                                      waitUntilDone:YES];
                // install
                int stat = [sis installModule:[modObj module] fromSource:[modObj installSource] withManager:sm];
                if(stat != 0) {
                    error++;
                }
            }
        }
        [installDict removeAllObjects];
    }
    
    // stop animation
    [pSheet stopProgressAnimation];
    
    // before ending the sheet, reinitialize the module manager
    [sm reInit];
    // also refresh the module list view
    [modListViewController refreshModulesList];
    
    // end sheet
    [pSheet performSelectorOnMainThread:@selector(endSheet) 
                             withObject:nil 
                          waitUntilDone:YES];
    
    // do some cleanup
    [pSheet setShouldKeepTrackOfProgress:[NSNumber numberWithBool:NO]];
    [pSheet setProgressAction:[NSNumber numberWithInt:NONE_PROGRESS_ACTION]];
    [pSheet reset];
        
    // release pool
    [pool release];
}

/**
 refreshes install sources for the outlineview
 */
- (void)refreshInstallSourceListObjects {

    // clear list
    [installSourceListObjects removeAllObjects];    
    
    // build new list
    SwordInstallSourceController *sis = [SwordInstallSourceController defaultController];
    NSEnumerator *iter = [[sis installSourceList] objectEnumerator];
    SwordInstallSource *is = nil;
    while((is = [iter nextObject])) {
        InstallSourceListObject *listObj = [InstallSourceListObject installSourceListObjectForType:TypeInstallSource];
        [listObj setInstallSource:is];
        [listObj setModuleType:@"All"];
        
        NSMutableArray *subList = [NSMutableArray array];
        NSEnumerator *iter2 = [[is listModuleTypes] objectEnumerator];
        NSString *modType = nil;
        while((modType = [iter2 nextObject])) {
            InstallSourceListObject *subListObj = [InstallSourceListObject installSourceListObjectForType:TypeModuleType];
            [subListObj setInstallSource:is];
            [subListObj setModuleType:modType];
            
            [subList addObject:subListObj];
        }
        
        [listObj setSubInstallSources:[NSArray arrayWithArray:subList]];
        
        // add
        [installSourceListObjects addObject:listObj];
    }
}

// ---------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------
/*
- (void)threadWillExit:(NSNotification *)notify {
	MBLOG(MBLOG_DEBUG,@"[ModuleManageViewController -threadWillExit:]");

    // send a notification that modules were added or removed
    //SendNotifyModulesChanged(nil);

	// do some cleanup here
    // reload module data
    //[[SwordManager defaultManager] reInit];
    
    // refresh the outline view
    //[modListViewController refreshModulesList];
}
*/

@end


@implementation ModuleManageViewController

// static methods
+ (NSString *)fileOpenDialog {
    int result;
    
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setCanChooseDirectories:YES];
    result = [oPanel runModalForDirectory:NSHomeDirectory() file:nil];
	
    if(result == NSOKButton)  {
        NSString *fileToOpen = [oPanel filename];
		return fileToOpen;
    } else {
		MBLOG(MBLOG_DEBUG,@"Cancel Button!");
		return nil;
	}
}

// ------------------ getter / setter -------------------
- (NSWindow *)parentWindow {
    return parentWindow;
}

- (void)setParentWindow:(NSWindow *)value {
    parentWindow = value;
}

- (id)delegate {
    return delegate;
}

- (void)setDelegate:(id)value {
    delegate = value;
}

- (NSArray *)selectedInstallSources {
    return selectedInstallSources;
}

- (void)setSelectedInstallSources:(NSArray *)value {
    [value retain];
    [selectedInstallSources release];
    selectedInstallSources = value;
}

- (BOOL)initialized {
    return initialized;
}

// ------------------- methods ----------------

- (id)init {
	return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
    return [self initWithDelegate:aDelegate parent:nil];
}

- (id)initWithDelegate:(id)aDelegate parent:(NSWindow *)aParent {

	self = [super init];
	if(self == nil) {
		MBLOG(MBLOG_ERR,@"[ModuleManageViewController -init]");		
	} else {
        
        initialized = NO;
        
        // first set delegate
        delegate = aDelegate;
        
        // set parent window
        parentWindow = aParent;
        
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(threadWillExit:)
                                                     name:NSThreadWillExitNotification object:nil];            
         */
		
        BOOL success = [NSBundle loadNibNamed:@"ModuleManageView" owner:self];
		if(success == YES) {
            
            // init selected sources
            selectedInstallSources = [[NSArray array] retain];
            
            // init registration dicts
            installDict = [[NSMutableDictionary dictionary] retain];
            removeDict = [[NSMutableDictionary dictionary] retain];
            
            // build installsource list objects
            installSourceListObjects = [[NSMutableArray array] retain];
            [self refreshInstallSourceListObjects];
            
            // reload data
            [categoryOutlineView reloadData];
            
        } else {
			MBLOG(MBLOG_ERR,@"[ModuleManageViewController]: cannot load ModuleManagerView.nib!");
		}		
	}
	
	return self;    
}

/**
 \brief finalize called by the GC
 */
- (void)dealloc {
	MBLOG(MBLOG_DEBUG,@"[ModuleManageViewController -finalize]");
    
    [self setInstallDict:nil];
    [self setRemoveDict:nil];
    [self setSelectedInstallSources:nil];
    [self setInstallSourceListObjects:nil];
    
	// dealloc object
	[super dealloc];
}

/** return the content view of this controller */
- (NSView *)contentView {
    if(splitView == nil) {
        MBLOG(MBLOG_WARN, @"[ModuleManageViewController -contentView] splitView is nil!");
    } else {
        MBLOG(MBLOG_WARN, @"[ModuleManageViewController -contentView] splitView initialized!");
    }

    return (NSView *)splitView;
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib {
	MBLOG(MBLOG_DEBUG,@"[ModuleManageViewController -awakeFromNib]");
	
    if(splitView == nil) {
        MBLOG(MBLOG_WARN, @"[ModuleManageViewController -awakeFromNib] splitView is nil!");
    } else {
        MBLOG(MBLOG_DEBUG, @"[ModuleManageViewController -awakeFromNib] splitView initialized!");
    }

    if(categoryOutlineView == nil) {
        MBLOG(MBLOG_WARN, @"[ModuleManageViewController -awakeFromNib] categoryOutlineView is nil!");
    } else {
        MBLOG(MBLOG_DEBUG, @"[ModuleManageViewController -awakeFromNib] categoryOutlineView initialized!");    
    }
    
    // set default menu
    [categoryOutlineView setMenu:installSourceMenu];    
        
    // reload data
    [categoryOutlineView reloadData];
    
    // first thing, we check the disclaimer
    if([userDefaults stringForKey:DefaultsUserDisplaimerConfirmed] == nil) {
        [[SwordInstallSourceController defaultController] setUserDisclainerConfirmed:NO];        
    } else {
        [[SwordInstallSourceController defaultController] setUserDisclainerConfirmed:[userDefaults boolForKey:DefaultsUserDisplaimerConfirmed]];
    }
    
    // check first start
    NSString *firstStartStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"FirstStartModInstaller"];
    if(firstStartStr == nil) {
        // first start
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"Yes", @"") 
                                       alternateButton:NSLocalizedString(@"No", @"")
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"FirstStart", @"")];
        if([alert runModal] == NSAlertDefaultReturn) {
            SwordInstallSourceController *sis = [SwordInstallSourceController defaultController];
            InstallSourceListObject *ilo = [[[InstallSourceListObject alloc] initWithType:TypeInstallSource] autorelease];
            [ilo setInstallSource:[[sis installSources] objectForKey:@"CrossWire"]];
            [self setSelectedInstallSources:[NSArray arrayWithObject:ilo]];
            // refresh
            [self refreshInstallSource:self];
        }
        // set user default object
        [[NSUserDefaults standardUserDefaults] setObject:@"started" forKey:@"FirstStartModInstaller"];
    } else {
        /*
        // lets show an requester and let the iser decide to check install sources
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"Yes", @"") 
                                       alternateButton:NSLocalizedString(@"No", @"")
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"AwakeCheckInstallSources", @"")];
        int stat = [alert runModal];
        if(stat == NSAlertDefaultReturn) {
            // test install sources for availability
            NSMutableArray *uis = [NSMutableArray array];
            SwordInstallSourceController *isc = [SwordInstallSourceController defaultController];
            for(SwordInstallSource *is in [isc installSourceList]) {
                
                NSString *host = [is source];
                if(![host isEqualToString:@"localhost"]) {
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@%@/mods.d", host, [is directory]]];
                    
                    NSURLResponse *response = [[NSURLResponse alloc] init];
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                    NSData *data = [NSURLConnection sendSynchronousRequest:request 
                                                         returningResponse:&response error:nil];
                    if(!data) {
                        [uis addObject:[is caption]];
                    }
                }
            }
            
            // install sources not available?
            NSMutableString *uisStr = [NSMutableString stringWithString:NSLocalizedString(@"The following install sources could not be contacted:\n", @"")];
            for(int i = 0;i < [uis count];i++) {
                if(i == 0) {
                    [uisStr appendString:[uis objectAtIndex:i]];
                } else {
                    [uisStr appendFormat:@", %@", [uis objectAtIndex:i]];
                }
            }
            if([uis count] > 0) {
                NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"")
                                                 defaultButton:NSLocalizedString(@"OK", @"") 
                                               alternateButton:nil
                                                   otherButton:nil 
                                     informativeTextWithFormat:uisStr];
                [alert runModal];        
            }        
        }        
         */
    }

    initialized = YES;    
}

//--------------------------------------------------------------------
//--------------- Module registration --------------------------------
//--------------------------------------------------------------------
- (void)unregister:(ModuleListObject *)modObj {
    
    if(modObj != nil) {
        [installDict removeObjectForKey:[[modObj module] name]];
        [removeDict removeObjectForKey:[[modObj module] name]];
    }
}

- (void)registerForInstall:(ModuleListObject *)modObj {
    // add module to install dict
    if(modObj != nil) {
        [installDict setObject:modObj forKey:[[modObj module] name]];
    }
}

- (void)registerForRemove:(ModuleListObject *)modObj {
    // add module to remove dict
    if(modObj != nil) {
        [removeDict setObject:modObj forKey:[[modObj module] name]];
    }    
}

- (void)registerForUpdate:(ModuleListObject *)modObj {
    // there no real update but we add it to both remove and install dict
    // remove action is called first    
    if(modObj != nil) {
        [removeDict setObject:modObj forKey:[[modObj module] name]];
        [installDict setObject:modObj forKey:[[modObj module] name]];
    }
    
}

/** process all the tasks we have to do */
- (void)processTasks {
        
    // count actions
    int actions = 0;
    actions += [removeDict count];
    actions += [installDict count];
            
    // start actions
    if(actions > 0) {
        
        // start on new thread
        [NSThread detachNewThreadSelector:@selector(batchProcessTasks:) toTarget:self withObject:[NSNumber numberWithInt:actions]];        
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"NoPendingTasks", @"")];
        [alert runModal];        
    }
}

- (IBAction)showDisclaimer {
    
    if([userDefaults stringForKey:DefaultsUserDisplaimerConfirmed] == nil || [userDefaults boolForKey:DefaultsUserDisplaimerConfirmed] == NO) {
        if(disclaimerWindow) {
            [[NSApplication sharedApplication] beginSheet:disclaimerWindow 
                                           modalForWindow:parentWindow 
                                            modalDelegate:self 
                                           didEndSelector:nil 
                                              contextInfo:nil];
        }        
    }
}

- (void)disclaimerSheetEnd {
    [disclaimerWindow close];
    [[NSApplication sharedApplication] endSheet:disclaimerWindow];
}

//--------------------------------------------------------------------
//----------- NSMenu validation --------------------------------
//--------------------------------------------------------------------
/**
 \brief validate menu
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	MBLOGV(MBLOG_DEBUG, @"[ModuleManageViewController -validateMenuItem:] %@", [menuItem description]);
    
    return YES;
}

//--------------------------------------------------------------------
//------------------------ IB actions --------------------------------
//--------------------------------------------------------------------

- (IBAction)syncInstallSourcesFromMasterList:(id)sender {
	MBLOG(MBLOG_DEBUG,@"[ModuleManageViewController -syncInstallSourcesFromMasterList:]");

    // get ThreadedProgressSheet
    MBThreadedProgressSheetController *ps = [MBThreadedProgressSheetController standardProgressSheetController];
    [ps setSheetWindow:parentWindow];
    [ps reset];
    [ps setSheetTitle:NSLocalizedString(@"WindowTitle_Progress", @"")];
    [ps setActionMessage:NSLocalizedString(@"Action_SynchingInstallSources", @"")];
    [ps setCurrentStepMessage:NSLocalizedString(@"ActionStep_Refreshing", @"")];
    [ps setIsThreaded:[NSNumber numberWithBool:YES]];
    [ps setIsIndeterminateProgress:[NSNumber numberWithBool:YES]];
    
    // start progress bar
    [ps beginSheet];
    [ps startProgressAnimation];
    
    // refresh master remote install source list
    if([[SwordInstallSourceController defaultController] refreshMasterRemoteInstallSourceList] == 0) {
        [[SwordInstallSourceController defaultController] reinitialize];
        [self refreshInstallSourceListObjects];
        [categoryOutlineView reloadData];
    }    

    [ps stopProgressAnimation];
    [ps endSheet];        
}

- (IBAction)addInstallSource:(id)sender {
	MBLOG(MBLOG_DEBUG,@"[ModuleManageViewController -addInstallSource:]");
    
    // empty all edit window fields
    [editISCaptionCell setStringValue:@""];
    [editISSourceCell setStringValue:@""];
    [editISDirCell setStringValue:@""];
    
    [editISType selectItemWithTitle:@"Remote"];
    [self editISTypeSelect:editISType];
    
    editingMode = EDITING_MODE_ADD;
    
    // bring up window
    [editISWindow makeKeyAndOrderFront:self];
}

- (IBAction)deleteInstallSource:(id)sender {
	MBLOG(MBLOG_DEBUG,@"[ModuleManageViewController -deleteInstallSource:]");

    // add values from current elected install source
    if([selectedInstallSources count] > 0) {
        
        // get selected install source
        InstallSourceListObject *selected = [selectedInstallSources objectAtIndex:0];
        SwordInstallSource *is = [selected installSource];
        
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"Yes", @"") 
                                       alternateButton:NSLocalizedString(@"No", @"")
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"DeleteConfirm", @"")];
        int stat = [alert runModal];
        if(stat == NSAlertDefaultReturn) {
            
            // delete this source
            SwordInstallSourceController *sis = [SwordInstallSourceController defaultController];
            [sis removeInstallSource:is];
            
            // refresh list objects
            [self refreshInstallSourceListObjects];
            
            // reload this outline view
            [categoryOutlineView reloadData];
        }
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"PleaseMakeSelection", @"")];
        [alert runModal];        
    }
}

- (IBAction)editInstallSource:(id)sender {
	MBLOG(MBLOG_DEBUG,@"[ModuleManageViewController -editInstallSource:]");
    
    // add values from current elected install source
    if([selectedInstallSources count] > 0) {
        
        // get selected install source
        InstallSourceListObject *selected = [selectedInstallSources objectAtIndex:0];
        SwordInstallSource *is = [selected installSource];
        
        [editISCaptionCell setStringValue:[is caption]];
        [editISSourceCell setStringValue:[is source]];
        [editISDirCell setStringValue:[is directory]];
        
        if([[is source] isEqualToString:@"localhost"]) {
            [editISType selectItemWithTitle:@"Local"];
        } else {
            [editISType selectItemWithTitle:@"Remote"];        
        }
        // call type change
        [self editISTypeSelect:editISType];
        
        editingMode = EDITING_MODE_EDIT;
        
        // bring up window
        [editISWindow makeKeyAndOrderFront:self];        
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"PleaseMakeSelection", @"")];
        [alert runModal];        
    }
}

- (IBAction)refreshInstallSource:(id)sender {
	MBLOG(MBLOG_DEBUG,@"[ModuleManageViewController -refreshInstallSource:]");
    
    if([selectedInstallSources count] == 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"PleaseMakeSelection", @"")];
        [alert runModal];
    } else {
        // get ThreadedProgressSheet
        MBThreadedProgressSheetController *ps = [MBThreadedProgressSheetController standardProgressSheetController];
        [ps setSheetWindow:parentWindow];
        [ps setSheetTitle:NSLocalizedString(@"WindowTitle_Progress", @"")];
        [ps setActionMessage:NSLocalizedString(@"Action_RefreshingInstallSourceAction", @"")];
        [ps setCurrentStepMessage:NSLocalizedString(@"ActionStep_Refreshing", @"")];
        [ps setIsThreaded:[NSNumber numberWithBool:YES]];
        [ps setIsIndeterminateProgress:[NSNumber numberWithBool:YES]];

        // the controller
        SwordInstallSourceController *sis = [SwordInstallSourceController defaultController];
        
        // start progress bar
        [ps beginSheet];
        [ps startProgressAnimation];
        
        int stat = 0;
        for(InstallSourceListObject *source in selectedInstallSources) {
            stat = [sis refreshInstallSource:[source installSource]];
            if(stat != 0) {
                MBLOG(MBLOG_ERR, @"[ModuleManageViewController -refreshInstallSource:] error on refreshing install source!");
                break;
            }
        }

        if(stat != 0) {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"")
                                             defaultButton:NSLocalizedString(@"OK", @"") 
                                           alternateButton:nil
                                               otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"ErrorOnRefreshingModules", @"")];
            [alert runModal];            
        } else {
            // re initialize sis
            //[[SwordManager defaultManager] reInit];
            [sis reinitialize];
        }
        
        // remove selection
        [self setSelectedInstallSources:[NSArray array]];
        [categoryOutlineView deselectAll:self];
        [categoryOutlineView reloadData];
        
        // refresh install source list and reload
        [self refreshInstallSourceListObjects];
        [categoryOutlineView reloadData];
        
        // set selection to none and reload
        [modListViewController setInstallSources:[NSArray array]];
        [modListViewController refreshModulesList];
        
        [ps stopProgressAnimation];
        [ps endSheet];                
    }
}

//--------------------------------------------------------------------
//--------------- Add/Edit IS actions --------------------------------
//--------------------------------------------------------------------
- (IBAction)editISOKButton:(id)sender {

    // get controller
    SwordInstallSourceController *sis = [SwordInstallSourceController defaultController];
    
    // error state
    BOOL error = NO;
    // close window?
    BOOL close = YES;
    
    // check for valid values in all fields
    if(([[editISCaptionCell stringValue] length] == 0) ||
       ([[editISDirCell stringValue] length] == 0) ||
       ([[editISSourceCell stringValue] length] == 0)) {
        
        // not valid
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"OneOrMoreEmptyFields", @"")];
        [alert runModal];
        
        error = YES;
        close = NO;
    } else {
        // valid
        if(editingMode == EDITING_MODE_EDIT) {
            // on editing mode, there must be a selected is
            // add values from current elected install source
            if([selectedInstallSources count] > 0) {
                
                // get selected install source
                InstallSourceListObject *selected = [selectedInstallSources objectAtIndex:0];
                SwordInstallSource *is = [selected installSource];
                
                // remove and re-add
                [sis removeInstallSource:is];
                
                // we will create anew one and add it below
                
            } else {
                MBLOG(MBLOG_ERR, @"[ModuleManageViewController editISOKButton:] no selected install source!");
                error = YES;
            }
        }
    }

    if(error == NO) {
        
        // create install source with values from form
        SwordInstallSource *is = [[SwordInstallSource alloc] initWithType:@"FTP"];
        
        [is setCaption:[editISCaptionCell stringValue]];
        [is setDirectory:[editISDirCell stringValue]];
        [is setSource:[editISSourceCell stringValue]];
        // add the source
        [sis addInstallSource:is];
        
        // refresh list objects
        [self refreshInstallSourceListObjects];
        
        // reload outline view
        [categoryOutlineView reloadData];
    }
    
    if(close) {
        // close window
        [editISWindow close];
    }
}

- (IBAction)editISCancelButton:(id)sender {
    
    // close window
    [editISWindow close];    
}

- (IBAction)editISTestButton:(id)sender {
    
    NSString *dir = [editISDirCell stringValue];
    NSString *host = [editISSourceCell stringValue];
    
    NSData *data = nil;
    if([host isEqualToString:@"localhost"]) {
        // check for existance of directory
        NSString *modDir = [dir stringByAppendingPathComponent:@"mods.d"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if([fm fileExistsAtPath:modDir]) {
            data = [NSData data];
        }
    } else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@%@/mods.d", host, dir]];
        
        NSURLResponse *response = [[NSURLResponse alloc] init];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        data = [NSURLConnection sendSynchronousRequest:request 
                                             returningResponse:&response error:nil];        
    }
    
    // if data is not nil, this URL is valid
    if(!data) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"ISNotValid", @"")];
        [alert runModal];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Info", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"ISValidInformation", @"")];
        [alert runModal];        
    }
}

- (IBAction)editISDirSelectButton:(id)sender {
    MBLOG(MBLOG_DEBUG, @"[ModuleManageViewController -editISDirSelectButton:]");

    NSString *filePath = [ModuleManageViewController fileOpenDialog];
    if(filePath != nil) {
        [editISDirCell setStringValue:filePath];
    }
}

- (IBAction)editISTypeSelect:(id)sender {
    MBLOG(MBLOG_DEBUG, @"[ModuleManageViewController -editISTypeSelect:]");
    
    // check selected tag
    int tag = [[editISType selectedCell] tag];
    if(tag == TYPE_TAG_REMOTE) {
        // hide directory button
        [editISDirSelect setHidden:YES];
        // enable host field but make empty
        [editISSourceCell setEnabled:YES];
    } else if(tag == TYPE_TAG_LOCAL) {
        // show dir button
        [editISDirSelect setHidden:NO];
        // set localost and disable host field
        [editISSourceCell setStringValue:@"localhost"];
        [editISSourceCell setEnabled:NO];
    }
}

// disclaimer window actions
- (IBAction)confirmNo:(id)sender {
    [userDefaults setBool:NO forKey:DefaultsUserDisplaimerConfirmed];
    [[SwordInstallSourceController defaultController] setUserDisclainerConfirmed:NO];
    // end sheet
    [self disclaimerSheetEnd];
}

- (IBAction)confirmYes:(id)sender {
    [userDefaults setBool:YES forKey:DefaultsUserDisplaimerConfirmed];    
    [[SwordInstallSourceController defaultController] setUserDisclainerConfirmed:YES];
    // end sheet
    [self disclaimerSheetEnd];
}

//--------------------------------------------------------------------
//----------- NSOutlineView delegates --------------------------------
//--------------------------------------------------------------------
/**
 \brief Notification is called when the selection has changed 
 */
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	MBLOG(MBLOG_DEBUG,@"[ModuleManageViewController outlineViewSelectionDidChange:]");
	
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {

			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			int len = [selectedRows count];
			NSMutableArray *selection = [NSMutableArray arrayWithCapacity:len];
            NSDictionary *item = nil;
			if(len > 0) {
				unsigned int indexes[len];
				[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
				
				for(int i = 0;i < len;i++) {
                    item = [oview itemAtRow:indexes[i]];
                    
                    // add to array
                    [selection addObject:item];
				}
				
                // set install source menu
                [oview setMenu:installSourceMenu];
            }

            // update modules
            NSArray *selected = [NSArray arrayWithArray:selection];
            [self setSelectedInstallSources:selected];
            [modListViewController setInstallSources:selected];
            [modListViewController refreshModulesList];
		} else {
			MBLOG(MBLOG_WARN,@"[ModuleManageViewController outlineViewSelectionDidChange:] have a nil notification object!");
		}
	} else {
		MBLOG(MBLOG_WARN,@"[ModuleManageViewController outlineViewSelectionDidChange:] have a nil notification!");
	}
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    int count = 0;
	
    // cast object
    InstallSourceListObject *listObject = (InstallSourceListObject *)item;
    
	if(item == nil) {
        // number of root items
        count = [installSourceListObjects count];
	} else if([listObject objectType] == TypeInstallSource) {
        count = [[listObject subInstallSources] count];
    }
	
	return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {

    // we only hace install Sources here
    InstallSourceListObject *ret = nil;
    
    // cast object
    InstallSourceListObject *listObject = (InstallSourceListObject *)item;

    if(item == nil) {
        // the return item will be a InstallSourceListObject
        ret = [installSourceListObjects objectAtIndex:index];
    } else if([listObject objectType] == TypeInstallSource) {
        ret = [[listObject subInstallSources] objectAtIndex:index];
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    
    NSString *ret = @"test";
    
    // cast object
    InstallSourceListObject *listObject = (InstallSourceListObject *)item;
    
    if(item != nil) {
        if([listObject objectType] == TypeInstallSource) {
            ret = [[listObject installSource] caption];
        } else {
            ret = [listObject moduleType];
        }
    }
    
    return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    
    // cast object
    InstallSourceListObject *listObject = (InstallSourceListObject *)item;

    if(item != nil && ([listObject objectType] == TypeInstallSource)) {
        return YES;
    }
    
    return NO;
}

@end
