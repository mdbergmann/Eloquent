//
//  ModuleListUIController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 16.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "ModuleListUIController.h"
#import "BibleCombiViewController.h"
#import "WorkspaceViewHostController.h"
#import "LeftSideBarViewController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "AppController.h"
#import "globals.h"

#define MODULELIST_UI_NIBNAME @"ModuleListUI"

enum ModuleMenu_Items{
    ModuleMenuOpenSingle = 100,
    ModuleMenuOpenWorkspace,
    ModuleMenuOpenCurrent,
    ModuleMenuShowAbout = 120,
    ModuleMenuUnlock
}ModuleMenuItems;

@interface ModuleListUIController ()

- (void)modulesListChanged:(NSNotification *)notification;

@end

@implementation ModuleListUIController

/**
 generate a menu structure
 
 @params[in|out] subMenuItem is the start of the menustructure.
 @params[in] type, create menu for module types. ModuleType enum values can be ORed, -1 for all
 @params[in] aTarget the target object of the created menuitem
 @params[in] aSelector the selector of the target that should be called
 */
+ (void)generateModuleMenu:(NSMenu **)itemMenu 
             forModuletype:(int)type 
            withMenuTarget:(id)aTarget 
            withMenuAction:(SEL)aSelector {
    
    SwordManager *swManager = [SwordManager defaultManager];
    // create menu for modules for specified type
    // bibles
    if((type == -1) || ((type & bible) == bible)) {
        NSArray *mods = [swManager modulesForType:SWMOD_CATEGORY_BIBLES];
        for(SwordBible *mod in mods) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] init];
            [menuItem setTitle:[mod name]];
            //[menuItem setToolTip:[[urlval valueData] absoluteString]];					
            //image = [NSImage imageNamed:@"ItemAdd"];
            //[image setSize:NSMakeSize(32,32)];
            //[menuItem setImage:image];
            [menuItem setTarget:aTarget];
            [menuItem setAction:aSelector];
            [menuItem setEnabled:YES];
            [*itemMenu addItem:menuItem];
            [menuItem release];
        }
        
        // add separator as last item
        [*itemMenu addItem:[NSMenuItem separatorItem]];
    }
    
    // commentaries
    if((type == -1) || ((type & commentary) == commentary)) {
        NSArray *mods = [swManager modulesForType:SWMOD_CATEGORY_COMMENTARIES];
        for(SwordBible *mod in mods) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] init];
            [menuItem setTitle:[mod name]];
            //[menuItem setToolTip:[[urlval valueData] absoluteString]];					
            //image = [NSImage imageNamed:@"ItemAdd"];
            //[image setSize:NSMakeSize(32,32)];
            //[menuItem setImage:image];
            [menuItem setTarget:aTarget];
            [menuItem setAction:aSelector];
            [menuItem setEnabled:YES];
            [*itemMenu addItem:menuItem];
            [menuItem release];
        }
        
        // add separator as last item
        [*itemMenu addItem:[NSMenuItem separatorItem]];
    }
    
    // dictionaries
    if((type == -1) || ((type & dictionary) == dictionary)) {
        NSArray *mods = [swManager modulesForType:SWMOD_CATEGORY_DICTIONARIES];
        for(SwordBible *mod in mods) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] init];
            [menuItem setTitle:[mod name]];
            //[menuItem setToolTip:[[urlval valueData] absoluteString]];					
            //image = [NSImage imageNamed:@"ItemAdd"];
            //[image setSize:NSMakeSize(32,32)];
            //[menuItem setImage:image];
            [menuItem setTarget:aTarget];
            [menuItem setAction:aSelector];
            [*itemMenu addItem:menuItem];
            [menuItem release];
        }
        
        // add separator as last item
        [*itemMenu addItem:[NSMenuItem separatorItem]];
    }
    
    // gen books
    if((type == -1) || ((type & genbook) == genbook)) {
        NSArray *mods = [swManager modulesForType:SWMOD_CATEGORY_GENBOOKS];
        for(SwordBible *mod in mods) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] init];
            [menuItem setTitle:[mod name]];
            //[menuItem setToolTip:[[urlval valueData] absoluteString]];					
            //image = [NSImage imageNamed:@"ItemAdd"];
            //[image setSize:NSMakeSize(32,32)];
            //[menuItem setImage:image];
            [menuItem setTarget:aTarget];
            [menuItem setAction:aSelector];
            [*itemMenu addItem:menuItem];
            [menuItem release];
        }
        
        // add separator as last item
        [*itemMenu addItem:[NSMenuItem separatorItem]];
    }
    
    // check last item is a separator, then remove    
    int len = [[*itemMenu itemArray] count];
    if(len > 0) {
        NSMenuItem *last = [*itemMenu itemAtIndex:len-1];
        if([last isSeparatorItem]) {
            [*itemMenu removeItem:last];
        }
    }
}


@synthesize moduleMenu;

- (id)init {
    return [super init];
}

- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate {
    self = [super initWithDelegate:aDelegate hostingDelegate:aHostingDelegate];
    if(self) {
        swordManager = [SwordManager defaultManager];
        
        // register for modules changed notification
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(modulesListChanged:)
                                                     name:NotificationModulesChanged object:nil];            
        
        BOOL stat = [NSBundle loadNibNamed:MODULELIST_UI_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[ModuleListUIController -init] unable to load nib!");
        }        
    }
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)awakeFromNib {
    [moduleUnlockTextField setContinuous:YES];    
}

#pragma mark - Methods

- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod {
    // get about text as NSAttributedString
    NSAttributedString *aboutText = [aMod fullAboutText];
    [[moduleAboutTextView textStorage] setAttributedString:aboutText];
    // open window
    [NSApp beginSheet:moduleAboutWindow 
       modalForWindow:[hostingDelegate window] 
        modalDelegate:self
       didEndSelector:nil 
          contextInfo:nil];    
}

#pragma mark - Notfications

- (void)modulesListChanged:(NSNotification *)notification {
    [self delegateReload];
}

#pragma mark - Menu Validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	MBLOGV(MBLOG_DEBUG, @"[ModuleListUIController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = YES;
    
    SwordModule *clicked = (SwordModule *)[self delegateSelectedObject];
    
    int tag = [menuItem tag];
    if(tag == ModuleMenuOpenCurrent) {
        if([clicked isKindOfClass:[SwordModule class]]) {
            SwordModule *mod = clicked;
            
            if([[hostingDelegate contentViewController] contentViewType] == SwordBibleContentType) {
                // only commentary and bible views are able to show within bible the current
                if(mod.type == bible || mod.type == commentary) {                    
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
    } else if(tag == ModuleMenuShowAbout) {
        if(![clicked isKindOfClass:[SwordModule class]]) {
            ret = NO;
        }
    } else if(tag == ModuleMenuUnlock) {
        if([clicked isKindOfClass:[SwordModule class]]) {
            SwordModule *mod = clicked;
            if(![mod isEncrypted]) {
                ret = NO;
            }
        }
    }    
    
    return ret;
}

#pragma mark - Actions

- (IBAction)moduleMenuClicked:(id)sender {
	MBLOGV(MBLOG_DEBUG, @"[ModuleListUIController -moduleMenuClicked:] %@", [sender description]);
    
    int tag = [sender tag];
    
    SwordModule *clicked = (SwordModule *)[self delegateSelectedObject];
    clickedMod = clicked;
    
    switch(tag) {
        case ModuleMenuOpenSingle:
            [[AppController defaultAppController] openSingleHostWindowForModule:clicked];
            break;
        case ModuleMenuOpenWorkspace:
            [self delegateDoubleClick];
            break;
        case ModuleMenuOpenCurrent:
        {
            if(clicked.type == bible) {
                [(BibleCombiViewController *)[hostingDelegate contentViewController] addNewBibleViewWithModule:(SwordBible *)clicked];
            } else if(clicked.type == commentary) {
                [(BibleCombiViewController *)[hostingDelegate contentViewController] addNewCommentViewWithModule:(SwordCommentary *)clicked];                    
            }
            break;
        }
        case ModuleMenuShowAbout:
        {
            [self displayModuleAboutSheetForModule:clicked];
            break;
        }
        case ModuleMenuUnlock:
        {
            // open window
            [NSApp beginSheet:moduleUnlockWindow 
               modalForWindow:[hostingDelegate window] 
                modalDelegate:self 
               didEndSelector:nil 
                  contextInfo:nil];
            break;
        }
    }
}

- (IBAction)moduleAboutClose:(id)sender {
    [moduleAboutWindow close];
    [NSApp endSheet:moduleAboutWindow];
    [moduleAboutTextView setString:@""];
}

- (IBAction)moduleUnlockOk:(id)sender {
    NSString *unlockCode = [moduleUnlockTextField stringValue];
    SwordModule *mod = clickedMod;        
    if(mod) {
        [mod unlock:unlockCode];
    }
    
    [moduleUnlockWindow close];
    [NSApp endSheet:moduleUnlockWindow];
    
    [moduleUnlockTextField setStringValue:@""];
    
    [self delegateReload];
}

- (IBAction)moduleUnlockCancel:(id)sender {
    [moduleUnlockWindow close];
    [NSApp endSheet:moduleUnlockWindow];
    [moduleUnlockTextField setStringValue:@""];    
}

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	// hide sheet
	[sSheet orderOut:nil];
}

#pragma mark - NSControl delegate methods

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if([aNotification object] == moduleUnlockTextField) {
        if([[moduleUnlockTextField stringValue] length] == 0) {
            [moduleUnlockOKButton setEnabled:NO];
        } else {
            [moduleUnlockOKButton setEnabled:YES];
        }        
    }
}

@end
