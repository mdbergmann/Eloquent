
#import "ModuleListViewController.h"
#import "ModuleListObject.h"
#import "InstallSourceListObject.h"
#import "ObjCSword/SwordManager.h"

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

- (void)setModuleData:(NSMutableArray *)anArray;
- (void)setModuleSelection:(NSMutableArray *)anArray;

- (ModuleListObject *)moduleObjectForClickedRow;
- (void)updateModuleSelection;
- (void)refreshLanguages;

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

- (void)updateModuleSelection {
    if([moduleSelection count] == 0 || [moduleSelection count] == 1) {
        ModuleListObject *clicked = [self moduleObjectForClickedRow];
        if(clicked) {
            [moduleSelection removeAllObjects];
            [moduleSelection addObject:clicked];
        }
    }    
}

- (void)refreshLanguages {
    NSMutableArray *list = [NSMutableArray array];
    for(ModuleListObject *lo in moduleData) {
        SwordModule *mod = [lo module];
        if(![list containsObject:[mod lang]]) {
            [list addObject:[mod lang]];            
        }
    }
    [list sortUsingSelector:@selector(compare:)];

    [languagesButton removeAllItems];
    [languagesButton addItemWithTitle:NSLocalizedString(@"All", @"")];
    for(NSString *lang in list) {
        [languagesButton addItemWithTitle:lang];
    }
    
    [languagesButton selectItemWithTitle:[self langFilter]];
}

@end

@implementation ModuleListViewController

@synthesize langFilter;

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
    self = [super init];
    if(self) {
        installSources = [[NSArray array] retain];
        moduleData = [[NSMutableArray array] retain];
        moduleSelection = [[NSMutableArray array] retain];
        [self setLangFilter:NSLocalizedString(@"All", @"")];
    }
    
    return self;
}

- (void)dealloc {
    [self setModuleData:nil];
    [self setModuleSelection:nil];
    [self setInstallSources:nil];
    [self setLangFilter:nil];
    [sortDescriptors release];
    
    [super dealloc];
}

//--------------------------------------------------------------------
//----------- Nib delegates ----------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib {
    [moduleOutlineView setMenu:moduleMenu];
    [self refreshLanguages];
}

/** update the modules with the modules in the sources list */
- (void)refreshModulesList {
    // prepare the module data for display
    
    // get SwordInstallSourceController
    SwordInstallSourceManager *sis = [SwordInstallSourceManager defaultController];
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

            // check for language filter
            if([[self langFilter] isEqualToString:NSLocalizedString(@"All", @"")] ||
               [[self langFilter] isEqualToString:[mod lang]]) {

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
    }
    [self refreshLanguages];
    
    [moduleOutlineView reloadData];
}

#pragma mark - Menu validation

/**
 \brief validate menu
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if([menuItem action] == @selector(languageFilter:)) {
        return YES;
    }
    
    BOOL ret = NO;
    int selectedModuleCount = [moduleSelection count];	
	if(selectedModuleCount > 1) {
		ret = YES;
	} else {
	
		// begin fix for MACSW-172 (draymer)
		ModuleListObject *selectedObj = nil;
		ModuleListObject *accessedObj;
		ModuleListObject *modObj;
		
		// need to check to see if the module being modified is that same as the
		// module being selected.
		accessedObj = [self moduleObjectForClickedRow];	
		if(selectedModuleCount == 1) {
			selectedObj = [moduleSelection objectAtIndex:0];
		}
		
		modObj = (selectedObj == accessedObj ? selectedObj : accessedObj);
		
		// end fix for MACSW-172
		
		if(modObj != nil) {
			
			CocoLog(LEVEL_DEBUG, @"selected module: %xd", modObj);
			
			int tag = [menuItem tag];
			
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
		}
    } 
    
    return ret;
}

#pragma mark - Actions

// ----------------------- actions -------------------------
- (IBAction)search:(id)sender {
}

- (IBAction)languageFilter:(id)sender {
    [self setLangFilter:[(NSMenuItem *)sender title]];
    
    [self refreshModulesList];
}

// -------------------- module actions ---------------------
- (IBAction)noneTask:(id)sender {
    [self updateModuleSelection];
    
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
        CocoLog(LEVEL_ERR, @"no module selected!");
    }    
}

- (IBAction)installModule:(id)sender {
    [self updateModuleSelection];
    
    if([moduleSelection count] > 0) {
        for(ModuleListObject *modObj in moduleSelection) {
            // only modules that are not installed can be registered for installation
            
            // check if module is installed already
            if((([[modObj module] status] & ModStatNew) > 0) || (([[modObj module] status] & ModStatUpdated) > 0)) {
                [modObj setTaskId:TaskInstall];
                
                // register module for installation
                if(delegate) {
                    if([delegate respondsToSelector:@selector(registerForInstall:)]) {
                        [delegate performSelector:@selector(registerForInstall:) withObject:modObj];
                    }
                }
            } else {
                CocoLog(LEVEL_WARN, @"module is already installed!");
            }
        }
        [moduleOutlineView reloadData];
    } else {
        CocoLog(LEVEL_ERR, @"no module selected!");
    }    
}

- (IBAction)removeModule:(id)sender {
    [self updateModuleSelection];
    
    if([moduleSelection count] > 0) {
        for(ModuleListObject *modObj in moduleSelection) {
            // only modules that are installed can be removed
            
            // check if module is really installed
            if(([[modObj module] status] & ModStatNew) == 0) {
                [modObj setTaskId:TaskRemove];
                
                // register module for removal
                if(delegate) {
                    if([delegate respondsToSelector:@selector(registerForRemove:)]) {
                        [delegate performSelector:@selector(registerForRemove:) withObject:modObj];
                    }
                }
            } else {
                CocoLog(LEVEL_WARN, @"module is not installed!");
            }
        }
        [moduleOutlineView reloadData];
    } else {
        CocoLog(LEVEL_ERR, @"no module selected!");
    }
}

- (IBAction)updateModule:(id)sender {
    [self updateModuleSelection];
    
    if([moduleSelection count] > 0) {
        for(ModuleListObject *modObj in moduleSelection) {
            // only module that are updateable can be updated
            
            // check if module is new version
            if(([[modObj module] status] & ModStatUpdated) > 0) {
                [modObj setTaskId:TaskUpdate];
                
                // register module for update
                if(delegate) {
                    if([delegate respondsToSelector:@selector(registerForUpdate:)]) {
                        [delegate performSelector:@selector(registerForUpdate:) withObject:modObj];
                    }
                }
            } else {
                CocoLog(LEVEL_INFO, @"current version of module installed!");
            }
        }        
        [moduleOutlineView reloadData];
    } else {
        CocoLog(LEVEL_ERR, @"no module selected!");
    }
}

#pragma mark - Notifications

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if(aNotification != nil) {
        NSSearchField *sf = [aNotification object];
        
        // get text
        NSString *searchStr = [sf stringValue];
        
        if([searchStr length] > 0) {
            // create result array
            NSMutableArray *resultArray = [NSMutableArray array];
            
            // init Reg ex
            Regex *regex = [Regex regexWithPattern:searchStr];
            [regex setCaseSensitive:NO];

            for(ModuleListObject *mod in moduleData) {
                // try to match against name of module
                if([regex matchIn:[[mod module] name] matchResult:nil] == RegexMatch) {
                    [resultArray addObject:mod];
                }
            }
            [self setModuleData:resultArray];
            
            [moduleOutlineView reloadData];
        } else {
            [self refreshModulesList];
        }
    }
}

#pragma mark - NSOutlineView delegates

/**
 \brief Notification is called when the selection has changed 
 */
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {
            
            // remove any old selection
            [moduleSelection removeAllObjects];
            
			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			NSUInteger len = [selectedRows count];
            ModuleListObject *mlo;
			if(len > 0) {
				NSUInteger indexes[len];
				[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
				
				for(int i = 0;i < len;i++) {
					mlo = [oview itemAtRow:indexes[i]];
                    [moduleSelection addObject:mlo];
				}				
            }
		} else {
			CocoLog(LEVEL_WARN, @"have a nil notification object!");
		}
	} else {
		CocoLog(LEVEL_WARN, @"have a nil notification!");
	}
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    int count = 0;
	
	if(item == nil) {
        count = [moduleData count];
	}
	
	return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    
    // we only have modules here
    NSDictionary *ret = nil;
    
	if(item == nil) {
        // number of root items
        ret = [moduleData objectAtIndex:(NSUInteger)index];
	}

    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    id ret = (NSString *)@"";
    
    ModuleListObject *mod = (ModuleListObject *)item;
    if([[tableColumn identifier] isEqualToString:TABLECOL_IDENTIFIER_MODNAME]) {
        ret = [[mod module] name];
    } else if([[tableColumn identifier] isEqualToString:TABLECOL_IDENTIFIER_MODSTATUS]) {
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
            ret = [[[SwordManager defaultManager] moduleWithName:[mod moduleName]] version];
        }
    } else if([[tableColumn identifier] isEqualToString:TABLECOL_IDENTIFIER_MODDESCR]) {
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
    NSArray *newDescriptors = [outlineView sortDescriptors];
    sortDescriptors = [newDescriptors retain];
    [moduleData sortUsingDescriptors:newDescriptors];
    [moduleOutlineView reloadData];    
}

- (NSString *)outlineView:(NSOutlineView *)outlineView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tc item:(id)item mouseLocation:(NSPoint)mouseLocation {
    ModuleListObject *mod = (ModuleListObject *)item;
    return [[mod module] descr];
}

@end
