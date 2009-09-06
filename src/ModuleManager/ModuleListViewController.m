
#import "ModuleListViewController.h"
#import <ModuleListObject.h>
#import <InstallSourceListObject.h>
#import <SwordManager.h>

// table column identifiers
#define TABLECOL_IDENTIFIER_MODNAME @"modname"
#define TABLECOL_IDENTIFIER_MODDESCR @"moddescr"
#define TABLECOL_IDENTIFIER_MODTYPE @"modtype"
#define TABLECOL_IDENTIFIER_MODSTATUS @"modstatus"
#define TABLECOL_IDENTIFIER_MODCIPHERED @"modciphered"
#define TABLECOL_IDENTIFIER_MODRVERSION @"modrversion"
#define TABLECOL_IDENTIFIER_MODLVERSION @"modlversion"
#define TABLECOL_IDENTIFIER_TASK @"task"

@interface ModuleListViewController (PrivateAPI)

// some setters for convenience
- (void)setModuleData:(NSMutableArray *)anArray;
- (void)setModuleSelection:(NSMutableArray *)anArray;

/** get clicked mod object in row */
- (ModuleListObject *)moduleObjectForClickedRow;

@end


@implementation ModuleListViewController (PrivateAPI)

// some setters for convenience
- (void)setModuleData:(NSMutableArray *)anArray {
    [anArray retain];
    [moduleData release];
    moduleData = anArray;    
}

- (void)setModuleSelection:(NSMutableArray *)anArray {
    [anArray retain];
    [moduleSelection release];
    moduleSelection = anArray;    
}

- (ModuleListObject *)moduleObjectForClickedRow {
    ModuleListObject *ret = nil;
    
    int clickedRow = [moduleOutlineView clickedRow];
    if(clickedRow >= 0) {
        // get row
        ret = [moduleOutlineView itemAtRow:clickedRow];
    }
    
    return ret;
}

@end

@implementation ModuleListViewController

// ------------- getter / setter -------------------
/** weak reference */
- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
}

- (id)delegate {
    return delegate;
}


- (void)setInstallSources:(NSArray *)anArray {
    [anArray retain];
    [installSources release];
    installSources = anArray;
}

- (NSArray *)installSources {
    return installSources;
}

- (id)init {

	MBLOG(MBLOG_DEBUG,@"[ModuleListViewController -init]");
    self = [super init];
    if(self) {
        // init install source array
        installSources = [[NSArray array] retain];
        // init module data array
        moduleData = [[NSMutableArray array] retain];
        // init selection
        moduleSelection = [[NSMutableArray array] retain];
    }
    
    return self;
}

- (void)dealloc {

    [self setModuleData:nil];
    [self setModuleSelection:nil];
    [self setInstallSources:nil];
    
    [super dealloc];
}

//--------------------------------------------------------------------
//----------- Nib delegates ----------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib {
	MBLOG(MBLOG_DEBUG,@"[ModuleListViewController -awakeFromNib]");
    
    // set menu
    [moduleOutlineView setMenu:moduleMenu];
}

/** update the modules with the modules in the sources list */
- (void)refreshModulesList {
    
    // prepare the module data for display
    
    // get SwordInstallSourceController
    SwordInstallSourceController *sis = [SwordInstallSourceController defaultController];
    // get default Sword Manager
    SwordManager *sw = [SwordManager defaultManager];
    
    // clear module data
    [moduleData removeAllObjects];
    
    // we have the install sources here and the modules have the state information
    for(InstallSourceListObject *listObject in installSources) {
        
        // get install Source
        SwordInstallSource *is = [listObject installSource];
        
        // compare install source modules with sword manager modules to get state info
        NSArray *modList = [sis moduleStatusInInstallSource:is baseManager:sw];        
        // loop over module list
        for(SwordModule *mod in modList) {
            // check for module type
            if(([listObject objectType] == TypeInstallSource) || 
               (([listObject objectType] == TypeModuleType) && [[listObject moduleType] isEqualToString:[mod typeString]])) {

                ModuleListObject *buf = [[[ModuleListObject alloc] init] autorelease];
                [buf setModule:mod];
                [buf setInstallSource:is];
                // add ModuleListObject to moduleData array
                [moduleData addObject:buf];
            }
        }
    }
    
    [moduleOutlineView reloadData];
}

//--------------------------------------------------------------------
//----------- NSMenu validation --------------------------------
//--------------------------------------------------------------------
/**
 \brief validate menu
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	MBLOGV(MBLOG_DEBUG, @"[ModuleListViewController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = NO;
    
    // get selected item
    // get current selected module
    if([moduleSelection count] == 1) {
        ModuleListObject *modObj = [moduleSelection objectAtIndex:0];
        
        // get menuitem tag
        int tag = [menuItem tag];
        
        // if tag is install
        if(tag == TaskInstall) {
            // install should only be active if it is not installed
            if(([[modObj module] status] & ModStatNew) > 0) {
                ret = YES;
            }
        } else if(tag == TaskRemove) {
            // remove only if module is installed
            if(([[modObj module] status] & ModStatNew) == 0) {
                ret = YES;
            }
        } else if(tag == TaskUpdate) {
            // update only if module is updateable
            if(([[modObj module] status] & ModStatUpdated) > 0) {
                ret = YES;
            }
        } else if(tag == TaskNone) {
            return YES;
        }
    } else if([moduleSelection count] > 1) {
        ret = YES;
    }
    
    return ret;
}

// ----------------------- actions -------------------------
- (IBAction)search:(id)sender {
	MBLOG(MBLOG_DEBUG,@"[ModuleListViewController -search:]");
}

// -------------------- module actions ---------------------
- (IBAction)noneTask:(id)sender {
	MBLOG(MBLOG_DEBUG,@"[ModuleListViewController -noneTask:]");
    
    if([moduleSelection count] == 0 || [moduleSelection count] == 1) {
        // get current selected module of clicked row
        ModuleListObject *clicked = [self moduleObjectForClickedRow];
        if(clicked) {
            // replace any old selected with the clicked one
            [moduleSelection removeAllObjects];
            [moduleSelection addObject:clicked];
        }
    }
    
    // get current selected module
    if([moduleSelection count] > 0) {
        for(ModuleListObject *modObj in moduleSelection) {
            // set taskid
            [modObj setTaskId:TaskNone];
            
            // unregister module from installation or removal
            if(delegate) {
                if([delegate respondsToSelector:@selector(unregister:)]) {
                    [delegate performSelector:@selector(unregister:) withObject:modObj];
                }
            }
        }                
        [moduleOutlineView reloadData];
    } else {
        MBLOG(MBLOG_ERR, @"[ModuleListViewController -installModule:] no module selected!");
    }    
}

- (IBAction)installModule:(id)sender {
	MBLOG(MBLOG_DEBUG,@"[ModuleListViewController -installModule:]");
    
    if([moduleSelection count] == 0 || [moduleSelection count] == 1) {
        // get current selected module of clicked row
        ModuleListObject *clicked = [self moduleObjectForClickedRow];
        if(clicked) {
            // replace any old selected with the clicked one
            [moduleSelection removeAllObjects];
            [moduleSelection addObject:clicked];
        }
    }
    
    // get current selected module
    if([moduleSelection count] > 0) {
        for(ModuleListObject *modObj in moduleSelection) {
            // only modules that are not installed can be registered for installation
            
            // check if module is installed already
            if((([[modObj module] status] & ModStatNew) > 0) || (([[modObj module] status] & ModStatUpdated) > 0)) {
                // set taskid
                [modObj setTaskId:TaskInstall];
                
                // register module for installation
                if(delegate) {
                    if([delegate respondsToSelector:@selector(registerForInstall:)]) {
                        [delegate performSelector:@selector(registerForInstall:) withObject:modObj];
                    }
                }
            } else {
                MBLOG(MBLOG_WARN, @"[ModuleListViewController -installModule:] module is already installed!");
            }
        }
        [moduleOutlineView reloadData];
    } else {
        MBLOG(MBLOG_ERR, @"[ModuleListViewController -installModule:] no module selected!");
    }    
}

- (IBAction)removeModule:(id)sender {
	MBLOG(MBLOG_DEBUG,@"[ModuleListViewController -removeModule:]");
    
    if([moduleSelection count] == 0 || [moduleSelection count] == 1) {
        // get current selected module of clicked row
        ModuleListObject *clicked = [self moduleObjectForClickedRow];
        if(clicked) {
            // replace any old selected with the clicked one
            [moduleSelection removeAllObjects];
            [moduleSelection addObject:clicked];
        }
    }
    
    // get current selected module
    if([moduleSelection count] > 0) {
        for(ModuleListObject *modObj in moduleSelection) {
            // only modules that are install can be removed
            
            // check if module is really installed
            if(([[modObj module] status] & ModStatNew) == 0) {
                // set taskid
                [modObj setTaskId:TaskRemove];
                
                // register module for removal
                if(delegate) {
                    if([delegate respondsToSelector:@selector(registerForRemove:)]) {
                        [delegate performSelector:@selector(registerForRemove:) withObject:modObj];
                    }
                }
            } else {
                MBLOG(MBLOG_WARN, @"[ModuleListViewController -removeModule:] module is not installed!");
            }
        }
        [moduleOutlineView reloadData];
    } else {
        MBLOG(MBLOG_ERR, @"[ModuleListViewController -removeModule:] no module selected!");
    }
}

- (IBAction)updateModule:(id)sender {
	MBLOG(MBLOG_DEBUG,@"[ModuleListViewController -updateModule:]");

    if([moduleSelection count] == 0 || [moduleSelection count] == 1) {
        // get current selected module of clicked row
        ModuleListObject *clicked = [self moduleObjectForClickedRow];
        if(clicked) {
            // replace any old selected with the clicked one
            [moduleSelection removeAllObjects];
            [moduleSelection addObject:clicked];
        }
    }
    
    // get current selected module
    if([moduleSelection count] > 0) {
        for(ModuleListObject *modObj in moduleSelection) {
            // only module that are updateable can be updated
            
            // check if module is new version
            if(([[modObj module] status] & ModStatUpdated) > 0) {
                // set taskid
                [modObj setTaskId:TaskUpdate];
                
                // register module for update
                if(delegate) {
                    if([delegate respondsToSelector:@selector(registerForUpdate:)]) {
                        [delegate performSelector:@selector(registerForUpdate:) withObject:modObj];
                    }
                }
            } else {
                MBLOG(MBLOG_INFO, @"[ModuleListViewController -updateModule:] current version of module installed!");
            }
        }        
        [moduleOutlineView reloadData];
    } else {
        MBLOG(MBLOG_ERR, @"[ModuleListViewController -updateModule:] no module selected!");
    }
}

//--------------------------------------------------------------------
//----------- NSTextField notifications ------------------------------
//--------------------------------------------------------------------
- (void)controlTextDidChange:(NSNotification *)aNotification {

	MBLOG(MBLOG_DEBUG,@"[ModuleListViewController textDidChange:]");
    if(aNotification != nil) {
        NSSearchField *sf = [aNotification object];
        
        // get text
        NSString *searchStr = [sf stringValue];
        
        if([searchStr length] > 0) {
            // create result array
            NSMutableArray *resultArray = [NSMutableArray array];
            
            // init Reg ex
            MBRegex *regex = [MBRegex regexWithPattern:searchStr];

            for(ModuleListObject *mod in moduleData) {
                // try to match against name of module
                if([regex matchIn:[[mod module] name] matchResult:nil] == MBRegexMatch) {
                    // add
                    [resultArray addObject:mod];
                }
            }
            
            // set this new array
            [self setModuleData:resultArray];
            
            // reload tableview
            [moduleOutlineView reloadData];
        } else {
            [self refreshModulesList];
        }
    }
}

//--------------------------------------------------------------------
//----------- NSOutlineView delegates ---------------------------------------
//--------------------------------------------------------------------
/**
 \brief Notification is called when the selection has changed 
 */
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	MBLOG(MBLOG_DEBUG,@"[ModuleListViewController outlineViewSelectionDidChange:]");
	
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {
            
            // remove any old selection
            [moduleSelection removeAllObjects];
            
			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			int len = [selectedRows count];
            ModuleListObject *mlo = nil;
			if(len > 0) {
				unsigned int indexes[len];
				[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
				
				for(int i = 0;i < len;i++) {
					mlo = [oview itemAtRow:indexes[i]];
                    
                    // add to array
                    [moduleSelection addObject:mlo];
				}				
            }
		} else {
			MBLOG(MBLOG_WARN,@"[ModuleListViewController outlineViewSelectionDidChange:] have a nil notification object!");
		}
	} else {
		MBLOG(MBLOG_WARN,@"[ModuleListViewController outlineViewSelectionDidChange:] have a nil notification!");
	}
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    int count = 0;
	
	if(item == nil) {
        // number of root items
        count = [moduleData count];
	}
	
	return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    
    // we only have modules here
    NSDictionary *ret = nil;
    
	if(item == nil) {
        // number of root items
        ret = [moduleData objectAtIndex:index];
	}

    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    
    id ret = (NSString *)@"";
    
    // the key of the item (which is a dictionary) is the module
    ModuleListObject *mod = (ModuleListObject *)item;

    if([[tableColumn identifier] isEqualToString:TABLECOL_IDENTIFIER_MODNAME]) {
        ret = [[mod module] name];
    } else if([[tableColumn identifier] isEqualToString:TABLECOL_IDENTIFIER_MODSTATUS]) {
        // print module status
        int stat = [[mod module] status];
        if((stat & ModStatSameVersion) == ModStatSameVersion) {
            ret = NSLocalizedString(@"ModStatSameVersion", @"");
        } else if((stat & ModStatNew) == ModStatNew) {
            ret = NSLocalizedString(@"ModStatNew", @"");
        } else if((stat & ModStatUpdated) == ModStatUpdated) {
            ret = NSLocalizedString(@"ModStatUpdated", @"");
        } else if((stat & ModStatOlder) == ModStatOlder) {
            ret = NSLocalizedString(@"ModStatOlder", @"");
        }
    } else if([[tableColumn identifier] isEqualToString:TABLECOL_IDENTIFIER_MODCIPHERED]) {
        if(([[mod module] status] & ModStatCiphered) == ModStatCiphered) {
            ret = [NSNumber numberWithBool:YES];
        } else {
            ret = [NSNumber numberWithBool:NO];        
        }
    } else if([[tableColumn identifier] isEqualToString:TABLECOL_IDENTIFIER_TASK]) {
        // for the cell we return the index number
        ret = [NSNumber numberWithInt:[mod taskId]];
        //NSMenuItemCell *mItemCell = [mItem menu
    } else if([[tableColumn identifier] isEqualToString:TABLECOL_IDENTIFIER_MODTYPE]) {
        ret = [[mod module] typeString];
    } else if([[tableColumn identifier] isEqualToString:TABLECOL_IDENTIFIER_MODRVERSION]) {
        ret = [[mod module] version];
    } else if([[tableColumn identifier] isEqualToString:TABLECOL_IDENTIFIER_MODLVERSION]) {
        
        // if the module is installed, show installed version
        if(([[mod module] status] & ModStatNew) > 0) {
            // this module is not installed
            ret = @"";
        } else {
            // get installed module
            ret = [[mod module] version];
        }
    } else if([[tableColumn identifier] isEqualToString:TABLECOL_IDENTIFIER_MODDESCR]) {
        //SwordManager *bMgr = [[mod installSource] swordManager];
        ret = [[mod module] descr];
    }
    
    return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	// display call with std font
	NSFont *font = FontStd;
	[cell setFont:font];
	// set row height according to used font
	// get font height
	//float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
	float pointSize = [font pointSize];
	[aOutlineView setRowHeight:pointSize+6];
	//[aOutlineView setRowHeight:imageHeight];
}

- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray *)oldDescriptors {

    MBLOG(MBLOG_DEBUG, @"[ModuleListViewController -sortDescriptorsDidChange:]");

    NSArray *newDescriptors = [outlineView sortDescriptors];
    // keep them
    sortDescriptors = [newDescriptors retain];
    
    // sort module array
    [moduleData sortUsingDescriptors:newDescriptors];
    
    // reload data
    [moduleOutlineView reloadData];    
}
@end
