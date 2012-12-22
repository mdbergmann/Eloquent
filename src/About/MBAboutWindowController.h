/* MBAboutWindowController */

//  Created by Manfred Bergmann on 25.07.05.
//  Copyright 2005 mabe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@interface MBAboutWindowController : NSWindowController {
    IBOutlet NSTextField *appNameLabel;
    IBOutlet NSTextField *copyrightLabel;
    IBOutlet NSTextView *creditsTextView;
    IBOutlet NSTextField *versionLabel;
}

@end
