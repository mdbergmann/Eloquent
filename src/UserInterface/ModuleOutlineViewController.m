//
//  ModuleOutlineViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 08.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ModuleOutlineViewController.h"
#import "AppController.h"
#import "BibleCombiViewController.h"
#import "HostableViewController.h"
#import "SingleViewHostController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "OutlineListObject.h"

enum ModuleMenu_Items{
    ModuleMenuOpenSingle = 1,
    ModuleMenuOpenWorkspace,
    ModuleMenuOpenCurrent
};

@interface ModuleOutlineViewController ()

/** private property */
@property(readwrite, retain) NSMutableArray *data;

/** builds the data structure for display */
- (void)buildData;
- (void)doubleClick;

@end

@implementation ModuleOutlineViewController

@synthesize manager;
@synthesize data;

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[ModuleOutlineViewController -init] loading nib");
        
        // set delegate
        self.delegate = aDelegate;
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:MODULEOUTLINEVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[ModuleOutlineViewController -init] unable to load nib!");
        } else {
            // get the default manager
            self.manager = [SwordManager defaultManager];
            
            // init data
            self.data = [NSMutableArray array];
            
            // build data
            [self buildData];
        }            
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[ModuleOutlineViewController -awakeFromNib]");

    // set double click action
    [moduleOutlineView setTarget:self];
    [moduleOutlineView setDoubleAction:@selector(doubleClick)];
    
    // loading finished
    viewLoaded = YES;
    [self reportLoadingComplete];
}

# pragma mark - methods

- (void)buildData {
    if(manager != nil) {
        // clear data
        [data removeAllObjects];
        
        // add root modules element
        OutlineListObject *obj = [[OutlineListObject alloc] initWithType:LISTOBJECTTYPE_MODULESROOT andDisplayString:@"Modules"];
        [data addObject:obj];
        
        // add module categories
        NSString *cat = nil;
        NSMutableArray *cats = [NSMutableArray array];
        for(cat in [SwordManager moduleTypes]) {
            OutlineListObject *buf = [[OutlineListObject alloc] initWithType:LISTOBJECTTYPE_MODULECATEGORY andDisplayString:cat];
            [cats addObject:buf];
            
            // add modules for category
            SwordModule *mod = nil;
            NSMutableArray *mods = [NSMutableArray array];
            for(mod in [manager modulesForType:cat]) {
                OutlineListObject *modBuf = [[OutlineListObject alloc] initWithType:LISTOBJECTTYPE_MODULE andDisplayString:[mod name]];
                modBuf.listObject = mod;
                [mods addObject:modBuf];
            }
            // add array
            buf.listObject = mods;
        }
        // add array
        obj.listObject = cats;
    }
}

#pragma mark - Module menu

//--------------------------------------------------------------------
//----------- NSMenu validation --------------------------------
//--------------------------------------------------------------------
/**
 \brief validate menu
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	MBLOGV(MBLOG_DEBUG, @"[ModuleOutlineViewController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = YES;
    
    // get menuitem tag
    int tag = [menuItem tag];
    
    if(tag == ModuleMenuOpenWorkspace) {
        ret = NO;
    } else if(tag == ModuleMenuOpenCurrent) {
        // get module
        OutlineListObject *clicked = [moduleOutlineView itemAtRow:[moduleOutlineView clickedRow]];
        if(clicked.listType == LISTOBJECTTYPE_MODULE) {
            SwordModule *mod = clicked.listObject;
            
            // get displaying type of delegate
            if([delegate isKindOfClass:[SingleViewHostController class]]) {
                SingleViewHostController *host = (SingleViewHostController *)delegate;
                if((host.moduleType == mod.type) ||
                   (host.moduleType == bible && mod.type == commentary)) {
                    ret = YES;
                } else {
                    ret = NO;
                }
            } else {
                ret = NO;
            }
        }
    }
        
    return ret;
}

- (IBAction)moduleMenuClicked:(id)sender {
	MBLOGV(MBLOG_DEBUG, @"[ModuleOutlineViewController -moduleMenuClicked:] %@", [sender description]);
    
    int tag = [sender tag];
    
    switch(tag) {
        case ModuleMenuOpenSingle:
            [self doubleClick];
            break;
        case ModuleMenuOpenWorkspace:
            // do nothing
            break;
        case ModuleMenuOpenCurrent:
        {
            // get module
            SwordModule *mod = nil;
            OutlineListObject *clicked = [moduleOutlineView itemAtRow:[moduleOutlineView clickedRow]];
            if(clicked.listType == LISTOBJECTTYPE_MODULE) {
                mod = clicked.listObject;
            }
            
            if(mod != nil) {
                HostableViewController *contentViewController = [delegate contentViewController];
                if([contentViewController isKindOfClass:[BibleCombiViewController class]]) {
                    if(mod.type == bible) {
                        [(BibleCombiViewController *)contentViewController addNewBibleViewWithModule:(SwordBible *)mod];
                    } else if(mod.type == commentary) {
                        [(BibleCombiViewController *)contentViewController addNewCommentViewWithModule:(SwordCommentary *)mod];                    
                    }
                }
            }
        }
    }
}

#pragma mark - outline delegate methods

- (void)doubleClick {
    // get clicked row
    int clickedRow = [moduleOutlineView clickedRow];
    
    OutlineListObject *clickedObj = [moduleOutlineView itemAtRow:clickedRow];
    if(clickedObj.listType == LISTOBJECTTYPE_MODULE) {
        // default action on this is open another single view host with this module
        [[AppController defaultAppController] openSingleHostWindowForModule:clickedObj.listObject];
    }
}

//--------------------------------------------------------------------
//----------- NSOutlineView delegates --------------------------------
//--------------------------------------------------------------------
/**
 \brief Notification is called when the selection has changed 
 */
/*
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	MBLOG(MBLOG_DEBUG,@"[ModuleOutlineViewController outlineViewSelectionDidChange:]");
	
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
                //[oview setMenu:installSourceMenu];
            }
            
            // update modules
            NSArray *selected = [NSArray arrayWithArray:selection];
            [self setSelectedInstallSources:selected];
            [modListViewController setInstallSources:selected];
            [modListViewController refreshModulesList];
		} else {
			MBLOG(MBLOG_WARN,@"[ModuleOutlineViewController outlineViewSelectionDidChange:] have a nil notification object!");
		}
	} else {
		MBLOG(MBLOG_WARN,@"[ModuleOutlineViewController outlineViewSelectionDidChange:] have a nil notification!");
	}
}
*/

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    int count = 0;
	
	if(item == nil) {
        // number of root items
        count = [data count];
	} else if([item isKindOfClass:[OutlineListObject class]]) {
        OutlineListObject *obj = (OutlineListObject *)item;
        count = [(NSArray *)obj.listObject count];
    }
	
	return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    
    OutlineListObject *ret = nil;
    
    if(item == nil) {
        ret = [data objectAtIndex:0];
	} else if([item isKindOfClass:[OutlineListObject class]]) {
        OutlineListObject *obj = (OutlineListObject *)item;
        ret = [(NSArray *)obj.listObject objectAtIndex:index];
    } else {
        ret = @"test";
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    
    NSString *ret = @"test";
    
    // cast object
    OutlineListObject *listObject = (OutlineListObject *)item;
    
    if(item != nil && [item isKindOfClass:[OutlineListObject class]]) {
        ret = listObject.displayString;
    }
    
    return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    
    // cast object
    OutlineListObject *listObject = (OutlineListObject *)item;
    
    if(item != nil && (listObject.listType != LISTOBJECTTYPE_MODULE)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    BOOL ret = NO;
    
    // cast object
    OutlineListObject *listObject = (OutlineListObject *)item;

    if(item != nil) {
        if(listObject.listType == LISTOBJECTTYPE_MODULE) {
            ret = YES;
        }
    }
    
    return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

@end
