#import <ObjCSword/ObjCSword.h>
#import "ModuleManageViewController.h"
#import "MBThreadedProgressSheetController.h"
#import "ModuleListObject.h"
#import "InstallSourceListObject.h"
#import "IndexingManager.h"
#import "MBPreferenceController.h"
#import "globals.h"
#import "ModuleListViewController.h"
#import "Eloquent-Swift.h"

// defaults entry for disclaimer
#define DefaultsUserDisclaimerConfirmed @"DefaultsUserDisplaimerConfirmed"

@interface ModuleManageViewController () {
    int editingMode;
    BOOL initialized;
}

- (void)refreshInstallSourceListObjects;
- (BOOL)checkDisclaimerValueAndShowAlertText:(NSString *)aText;
- (void)showRefreshRepositoryInformation;

/** the array used for display in outline view */
@property (strong, readwrite) NSMutableDictionary *installDict;
@property (strong, readwrite) NSMutableDictionary *removeDict;

@end


@implementation ModuleManageViewController

// static methods
+ (NSURL *)fileOpenDialog {
    NSInteger result;
    
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setCanChooseDirectories:YES];
    result = [oPanel runModal];
	
    if(result == NSModalResponseOK)  {
        NSURL *fileToOpen = [oPanel URL];
		return fileToOpen;
    } else {
		CocoLog(LEVEL_DEBUG, @"Cancel Button!");
		return nil;
	}
}

- (BOOL)initialized {
    return initialized;
}

#pragma mark - Initialisation

- (id)init {
	return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
    return [self initWithDelegate:aDelegate parent:nil];
}

- (id)initWithDelegate:(id)aDelegate parent:(NSWindow *)aParent {

	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"");
	} else {
        
        initialized = NO;
        
        self.delegate = aDelegate;
        self.parentWindow = aParent;
        
        BOOL success = [[NSBundle mainBundle] loadNibNamed:@"ModuleManageView" owner:self topLevelObjects:nil];
		if(success) {
            self.selectedInstallSources = [NSArray array];
            self.installDict = [NSMutableDictionary dictionary];
            self.removeDict = [NSMutableDictionary dictionary];
            
            [self refreshInstallSourceListObjects];
            
            [categoryOutlineView reloadData];            
        } else {
			CocoLog(LEVEL_ERR,@"cannot load ModuleManagerView.nib!");
		}		
	}
	
	return self;    
}

- (void)awakeFromNib {
    // set default menu
    [categoryOutlineView setMenu:installSourceMenu];    
    [categoryOutlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    
    // reload data
    [categoryOutlineView reloadData];
    
    // first thing, we check the disclaimer
    if([UserDefaults stringForKey:DefaultsUserDisclaimerConfirmed] == nil) {
        [[SwordInstallSourceManager defaultManager] setUserDisclaimerConfirmed:NO];
    } else {
        [[SwordInstallSourceManager defaultManager] setUserDisclaimerConfirmed:[UserDefaults boolForKey:DefaultsUserDisclaimerConfirmed]];
    }
    
    initialized = YES;    
}

#pragma mark - Methods

- (NSView *)contentView {
    return splitView;
}

- (void)unregister:(ModuleListObject *)modObj {    
    if(modObj != nil) {
        [self.installDict removeObjectForKey:[[modObj module] name]];
        [self.removeDict removeObjectForKey:[[modObj module] name]];
    }
}

- (void)registerForInstall:(ModuleListObject *)modObj {
    if(modObj != nil) {
        self.installDict[[[modObj module] name]] = modObj;
    }
}

- (void)registerForRemove:(ModuleListObject *)modObj {
    if(modObj != nil) {
        self.removeDict[[[modObj module] name]] = modObj;
    }    
}

- (void)registerForUpdate:(ModuleListObject *)modObj {
    // there no real update but we add it to both remove and install dict
    // remove action is called first    
    if(modObj != nil) {
        self.removeDict[[[modObj module] name]] = modObj;
        self.installDict[[[modObj module] name]] = modObj;
    }
    
}

/** process all the tasks we have to do */
- (void)processTasks {
    // start actions
    if([self hasTasks]) {
        [self checkDisclaimerValueAndShowAlertText:NSLocalizedString(@"OnlyRemoveAndInstallForLocalSources", @"")];
        // start on new thread
        dispatch_async(dispatch_queue_create("TaskProcessor", NULL), ^(void) {
            [self batchProcessTasks:[self numberOfTasks]];

            [modListViewController refreshSwordManager];
            [modListViewController refreshModulesList];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                SendNotifyModulesChanged(nil);
            });
        });
        
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:@"%@", NSLocalizedString(@"NoPendingTasks", @"")];
        [alert runModal];        
    }
}

- (NSInteger)numberOfTasks {
    int actions = 0;
    actions += [self.removeDict count];
    actions += [self.installDict count];
    return actions;
}

- (BOOL)hasTasks {
    return [self numberOfTasks] > 0;
}

- (IBAction)showDisclaimer {
    if([UserDefaults stringForKey:DefaultsUserDisclaimerConfirmed] == nil || ![UserDefaults boolForKey:DefaultsUserDisclaimerConfirmed]) {
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
    
    // tell user to refresh install sources
    [self showRefreshRepositoryInformation];
}

- (IBAction)confirmNo:(id)sender {
    [UserDefaults setBool:NO forKey:DefaultsUserDisclaimerConfirmed];
    [[SwordInstallSourceManager defaultManager] setUserDisclaimerConfirmed:NO];
    // end sheet
    [self disclaimerSheetEnd];
}

- (IBAction)confirmYes:(id)sender {
    [UserDefaults setBool:YES forKey:DefaultsUserDisclaimerConfirmed];
    [[SwordInstallSourceManager defaultManager] setUserDisclaimerConfirmed:YES];
    // end sheet
    [self disclaimerSheetEnd];
}

- (void)showTasksPreview {
    if(tasksPreviewWindow) {
        [processTasksButton setEnabled:[self hasTasks]];
        
        [tasksPreviewTextField setStringValue:[self tasksPreviewDescription]];
        [[NSApplication sharedApplication] beginSheet:tasksPreviewWindow 
                                       modalForWindow:parentWindow 
                                        modalDelegate:self 
                                       didEndSelector:nil 
                                          contextInfo:nil];
    }
    
}

- (void)tasksPreviewSheetEnd {
    [tasksPreviewWindow close];
    [[NSApplication sharedApplication] endSheet:tasksPreviewWindow];
}

- (IBAction)closePreview:(id)sender {
    [self tasksPreviewSheetEnd];
}

- (IBAction)processTasks:(id)sender {
    [self tasksPreviewSheetEnd];    
    [self processTasks];
}

/** serialize tasks for previews */
- (NSString *)tasksPreviewDescription {
    
    NSMutableString *ret = [NSMutableString string];
    
    if([self hasTasks]) {
        [ret appendString:NSLocalizedString(@"TaskPreview_Heading", @"")];
        [ret appendString:@"\n\n"];
        
        if([self.removeDict count] > 0) {
            [ret appendString:NSLocalizedString(@"TaskPreview_RemoveHeading", @"")];        
            for(ModuleListObject *modObj in [self.removeDict allValues]) {
                [ret appendFormat:NSLocalizedString(@"TaskPreview_RemoveModule", @""), [modObj moduleName]];
            }
            [ret appendString:@"\n"];
        }
        
        if([self.installDict count] > 0) {
            [ret appendString:NSLocalizedString(@"TaskPreview_InstallHeading", @"")];        
            for(ModuleListObject *modObj in [self.installDict allValues]) {
                [ret appendFormat:NSLocalizedString(@"TaskPreview_InstallModule", @""), [modObj moduleName]];
            }
            [ret appendString:@"\n"];
        }        
    } else {
        [ret appendString:NSLocalizedString(@"TaskPreview_NoTasks", @"")];
    }
    
    return ret;
}

#pragma mark - Menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    return YES;
}

#pragma mark - Actions

- (IBAction)syncInstallSourcesFromMasterList:(id)sender {
    if([self checkDisclaimerValueAndShowAlertText:NSLocalizedString(@"UnavailableOptionDueToNoDisclaimerComfirm", @"")]) {
        MBThreadedProgressSheetController *ps = [MBThreadedProgressSheetController standardProgressSheetController];
        [ps setSheetWindow:parentWindow];
        [ps reset];
        [ps setSheetTitle:NSLocalizedString(@"WindowTitle_Progress", @"")];
        [ps setActionMessage:NSLocalizedString(@"Action_SynchingInstallSources", @"")];
        [ps setCurrentStepMessage:NSLocalizedString(@"ActionStep_Refreshing", @"")];
        [ps setIsThreaded:@YES];
        [ps setIsIndeterminateProgress:@YES];
        
        // start progress bar
        [ps beginSheet];
        [ps startProgressAnimation];
        
        // refresh master remote install source list
        if([[SwordInstallSourceManager defaultManager] refreshMasterRemoteInstallSourceList] == 0) {
            [self refreshInstallSourceListObjects];
            [categoryOutlineView reloadData];
        }
        
        [ps stopProgressAnimation];
        [ps endSheet];        
    }    
}

- (IBAction)addInstallSource:(id)sender {
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
    // add values from current elected install source
    if([self.selectedInstallSources count] > 0) {
        
        // get selected install source
        InstallSourceListObject *selected = self.selectedInstallSources[0];
        SwordInstallSource *is = [selected installSource];
        
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"Yes", @"") 
                                       alternateButton:NSLocalizedString(@"No", @"")
                                           otherButton:nil 
                             informativeTextWithFormat:@"%@", NSLocalizedString(@"DeleteConfirm", @"")];
        NSInteger stat = [alert runModal];
        if(stat == NSAlertDefaultReturn) {
            
            SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultManager];
            [sis removeInstallSource:is reload:YES];
            
            [self refreshInstallSourceListObjects];
            
            [categoryOutlineView reloadData];
        }
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:@"%@", NSLocalizedString(@"PleaseMakeSelection", @"")];
        [alert runModal];
    }
}

- (IBAction)editInstallSource:(id)sender {
    // add values from current elected install source
    if([self.selectedInstallSources count] > 0) {
        
        // get selected install source
        InstallSourceListObject *selected = self.selectedInstallSources[0];
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
                             informativeTextWithFormat:@"%@", NSLocalizedString(@"PleaseMakeSelection", @"")];
        [alert runModal];        
    }
}

- (IBAction)refreshInstallSource:(id)sender {
    if([self.selectedInstallSources count] == 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"%@", NSLocalizedString(@"PleaseMakeSelection", @"")];
        [alert runModal];
        return;
    }

    if([self checkDisclaimerValueAndShowAlertText:NSLocalizedString(@"UnavailableOptionDueToNoDisclaimerComfirm", @"")]) {
        // get ThreadedProgressSheet
        MBThreadedProgressSheetController *ps = [MBThreadedProgressSheetController standardProgressSheetController];
        [ps setSheetWindow:parentWindow];
        [ps setSheetTitle:NSLocalizedString(@"WindowTitle_Progress", @"")];
        [ps setActionMessage:NSLocalizedString(@"Action_RefreshingInstallSourceAction", @"")];
        [ps setCurrentStepMessage:NSLocalizedString(@"ActionStep_Refreshing", @"")];
        [ps setIsThreaded:@YES];
        [ps setIsIndeterminateProgress:@YES];

        // the controller
        SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultManager];

        // start progress bar
        [ps beginSheet];
        [ps startProgressAnimation];

        int stat = 0;
        for(InstallSourceListObject *source in self.selectedInstallSources) {
            stat = [sis refreshInstallSource:[source installSource]];
            if(stat != 0) {
                CocoLog(LEVEL_ERR, @"Error on refreshing install source!");
                break;
            }
        }

        if(stat != 0) {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"")
                                             defaultButton:NSLocalizedString(@"OK", @"")
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"%@", NSLocalizedString(@"ErrorOnRefreshingModules", @"")];
            [alert runModal];
        }

        [modListViewController refreshModulesList];

        [ps stopProgressAnimation];
        [ps endSheet];
    }
}

- (IBAction)editISOKButton:(id)sender {
    SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultManager];
    
    BOOL error = NO;
    BOOL close = YES;

    SwordInstallSource *is;
    if(([[editISCaptionCell stringValue] length] == 0) ||
       ([[editISDirCell stringValue] length] == 0) ||
       ([[editISSourceCell stringValue] length] == 0)) {
        // not valid
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:@"%@", NSLocalizedString(@"OneOrMoreEmptyFields", @"")];
        [alert runModal];
        
        error = YES;
        close = NO;
    } else {
        if(editingMode == EDITING_MODE_EDIT) {
            // on editing mode, there must be a selected is
            // add values from current elected install source
            if([self.selectedInstallSources count] > 0) {
                
                // get selected install source
                InstallSourceListObject *selected = self.selectedInstallSources[0];
                is = [selected installSource];
                
                // remove and re-add
                [sis removeInstallSource:is reload:YES];
                
                // we will create anew one and add it below
                
            } else {
                CocoLog(LEVEL_ERR, @"no selected install source!");
                error = YES;
            }
        }
    }

    if(!error) {

        if(is == nil) { // this is "add", not "edit" operation
            is = [[SwordInstallSource alloc] initWithType:@"FTP"];
        }

        [is setCaption:[editISCaptionCell stringValue]];
        [is setDirectory:[editISDirCell stringValue]];
        [is setSource:[editISSourceCell stringValue]];

        [sis addInstallSource:is reload:YES];
        
        [self refreshInstallSourceListObjects];
        
        [categoryOutlineView reloadData];
    }
    
    if(close) {
        [editISWindow close];
    }
}

- (IBAction)editISCancelButton:(id)sender {
    [editISWindow close];    
}

- (IBAction)editISTestButton:(id)sender {
    
    NSString *dir = [editISDirCell stringValue];
    NSString *host = [editISSourceCell stringValue];
    
    NSData *data = nil;
    if([host isEqualToString:@"localhost"]) {
        // check for existence of directory
        NSString *modDir = [dir stringByAppendingPathComponent:@"mods.d"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if([fm fileExistsAtPath:modDir]) {
            data = [NSData data];
        }
    } else {
        if([self checkDisclaimerValueAndShowAlertText:NSLocalizedString(@"UnavailableOptionDueToNoDisclaimerComfirm", @"")]) {        
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@%@/mods.d.tar.gz", host, dir]];
            
            NSURLResponse *response = [[NSURLResponse alloc] init];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            data = [NSURLConnection sendSynchronousRequest:request 
                                         returningResponse:&response error:nil];
        } else {
            data = nil;
        }
    }
    
    // if data is not nil, this URL is valid
    if(!data) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:@"%@", NSLocalizedString(@"ISNotValid", @"")];
        [alert runModal];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:@"%@", NSLocalizedString(@"ISValidInformation", @"")];
        [alert runModal];        
    }
}

- (IBAction)editISDirSelectButton:(id)sender {
    NSURL *fileUrl = [ModuleManageViewController fileOpenDialog];
    if(fileUrl != nil) {
        [editISDirCell setStringValue:[fileUrl path]];
    }
}

- (IBAction)editISTypeSelect:(id)sender {
    // check selected tag
    NSInteger tag = [[editISType selectedCell] tag];
    if(tag == TYPE_TAG_REMOTE) {
        // hide directory button
        [editISDirSelect setHidden:YES];
        // enable host field but make empty
        [editISSourceCell setEnabled:YES];
    } else if(tag == TYPE_TAG_LOCAL) {
        // show dir button
        [editISDirSelect setHidden:NO];
        // set localhost and disable host field
        [editISSourceCell setStringValue:@"localhost"];
        [editISSourceCell setEnabled:NO];
    }
}

/**
 \brief batch process tasks with separate thread to show progress in threaded progress indicator
 */
- (void)batchProcessTasks:(NSInteger)actions {
    // Cancel indicator
    BOOL isCanceled = NO;
    int error = 0;

    // get ThreadedProgressSheet
    MBThreadedProgressSheetController *pSheet = [MBThreadedProgressSheetController standardProgressSheetController];
    [pSheet setSheetWindow:parentWindow];
    [pSheet setMinProgressValue:@0.0];
    [pSheet reset];
    [pSheet setShouldKeepTrackOfProgress:@YES];
    [pSheet setIsThreaded:@YES];

    if(actions == 1) {
        // set to indeterminate
        [pSheet performSelectorOnMainThread:@selector(setIsIndeterminateProgress:)
                                 withObject:@YES
                              waitUntilDone:YES];
    } else if(actions > 1) {
        // set to indeterminate
        [pSheet performSelectorOnMainThread:@selector(setIsIndeterminateProgress:)
                                 withObject:@NO
                              waitUntilDone:YES];
        [pSheet performSelectorOnMainThread:@selector(setMaxProgressValue:)
                                 withObject:@(actions)
                              waitUntilDone:YES];
    }

    // begin sheet
    [pSheet performSelectorOnMainThread:@selector(beginSheet)
                             withObject:nil
                          waitUntilDone:YES];

    // get controllers
    SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultManager];
    SwordManager *sm = [SwordManager managerWithPath:[[FolderUtil urlForModulesFolder] path]];

    // start animation
    [pSheet performSelectorOnMainThread:@selector(startProgressAnimation)
                             withObject:nil
                          waitUntilDone:YES];

    // first remove
    [pSheet performSelectorOnMainThread:@selector(setActionMessage:)
                             withObject:NSLocalizedString(@"Action_RemovingModules", @"")
                          waitUntilDone:YES];

    for(id key in [self.removeDict allKeys]) {
        // check return value of sheet, has cancel been pressed?
        if([pSheet sheetReturnCode] != 0) {
            // cancel has been pressed, break import process
            isCanceled = YES;
        } else {
            // increment progress
            [pSheet performSelectorOnMainThread:@selector(incrementProgressBy:)
                                     withObject:@1.0
                                  waitUntilDone:YES];

            ModuleListObject *modObj = self.removeDict[key];

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
                if([UserDefaults boolForKey:DefaultsRemoveIndexOnModuleRemoval]) {
                    [[IndexingManager sharedManager] removeIndexForModuleName:[[modObj module] name]];
                }
            }
        }
    }
    [self.removeDict removeAllObjects];

    if(!isCanceled) {
        // then install
        [pSheet performSelectorOnMainThread:@selector(setActionMessage:)
                                 withObject:NSLocalizedString(@"Action_InstallingModules", @"")
                              waitUntilDone:YES];
        for (id key in [self.installDict allKeys]) {
            // check return value of sheet, has cancel been pressed?
            if([pSheet sheetReturnCode] != 0) {
                // cancel has been pressed, break import process
                isCanceled = YES;
            } else {
                // increment progress
                [pSheet performSelectorOnMainThread:@selector(incrementProgressBy:)
                                         withObject:@1.0
                                      waitUntilDone:YES];

                // if this is the last item to install we can make the indicator to indeterminate
                if([pSheet progressValue] == [pSheet maxProgressValue]) {
                    [pSheet performSelectorOnMainThread:@selector(setIsIndeterminateProgress:)
                                             withObject:@YES
                                          waitUntilDone:YES];
                }

                ModuleListObject *modObj = self.installDict[key];

                // give some messages
                [pSheet performSelectorOnMainThread:@selector(setCurrentStepMessage:)
                                         withObject:[[modObj module] name]
                                      waitUntilDone:YES];
                // install
                SwordInstallSource *is = [modObj installSource];
                if([is isLocalSource] || [sis userDisclaimerConfirmed]) {
                    int stat = [sis installModule:[modObj module] fromSource:is withManager:sm];
                    if(stat != 0) {
                        error++;
                    }
                }
            }
        }
        [self.installDict removeAllObjects];
    }

    [pSheet stopProgressAnimation];

    [pSheet performSelectorOnMainThread:@selector(endSheet)
                             withObject:nil
                          waitUntilDone:YES];
    [pSheet setShouldKeepTrackOfProgress:@NO];
    [pSheet setProgressAction:@(NONE_PROGRESS_ACTION)];
    [pSheet reset];
}

/**
 refreshes install sources for the outline view
 */
- (void)refreshInstallSourceListObjects {
    NSMutableArray *listObjects = [NSMutableArray array];
    SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultManager];

    for(SwordInstallSource *is in [[[sis allInstallSources] allValues] sortedArrayUsingComparator: ^(SwordInstallSource *obj1, SwordInstallSource *obj2) {
        return [[obj1 caption] compare:[obj2 caption]];
    }]) {
        InstallSourceListObject *listObj = [InstallSourceListObject installSourceListObjectForType:TypeInstallSource];
        [listObj setInstallSource:is];
        [listObj setModuleType:@"All"];

        NSMutableArray *subList = [NSMutableArray array];
        for(NSString *modType in [is listModuleTypes]) {
            InstallSourceListObject *subListObj = [InstallSourceListObject installSourceListObjectForType:TypeModuleType];
            [subListObj setInstallSource:is];
            [subListObj setModuleType:modType];

            [subList addObject:subListObj];
        }

        [listObj setSubInstallSources:[NSArray arrayWithArray:subList]];
        [listObjects addObject:listObj];
    }
    self.installSourceListObjects = [NSArray arrayWithArray:listObjects];
}

- (BOOL)checkDisclaimerValueAndShowAlertText:(NSString *)aText {
    SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultManager];
    BOOL confirmed = [sis userDisclaimerConfirmed];
    if(!confirmed) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"%@", aText];
        [alert runModal];
    }
    return confirmed;
}

- (void)showRefreshRepositoryInformation {
    SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultManager];
    BOOL confirmed = [sis userDisclaimerConfirmed];
    if(confirmed) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"%@", NSLocalizedString(@"Info_RememberToRefreshRepositories", @"")];
        [alert runModal];
    }
}

@end
