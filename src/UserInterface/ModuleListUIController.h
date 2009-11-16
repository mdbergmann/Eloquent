//
//  ModuleListUIController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 16.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@class SwordManager;
@class SwordModule;

@interface ModuleListUIController : NSObject {
    IBOutlet id delegate;
    IBOutlet id hostingDelegate;

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

@property (readwrite) id delegate;
@property (readwrite) id hostingDelegate;
@property (readonly) NSMenu *moduleMenu;

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
