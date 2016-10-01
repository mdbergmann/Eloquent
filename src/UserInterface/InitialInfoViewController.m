//
//  InitialInfoViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 05.10.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "InitialInfoViewController.h"
#import "AppController.h"
#import "HostableViewController.h"
#import "WindowHostController.h"
#import "ModuleCommonsViewController.h"
#import "BibleCombiViewController.h"
#import "globals.h"
#import "MBPreferenceController.h"


@implementation InitialInfoViewController

- (id)init {
    self = [super init];
    if(self) {
        [[NSBundle mainBundle] loadNibNamed:@"InitialInfoView" owner:self topLevelObjects:nil];
    }

    return self;
}

- (NSString *)installedModulesLabel {
    return [NSString stringWithFormat:NSLocalizedString(@"InitialViewLabelText", @""), [[SwordManager defaultManager] numberOfModules]];
}

- (NSString *)openBibleLabel {
    return NSLocalizedString(@"InitialViewLabelOpenBibleText", @"");
}

- (IBAction)openModuleManager:(id)sender {
    [[AppController defaultAppController] showModuleManager:sender];
}

- (IBAction)openDefaultBible:(id)sender {
    if(self.host == nil) {
        CocoLog(LEVEL_WARN, @"host window controller not defined!");
        return;
    }
    
    // find default bible
    NSString *defaultBibleName = [UserDefaults objectForKey:DefaultsBibleModule];
    if(defaultBibleName == nil) {
        // find the first bible in list instead
        NSArray *bibles = [[SwordManager defaultManager] modulesForType:Bible];
        if(bibles && [bibles count] > 0) {
            defaultBibleName = [bibles objectAtIndex:0];
        }
    }

    if(defaultBibleName == nil) {
        CocoLog(LEVEL_WARN, @"It seems no default bible is defined and there is also no bible installed. Unable to fullfil the request!");
        return;
    }

    SwordModule *mod = [[SwordManager defaultManager] moduleWithName:defaultBibleName];
    [self.host addContentViewController:[[BibleCombiViewController alloc] initWithModule:(SwordBible *) mod delegate:nil]];
}

@end
