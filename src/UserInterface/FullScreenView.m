//
//  FullScreenView.m
//  MacSword2
//
//  Created by Manfred Bergmann on 09.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FullScreenView.h"
#import "MBPreferenceController.h"
#import "ConfirmationSheetController.h"
#import "globals.h"

@interface FullScreenView ()

- (void)enterFullScreenMode;
- (void)exitFullScreenMode;

@end

@implementation FullScreenView

@synthesize delegate;

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
            [self enterFullScreenMode];
        }
    } else {
        [self exitFullScreenMode];
    }
}

- (IBAction)fullScreenModeOnOff:(id)sender {
    [self setFullScreenMode:![self isFullScreenMode]];
}

- (void)confirmationSheetEnded {
    if(conf) {
        if([conf sheetReturnCode] == SheetDefaultButtonCode) {
            [self enterFullScreenMode];
        }
    }
}

- (void)enterFullScreenMode {
    if([self delegate] && [[self delegate] respondsToSelector:@selector(goingToFullScreenMode)]) {
        [[self delegate] performSelector:@selector(goingToFullScreenMode)];
    }
    [self enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];    
    if([self delegate] && [[self delegate] respondsToSelector:@selector(goneToFullScreenMode)]) {
        [[self delegate] performSelector:@selector(goneToFullScreenMode)];
    }
}

- (void)exitFullScreenMode {
    if([self delegate] && [[self delegate] respondsToSelector:@selector(leavingFullScreenMode)]) {
        [[self delegate] performSelector:@selector(leavingFullScreenMode)];
    }
    [self exitFullScreenModeWithOptions:nil];    
    if([self delegate] && [[self delegate] respondsToSelector:@selector(leftFullScreenMode)]) {
        [[self delegate] performSelector:@selector(leftFullScreenMode)];
    }
}

@end
