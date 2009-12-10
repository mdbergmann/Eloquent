//
//  ModuleListUIController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 16.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <LeftSideBarAccessoryUIController.h>

@class SwordManager;
@class SwordModule;

@interface ModuleListUIController : LeftSideBarAccessoryUIController {
    // module about
    IBOutlet NSWindow *moduleAboutWindow;
    IBOutlet NSTextView *moduleAboutTextView;
    // unlock window
    IBOutlet NSWindow *moduleUnlockWindow;
    IBOutlet NSTextField *moduleUnlockTextField;
    IBOutlet NSButton *moduleUnlockOKButton;
    IBOutlet NSMenu *moduleMenu;
    
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
+ (void)generateModuleMenu:(NSMenu **)itemMenu 
             forModuletype:(int)type 
            withMenuTarget:(id)aTarget 
            withMenuAction:(SEL)aSelector;
    
// init
- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate;

// methods
- (void)displayModuleAboutSheetForModule:(SwordModule *)aMod;

// actions
- (IBAction)moduleMenuClicked:(id)sender;
- (IBAction)moduleAboutClose:(id)sender;
- (IBAction)moduleUnlockOk:(id)sender;
- (IBAction)moduleUnlockCancel:(id)sender;

@end
