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
#import "WorkspaceViewHostController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SwordModCategory.h"

enum ModuleMenu_Items{
    ModuleMenuOpenSingle = 1,
    ModuleMenuOpenWorkspace,
    ModuleMenuOpenCurrent
};

@interface ModuleOutlineViewController ()

- (void)doubleClick;

@end

@implementation ModuleOutlineViewController

@synthesize manager;

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
        }            
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[ModuleOutlineViewController -awakeFromNib]");

    // set double click action
    [outlineView setTarget:self];
    [outlineView setDoubleAction:@selector(doubleClick)];
    
    // loading finished
    viewLoaded = YES;
    [self reportLoadingComplete];
}

# pragma mark - Methods

#pragma mark - Module menu

//--------------------------------------------------------------------
//----------- NSMenu validation --------------------------------
//--------------------------------------------------------------------
/**
 \brief validate menu
 */
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	MBLOGV(MBLOG_DEBUG, @"[ModuleOutlineViewController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = YES; // all of the module stype should be able to show in a single view host
    
    // get menuitem tag
    int tag = [menuItem tag];
    
    if(tag == ModuleMenuOpenCurrent) {
        // get module
        id clicked = [outlineView itemAtRow:[outlineView clickedRow]];
        if([clicked isKindOfClass:[SwordModule class]]) {
            SwordModule *mod = clicked;
            
            if([[hostingDelegate contentViewController] isKindOfClass:[BibleCombiViewController class]]) {
                // only commentary and bible views are able to show within bible the current
                if(([hostingDelegate moduleType] == mod.type) ||
                   ([hostingDelegate moduleType] == bible && mod.type == commentary)) {
                    ret = YES;
                } else {
                    ret = NO;
                }                
            } else {
                ret = NO;
            }
        }
    } else if(tag == ModuleMenuOpenWorkspace) {
        // we only open in workspace if the histingDelegate is a workspace
        if(![hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            ret = NO;
        }
    }
        
    return ret;
}

- (IBAction)moduleMenuClicked:(id)sender {
	MBLOGV(MBLOG_DEBUG, @"[ModuleOutlineViewController -moduleMenuClicked:] %@", [sender description]);
    
    int tag = [sender tag];
    
    // get module
    SwordModule *mod = nil;
    id clicked = [outlineView itemAtRow:[outlineView clickedRow]];
    if([clicked isKindOfClass:[SwordModule class]]) {
        mod = clicked;
    }

    switch(tag) {
        case ModuleMenuOpenSingle:
        case ModuleMenuOpenWorkspace:
            [self doubleClick];
            break;
        case ModuleMenuOpenCurrent:
        {
            if(mod != nil) {
                if(mod.type == bible) {
                    [(BibleCombiViewController *)[hostingDelegate contentViewController] addNewBibleViewWithModule:(SwordBible *)mod];
                } else if(mod.type == commentary) {
                    [(BibleCombiViewController *)[hostingDelegate contentViewController] addNewCommentViewWithModule:(SwordCommentary *)mod];                    
                }
            }
        }
    }
}

#pragma mark - outline delegate methods

- (void)doubleClick {
    // get clicked row
    int clickedRow = [outlineView clickedRow];
    
    id clickedObj = [outlineView itemAtRow:clickedRow];
    if([clickedObj isKindOfClass:[SwordModule class]]) {
        
        // depending on the hosting window we open a new tab or window
        if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [(WorkspaceViewHostController *)hostingDelegate addTabContentForModule:(SwordModule *)clickedObj];        
        } else if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            // default action on this is open another single view host with this module
            [[AppController defaultAppController] openSingleHostWindowForModule:(SwordModule *)clickedObj];        
        }
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

- (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {

	// display call with std font
	NSFont *font = FontLarge;    
	[cell setFont:font];
	//float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
	float pointSize = [font pointSize];
	[aOutlineView setRowHeight:pointSize+6];
}


- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    int count = 0;
	
	if(item == nil) {
        // module categories
        count = [[SwordModCategory moduleCategories] count];        
	} else if([item isKindOfClass:[SwordModCategory class]]) {
        // the modules under a certain category
        SwordModCategory *obj = (SwordModCategory *)item;
        count = [[[SwordManager defaultManager] modulesForType:[obj name]] count];
    }
	
	return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    
    id ret = nil;
    
    if(item == nil) {
        // module categories
        ret = [[SwordModCategory moduleCategories] objectAtIndex:index];        
	} else if([item isKindOfClass:[SwordModCategory class]]) {
        // the modules under a certain category
        SwordModCategory *obj = (SwordModCategory *)item;
        ret = [[[SwordManager defaultManager] modulesForType:[obj name]] objectAtIndex:index];
    } else {
        ret = @"test";
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    
    NSString *ret = @"test";
    
    if(item != nil) {
        if([item isKindOfClass:[SwordModCategory class]]) {
            ret = [(SwordModCategory *)item name];
        } else if([item isKindOfClass:[SwordModule class]]) {
            ret = [(SwordModule *)item name];
        }
    }

    return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    
    if(item != nil && [item isKindOfClass:[SwordModCategory class]]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    if(item != nil) {
        if([item isKindOfClass:[SwordModule class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

@end
