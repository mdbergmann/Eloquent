//
//  ModuleListUIController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 16.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "ModulesUIController.h"
#import "BibleCombiViewController.h"
#import "WorkspaceViewHostController.h"
#import "LeftSideBarViewController.h"
#import "ObjCSword/SwordManager.h"
#import "ObjCSword/SwordModule.h"
#import "ObjCSword/Notifications.h"
#import "ObjCSword/SwordModule+Index.h"
#import "AppController.h"
#import "MBThreadedProgressSheetController.h"
#import "ConfirmationSheetController.h"
#import "MBPreferenceController.h"
#import "globals.h"

#define MODULELIST_UI_NIBNAME @"ModuleListUI"

enum ModuleMenu_Items{
    ModuleMenuOpenSingle = 100,
    ModuleMenuOpenWorkspace,
    ModuleMenuOpenCurrent,
    ModuleMenuShowAbout = 120,
    ModuleMenuUnlock,
    ModuleMenuCreateCluceneIndex
}ModuleMenuItems;

@interface ModulesUIController ()

- (NSAttributedString *)aboutStringForModule:(SwordModule *)aMod;
- (void)modulesListChanged:(NSNotification *)notification;
- (void)createCluceneIndex;
- (void)_createCluceneIndex;

@end

@implementation ModulesUIController

/**
 generate a menu structure
 
 @params[in|out] subMenuItem is the start of the menustructure.
 @params[in] type, create menu for module types. ModuleType enum values can be ORed, -1 for all
 @params[in] aTarget the target object of the created menuitem
 @params[in] aSelector the selector of the target that should be called
 */
- (void)generateModuleMenu:(NSMenu **)itemMenu 
             forModuletype:(ModuleType)type 
            withMenuTarget:(id)aTarget 
            withMenuAction:(SEL)aSelector {
    
    SwordManager *swManager = [SwordManager defaultManager];
    // create menu for modules for specified type
    // bibles
    if((type == -1) || ((type & Bible) == Bible)) {
        NSArray *mods = [swManager modulesForType:type];
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
    if((type == -1) || ((type & Commentary) == Commentary)) {
        NSArray *mods = [swManager modulesForType:type];
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
    if((type == -1) || ((type & Dictionary) == Dictionary)) {
        NSArray *mods = [swManager modulesForType:type];
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
    if((type == -1) || ((type & Genbook) == Genbook)) {
        NSArray *mods = [swManager modulesForType:type];
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

- (id)initWithDelegate:(id<LeftSideBarDelegate>)aDelegate hostingDelegate:(WindowHostController *)aHostingDelegate {
    self = [super initWithDelegate:aDelegate hostingDelegate:aHostingDelegate];
    if(self) {
        swordManager = [SwordManager defaultManager];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(modulesListChanged:)
                                                     name:NotificationModulesChanged object:nil];            
        
        BOOL stat = [NSBundle loadNibNamed:MODULELIST_UI_NIBNAME owner:self];
        if(!stat) {
            CocoLog(LEVEL_ERR, @"[ModuleListUIController -init] unable to load nib!");
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
    NSAttributedString *aboutText = [self aboutStringForModule:aMod];
    [[moduleAboutTextView textStorage] setAttributedString:aboutText];
    // open window
    [NSApp beginSheet:moduleAboutWindow 
       modalForWindow:[hostingDelegate window] 
        modalDelegate:self
       didEndSelector:nil 
          contextInfo:nil];    
}

- (NSAttributedString *)aboutStringForModule:(SwordModule *)aMod {
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] init];
    
    // module Name, book name, type, lang, version, about
    // module name
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleName", @"") 
                                                                     attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod name]] 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module description
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleDescription", @"")
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod descr]] 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];
    if(attrString) {
        [ret appendAttributedString:attrString];
    }
    
    // module type
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleType", @"") 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod typeString]] 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module lang
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleLang", @"") 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod lang]] 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module version
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleVersion", @"") 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod version]] 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module versification
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleVersification", @"") 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod versification]] 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }

    // module about
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", NSLocalizedString(@"AboutModuleAboutText", @"")]
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    NSMutableString *aboutStr = [NSMutableString stringWithString:[aMod aboutText]];
    attrString = [[NSAttributedString alloc] initWithString:aboutStr 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];    
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    return ret;    
}

#pragma mark - Notfications

- (void)modulesListChanged:(NSNotification *)notification {
    [self delegateReload];
}

#pragma mark - Menu Validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    BOOL ret = YES;
    
    SwordModule *clicked = (SwordModule *)[self delegateSelectedObject];
    
    int tag = [menuItem tag];
    if(tag == ModuleMenuOpenCurrent) {
        if([clicked isKindOfClass:[SwordModule class]]) {
            SwordModule *mod = clicked;
            
            if([[hostingDelegate contentViewController] contentViewType] == SwordBibleContentType) {
                // only commentary and bible views are able to show within bible the current
                if(mod.type == Bible || mod.type == Commentary) {                    
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
    } else if(tag == ModuleMenuShowAbout || tag == ModuleMenuCreateCluceneIndex) {
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
            if(clicked.type == Bible) {
                [(BibleCombiViewController *)[hostingDelegate contentViewController] addNewBibleViewWithModule:(SwordBible *)clicked];
            } else if(clicked.type == Commentary) {
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
        case ModuleMenuCreateCluceneIndex:
        {
            [self createCluceneIndex];
            break;
        }
    }
}

- (void)createCluceneIndex {
    if([userDefaults objectForKey:DefaultsCreateCluceneConfirm] == nil || 
       [userDefaults boolForKey:DefaultsCreateCluceneConfirm] == NO) {
        confirmSheet = [[ConfirmationSheetController alloc] initWithSheetTitle:NSLocalizedString(@"ConfirmCreateCluceneIndex", @"") 
                                                               message:NSLocalizedString(@"ConfirmCreateCluceneIndexText", @"") 
                                                         defaultButton:NSLocalizedString(@"Yes", @"") 
                                                       alternateButton:NSLocalizedString(@"No", @"") 
                                                           otherButton:nil 
                                                        askAgainButton:NSLocalizedString(@"DoNotAskAgain", @"") 
                                                   defaultsAskAgainKey:DefaultsCreateCluceneConfirm 
                                                           contextInfo:nil 
                                                             docWindow:[hostingDelegate window]];
        [confirmSheet setDelegate:self];
        [confirmSheet beginSheet];
    } else {
        [self _createCluceneIndex];
    }
}

- (void)_createCluceneIndex {
    SwordModule *mod = (SwordModule *)[self delegateSelectedObject];
    if(mod) {
        MBThreadedProgressSheetController *ps = [MBThreadedProgressSheetController standardProgressSheetController];
        [ps reset];
        [ps setIsIndeterminateProgress:[NSNumber numberWithBool:YES]];
        [ps setIsThreaded:[NSNumber numberWithBool:YES]];
        [ps setActionMessage:NSLocalizedString(@"CreatingCluceneIndex", @"")];
        [ps setCurrentStepMessage:NSLocalizedString(@"Indexing", @"")];
        
        [ps startProgressAnimation];
        [ps beginSheetForWindow:[hostingDelegate window]];
        CocoLog(LEVEL_INFO, @"Creating Clucene index for module: %@", [mod name]);
        [mod createSearchIndex];
        CocoLog(LEVEL_INFO, @"Creating Clucene index...done");
        [ps endSheet];
        [ps stopProgressAnimation];        
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

// Confirm sheet callback
- (void)confirmationSheetEnded {
    if(confirmSheet) {
        if([confirmSheet sheetReturnCode] == SheetDefaultButtonCode) {
            [self _createCluceneIndex];
        }
    }
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
