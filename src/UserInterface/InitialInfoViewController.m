//
//  InitialInfoViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 05.10.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "InitialInfoViewController.h"
#import "AppController.h"
#import "SwordManager.h"


@implementation InitialInfoViewController

- (NSString *)installedModulesLabel {
    return [NSString stringWithFormat:NSLocalizedString(@"InitialViewLabelText", @""), [[[SwordManager defaultManager] modules] count]];
}

- (IBAction)openModuleManager:(id)sender {
    [[AppController defaultAppController] showModuleManager:sender];
}

@end
