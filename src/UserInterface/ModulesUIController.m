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
- (void)generateModuleMenu:(NSMenu *)itemMenu
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
            [itemMenu addItem:menuItem];
        }
        
        // add separator as last item
        [itemMenu addItem:[NSMenuItem separatorItem]];
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
            [itemMenu addItem:menuItem];
        }
        
        // add separator as last item
        [itemMenu addItem:[NSMenuItem separatorItem]];
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
            [itemMenu addItem:menuItem];
        }
        
        // add separator as last item
        [itemMenu addItem:[NSMenuItem separatorItem]];
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
            [itemMenu addItem:menuItem];
        }
        
        // add separator as last item
        [itemMenu addItem:[NSMenuItem separatorItem]];
    }
    
    // check last item is a separator, then remove    
    NSInteger len = [[itemMenu itemArray] count];
    if(len > 0) {
        NSMenuItem *last = [itemMenu itemAtIndex:len-1];
        if([last isSeparatorItem]) {
            [itemMenu removeItem:last];
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
        
        [[NSBundle mainBundle] loadNibNamed:MODULELIST_UI_NIBNAME owner:self topLevelObjects:nil];
    }
    return self;
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
                                                                     attributes:@{NSFontAttributeName: FontMoreLargeBold}];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod name]]
                                                 attributes:@{NSFontAttributeName: FontMoreLarge}];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module description
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleDescription", @"")
                                                 attributes:@{NSFontAttributeName: FontMoreLargeBold}];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod descr]]
                                                 attributes:@{NSFontAttributeName: FontMoreLarge}];
    if(attrString) {
        [ret appendAttributedString:attrString];
    }
    
    // module type
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleType", @"")
                                                 attributes:@{NSFontAttributeName: FontMoreLargeBold}];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod typeString]]
                                                 attributes:@{NSFontAttributeName: FontMoreLarge}];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module lang
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleLang", @"")
                                                 attributes:@{NSFontAttributeName: FontMoreLargeBold}];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod lang]]
                                                 attributes:@{NSFontAttributeName: FontMoreLarge}];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module version
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleVersion", @"")
                                                 attributes:@{NSFontAttributeName: FontMoreLargeBold}];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod version]]
                                                 attributes:@{NSFontAttributeName: FontMoreLarge}];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module versification
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleVersification", @"")
                                                 attributes:@{NSFontAttributeName: FontMoreLargeBold}];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod versification]]
                                                 attributes:@{NSFontAttributeName: FontMoreLarge}];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }

    // module distribution license
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleDistLicense", @"")
                                                 attributes:@{NSFontAttributeName: FontMoreLargeBold}];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [aMod distributionLicense]]
                                                 attributes:@{NSFontAttributeName: FontMoreLarge}];
    if(attrString) {
        [ret appendAttributedString:attrString];
    }

    // module short promo
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleShortPromo", @"")
                                                 attributes:@{NSFontAttributeName: FontMoreLargeBold}];
    [ret appendAttributedString:attrString];
    
    NSString *promoString = [NSString stringWithFormat:@"%@<br /><br />", [aMod shortPromo]];

    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    options[NSCharacterEncodingDocumentOption] = @(NSUTF8StringEncoding);

    WebPreferences *webPrefs = [[MBPreferenceController defaultPrefsController] defaultWebPreferencesForModuleName:nil];
    [webPrefs setDefaultFontSize:(int)[FontMoreLarge pointSize]];
    [webPrefs setStandardFontFamily:[FontMoreLarge familyName]];
    options[NSWebPreferencesDocumentOption] = webPrefs;

    attrString = [[NSAttributedString alloc] initWithHTML:[promoString dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:options
                                       documentAttributes:nil];
    if(attrString) {
        [ret appendAttributedString:attrString];
    }

    // module about
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", NSLocalizedString(@"AboutModuleAboutText", @"")]
                                                 attributes:@{NSFontAttributeName: FontMoreLargeBold}];
    [ret appendAttributedString:attrString];
    NSMutableString *aboutStr = [NSMutableString stringWithString:[aMod aboutText]];
    attrString = [[NSAttributedString alloc] initWithString:aboutStr
                                                 attributes:@{NSFontAttributeName: FontMoreLarge}];
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
    
    NSInteger tag = [menuItem tag];
    if(tag == ModuleMenuOpenCurrent) {
        if([clicked isKindOfClass:[SwordModule class]]) {
            SwordModule *mod = clicked;
            
            if([[hostingDelegate contentViewController] contentViewType] == SwordBibleContentType) {
                // only commentary and bible views are able to show within bible the current
                ret = mod.type == Bible || mod.type == Commentary;
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
    NSInteger tag = [sender tag];
    
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
    if([UserDefaults objectForKey:DefaultsCreateCluceneConfirm] == nil ||
            ![UserDefaults boolForKey:DefaultsCreateCluceneConfirm]) {
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
        [ps setIsIndeterminateProgress:@YES];
        [ps setIsThreaded:@YES];
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
        [[SwordManager defaultManager] setCipherKey:unlockCode forModuleNamed:[mod name]];
        
        NSMutableDictionary *cipherKeys = [[UserDefaults objectForKey:DefaultsModuleCipherKeysKey] mutableCopy];
        cipherKeys[[mod name]] = unlockCode;
        [UserDefaults setObject:[NSDictionary dictionaryWithDictionary:cipherKeys] forKey:DefaultsModuleCipherKeysKey];
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
        [moduleUnlockOKButton setEnabled:[[moduleUnlockTextField stringValue] length] != 0];
    }
}

@end
