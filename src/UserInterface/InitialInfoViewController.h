//
//  InitialInfoViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 05.10.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>


@interface InitialInfoViewController : NSViewController {
    IBOutlet NSTextField *installedModulesLabel;
}

- (NSString *)installedModulesLabel;

- (IBAction)openModuleManager:(id)sender;

@end
