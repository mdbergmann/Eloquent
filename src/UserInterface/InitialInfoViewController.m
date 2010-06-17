//
//  InitialInfoViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 05.10.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "InitialInfoViewController.h"
#import "ObjCSword/Logger.h"
#import "AppController.h"
#import "ObjCSword/SwordManager.h"


@implementation InitialInfoViewController

- (id)init {
    self = [super init];
    if(self) {
        BOOL success = [NSBundle loadNibNamed:@"InitialInfoView" owner:self];
        if(success) {
        } else {
            LogL(LOG_ERR,@"[InitialInfoViewController]: cannot load ConfirmationSheetControllerNib!");
        }        
    }

    return self;
}

- (NSString *)installedModulesLabel {
    return [NSString stringWithFormat:NSLocalizedString(@"InitialViewLabelText", @""), [[[SwordManager defaultManager] modules] count]];
}

- (IBAction)openModuleManager:(id)sender {
    [[AppController defaultAppController] showModuleManager:sender];
}

@end
