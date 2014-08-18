//
//  InitialInfoViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 05.10.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@class WindowHostController;

@interface InitialInfoViewController : NSViewController {
    IBOutlet NSTextField *installedModulesLabel;
    IBOutlet NSTextField *openBibleLabel;
}

@property (strong, nonatomic) IBOutlet WindowHostController *host;

- (NSString *)installedModulesLabel;
- (NSString *)openBibleLabel;

- (IBAction)openModuleManager:(id)sender;
- (IBAction)openDefaultBible:(id)sender;

@end
