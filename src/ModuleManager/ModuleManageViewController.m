#import <ObjCSword/ObjCSword.h>
#import "ModuleManageViewController.h"
#import "MBThreadedProgressSheetController.h"
#import "ModuleListObject.h"
#import "InstallSourceListObject.h"
#import "IndexingManager.h"
#import "MBPreferenceController.h"
#import "globals.h"
#import "ModuleListViewController.h"

// defaults entry for disclaimer
#define DefaultsUserDisclaimerConfirmed @"DefaultsUserDisplaimerConfirmed"

@interface ModuleManageViewController ()

- (void)batchProcessTasks:(NSNumber *)actions;
- (void)refreshInstallSourceListObjects;
- (BOOL)checkDisclaimerValueAndShowAlertText:(NSString *)aText;
- (void)showRefreshRepositoryInformation;

@end


@implementation ModuleManageViewController

@synthesize delegate;
@synthesize parentWindow ;
@synthesize selectedInstallSources;

// static methods
+ (NSURL *)fileOpenDialog {
    int result;
    
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setCanChooseDirectories:YES];
    result = [oPanel runModal];
	
    if(result == NSOKButton)  {
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
        
        delegate = aDelegate;        
        parentWindow = aParent;
        
        BOOL success = [NSBundle loadNibNamed:@"ModuleManageView" owner:self];
		if(success == YES) {
            selectedInstallSources = [[NSArray array] retain];
            
            installDict = [[NSMutableDictionary dictionary] retain];
            removeDict = [[NSMutableDictionary dictionary] retain];
            
            installSourceListObjects = [[NSMutableArray array] retain];
            [self refreshInstallSourceListObjects];
            
            [categoryOutlineView reloadData];            
        } else {
			CocoLog(LEVEL_ERR,@"cannot load ModuleManagerView.nib!");
		}		
	}
	
	return self;    
}

- (void)finalize {    
	[super finalize];
}

- (void)dealloc {
    [selectedInstallSources release];
    [installDict release];
    [removeDict release];
    [installSourceListObjects release];

    [super dealloc];
}

- (void)awakeFromNib {
    // set default menu
    [categoryOutlineView setMenu:installSourceMenu];    
    [categoryOutlineView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    
    // reload data
    [categoryOutlineView reloadData];
    
    // first thing, we check the disclaimer
    if([userDefaults stringForKey:DefaultsUserDisclaimerConfirmed] == nil) {
        [[SwordInstallSourceManager defaultController] setUserDisclaimerConfirmed:NO];
    } else {
        [[SwordInstallSourceManager defaultController] setUserDisclaimerConfirmed:[userDefaults boolForKey:DefaultsUserDisclaimerConfirmed]];
    }
    
    initialized = YES;    
}

#pragma mark - Methods

- (NSView *)contentView {
    return splitView;
}

- (void)unregister:(ModuleListObject *)modObj {    
    if(modObj != nil) {
        [installDict removeObjectForKey:[[modObj module] name]];
        [removeDict removeObjectForKey:[[modObj module] name]];
    }
}

- (void)registerForInstall:(ModuleListObject *)modObj {
    if(modObj != nil) {
        [installDict setObject:modObj forKey:[[modObj module] name]];
    }
}

- (void)registerForRemove:(ModuleListObject *)modObj {
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
    // start actions
    if([self hasTasks]) {
        [self checkDisclaimerValueAndShowAlertText:NSLocalizedString(@"OnlyRemoveAndInstallForLocalSources", @"")];
        // start on new thread
        [NSThread detachNewThreadSelector:@selector(batchProcessTasks:) toTarget:self withObject:[NSNumber numberWithInt:[self numberOfTasks]]];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"NoPendingTasks", @"")];
        [alert runModal];        
    }
}

- (NSInteger)numberOfTasks {
    int actions = 0;
    actions += [removeDict count];
    actions += [installDict count];
    return actions;
}

- (BOOL)hasTasks {
    return [self numberOfTasks] > 0;
}

- (IBAction)showDisclaimer {
    if([userDefaults stringForKey:DefaultsUserDisclaimerConfirmed] == nil || [userDefaults boolForKey:DefaultsUserDisclaimerConfirmed] == NO) {
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
    [userDefaults setBool:NO forKey:DefaultsUserDisclaimerConfirmed];
    [[SwordInstallSourceManager defaultController] setUserDisclaimerConfirmed:NO];
    // end sheet
    [self disclaimerSheetEnd];
}

- (IBAction)confirmYes:(id)sender {
    [userDefaults setBool:YES forKey:DefaultsUserDisclaimerConfirmed];
    [[SwordInstallSourceManager defaultController] setUserDisclaimerConfirmed:YES];
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
        
        if([removeDict count] > 0) {
            [ret appendString:NSLocalizedString(@"TaskPreview_RemoveHeading", @"")];        
            for(ModuleListObject *modObj in [removeDict allValues]) {
                [ret appendFormat:NSLocalizedString(@"TaskPreview_RemoveModule", @""), [modObj moduleName]];
            }
            [ret appendString:@"\n"];
        }
        
        if([installDict count] > 0) {
            [ret appendString:NSLocalizedString(@"TaskPreview_InstallHeading", @"")];        
            for(ModuleListObject *modObj in [installDict allValues]) {
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
        [ps setIsThreaded:[NSNumber numberWithBool:YES]];
        [ps setIsIndeterminateProgress:[NSNumber numberWithBool:YES]];
        
        // start progress bar
        [ps beginSheet];
        [ps startProgressAnimation];
        
        // refresh master remote install source list
        if([[SwordInstallSourceManager defaultController] refreshMasterRemoteInstallSourceList] == 0) {
            [[SwordInstallSourceManager defaultController] reinitialize];
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
            SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultController];
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
    if([selectedInstallSources count] == 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"PleaseMakeSelection", @"")];
        [alert runModal];
    } else {
        if([self checkDisclaimerValueAndShowAlertText:NSLocalizedString(@"UnavailableOptionDueToNoDisclaimerComfirm", @"")]) {
            // get ThreadedProgressSheet
            MBThreadedProgressSheetController *ps = [MBThreadedProgressSheetController standardProgressSheetController];
            [ps setSheetWindow:parentWindow];
            [ps setSheetTitle:NSLocalizedString(@"WindowTitle_Progress", @"")];
            [ps setActionMessage:NSLocalizedString(@"Action_RefreshingInstallSourceAction", @"")];
            [ps setCurrentStepMessage:NSLocalizedString(@"ActionStep_Refreshing", @"")];
            [ps setIsThreaded:[NSNumber numberWithBool:YES]];
            [ps setIsIndeterminateProgress:[NSNumber numberWithBool:YES]];

            // the controller
            SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultController];
            
            // start progress bar
            [ps beginSheet];
            [ps startProgressAnimation];
            
            int stat = 0;
            for(InstallSourceListObject *source in selectedInstallSources) {
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
                                     informativeTextWithFormat:NSLocalizedString(@"ErrorOnRefreshingModules", @"")];
                [alert runModal];            
            } else {
                [sis reinitialize];
            }
            
            // set selection to none and reload
            [modListViewController setInstallSources:[NSArray array]];
            [modListViewController refreshModulesList];

            // the following lines are nonsense
            // TODO: find better way for refreshing the module list.
            [self setSelectedInstallSources:[NSArray array]];
            [categoryOutlineView deselectAll:self];
            [categoryOutlineView reloadData];
            
            // refresh install source list and reload
            [self refreshInstallSourceListObjects];
            [categoryOutlineView reloadData];
                    
            [ps stopProgressAnimation];
            [ps endSheet];
        }
    }
}

- (IBAction)editISOKButton:(id)sender {
    SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultController];
    
    BOOL error = NO;
    BOOL close = YES;
    
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
                CocoLog(LEVEL_ERR, @"no selected install source!");
                error = YES;
            }
        }
    }

    if(error == NO) {
        
        SwordInstallSource *is = [[[SwordInstallSource alloc] initWithType:@"FTP"] autorelease];
        
        [is setCaption:[editISCaptionCell stringValue]];
        [is setDirectory:[editISDirCell stringValue]];
        [is setSource:[editISSourceCell stringValue]];

        [sis addInstallSource:is];
        
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
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@%@/mods.d", host, dir]];
            
            NSURLResponse *response = [[[NSURLResponse alloc] init] autorelease];
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
                             informativeTextWithFormat:NSLocalizedString(@"ISNotValid", @"")];
        [alert runModal];
    } else {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") 
                                       alternateButton:nil
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"ISValidInformation", @"")];
        [alert runModal];        
    }
}

- (IBAction)editISDirSelectButton:(id)sender {
    NSURL *fileUrl = [ModuleManageViewController fileOpenDialog];
    if(fileUrl != nil) {
        [editISDirCell setStringValue:[fileUrl absoluteString]];
    }
}

- (IBAction)editISTypeSelect:(id)sender {
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
        // set localhost and disable host field
        [editISSourceCell setStringValue:@"localhost"];
        [editISSourceCell setEnabled:NO];
    }
}

//--------------------------------------------------------------------
//----------- NSOutlineView delegates --------------------------------
//--------------------------------------------------------------------
/**
 \brief Notification is called when the selection has changed 
 */
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {

			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			NSUInteger len = [selectedRows count];
			NSMutableArray *selection = [NSMutableArray arrayWithCapacity:len];
            NSDictionary *item;
			if(len > 0) {
				NSUInteger indexes[len];
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
			CocoLog(LEVEL_WARN,@"have a nil notification object!");
		}
	} else {
		CocoLog(LEVEL_WARN,@"have a nil notification!");
	}
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    int count = 0;
	
    InstallSourceListObject *listObject = (InstallSourceListObject *)item;    
	if(item == nil) {
        // number of root items
        count = [installSourceListObjects count];
	} else if([listObject objectType] == TypeInstallSource) {
        count = [[listObject subInstallSources] count];
    }
	
	return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    InstallSourceListObject *ret = nil;
    
    InstallSourceListObject *listObject = (InstallSourceListObject *)item;
    if(item == nil) {
        // the return item will be a InstallSourceListObject
        ret = [installSourceListObjects objectAtIndex:(NSUInteger)index];
    } else if([listObject objectType] == TypeInstallSource) {
        ret = [[listObject subInstallSources] objectAtIndex:(NSUInteger)index];
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    NSString *ret = @"test";
    
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
    InstallSourceListObject *listObject = (InstallSourceListObject *)item;
    if(item != nil && ([listObject objectType] == TypeInstallSource)) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Private stuff

/**
 \brief batch process tasks with separate thread to show progress in threaded progress indicator
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
    SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultController];
    SwordManager *sm = [SwordManager defaultManager];

    // start animation
    [pSheet performSelectorOnMainThread:@selector(startProgressAnimation)
                             withObject:nil
                          waitUntilDone:YES];

    // first remove
    [pSheet performSelectorOnMainThread:@selector(setActionMessage:)
                             withObject:NSLocalizedString(@"Action_RemovingModules", @"")
                          waitUntilDone:YES];

    for(id key in [removeDict allKeys]) {
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
        for (id key in [installDict allKeys]) {
            // check return value of sheet, has cancel been pressed?
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
                SwordInstallSource *is = [modObj installSource];
                if([is isLocalSource] || [sis userDisclaimerConfirmed]) {
                    int stat = [sis installModule:[modObj module] fromSource:is withManager:sm];
                    if(stat != 0) {
                        error++;
                    }
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
 refreshes install sources for the outline view
 */
- (void)refreshInstallSourceListObjects {

    // clear list
    [installSourceListObjects removeAllObjects];

    // build new list
    SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultController];
    for(SwordInstallSource *is in [sis installSourceList]) {
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

        // add
        [installSourceListObjects addObject:listObj];
    }
}

- (BOOL)checkDisclaimerValueAndShowAlertText:(NSString *)aText {
    SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultController];
    BOOL confirmed = [sis userDisclaimerConfirmed];
    if(!confirmed) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:aText];
        [alert runModal];
    }
    return confirmed;
}

- (void)showRefreshRepositoryInformation {
    SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultController];
    BOOL confirmed = [sis userDisclaimerConfirmed];
    if(confirmed) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"Info_RememberToRefreshRepositories", @"")];
        [alert runModal];
    }
}

@end
