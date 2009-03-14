//
//  FullScreenSplitView.m
//  MacSword2
//
//  Created by Manfred Bergmann on 09.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FullScreenSplitView.h"
#import "MBPreferenceController.h"
#import "ConfirmationSheetController.h"
#import "globals.h"

@implementation FullScreenSplitView

- (BOOL)isFullScreenMode {
    return [self isInFullScreenMode];
}

- (void)setFullScreenMode:(BOOL)flag {
    if(flag) {
        if([userDefaults objectForKey:DefaultsShowFullScreenConfirm] == nil || 
           [userDefaults boolForKey:DefaultsShowFullScreenConfirm] == NO) {
            conf = [[ConfirmationSheetController alloc] initWithSheetTitle:NSLocalizedString(@"ConfirmFullScreenMode", @"") 
                                                                   message:NSLocalizedString(@"ConfirmFullScreenModeText", @"") 
                                                             defaultButton:NSLocalizedString(@"OK", @"") 
                                                           alternateButton:NSLocalizedString(@"Cancel", @"") 
                                                               otherButton:nil 
                                                            askAgainButton:NSLocalizedString(@"DoNotAskAgain", @"") 
                                                       defaultsAskAgainKey:DefaultsShowFullScreenConfirm 
                                                               contextInfo:nil 
                                                                 docWindow:[self window]];
            [conf setDelegate:self];
            [conf beginSheet];
        } else {
            [self enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];        
        }
    } else {
        [self exitFullScreenModeWithOptions:nil];
    }
}

- (IBAction)fullScreenModeOnOff:(id)sender {
    [self setFullScreenMode:![self isFullScreenMode]];
}

- (void)confirmationSheetEnded {
    if(conf) {
        if([conf sheetReturnCode] == SheetDefaultButtonCode) {
            [self enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];            
        }
    }
}

@end
