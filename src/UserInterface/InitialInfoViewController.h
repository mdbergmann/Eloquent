//
//  InitialInfoViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 05.10.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface InitialInfoViewController : NSViewController {
    IBOutlet NSTextField *installedModulesLabel;
}

- (NSString *)installedModulesLabel;

- (IBAction)openModuleManager:(id)sender;

@end
