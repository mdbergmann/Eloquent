//
//  ModuleListUIController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 16.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <ObjCSword/SwordModule.h>
#import "LeftSideBarAccessoryUIController.h"

@class SwordManager;
@class SwordModule;
@class WindowHostController;
@class ConfirmationSheetController;

@interface ModulesUIController : LeftSideBarAccessoryUIController {
    // module about
    IBOutlet NSWindow *moduleAboutWindow;
    IBOutlet NSTextView *moduleAboutTextView;
    // unlock window
    IBOutlet NSWindow *moduleUnlockWindow;
    IBOutlet NSTextField *moduleUnlockTextField;
    IBOutlet NSButton *moduleUnlockOKButton;
    IBOutlet NSMenu *moduleMenu;
    
    ConfirmationSheetController *confirmSheet;
    
    SwordManager *swordManager;
    SwordModule *clickedMod;
}

@property (readonly) NSMenu *moduleMenu;

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
            withMenuAction:(SEL)aSelector;
    
- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod;

- (IBAction)moduleMenuClicked:(id)sender;
- (IBAction)moduleAboutClose:(id)sender;
- (IBAction)moduleUnlockOk:(id)sender;
- (IBAction)moduleUnlockCancel:(id)sender;

@end
