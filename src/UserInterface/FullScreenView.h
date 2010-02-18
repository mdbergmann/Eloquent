//
//  FullScreenView.h
//  MacSword2
//
//  Created by Manfred Bergmann on 09.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ProtocolHelper.h>

@class ConfirmationSheetController;

@interface FullScreenView : NSView <FullScreenCapability> {
    ConfirmationSheetController *conf;
    id delegate;
}

@property (readwrite) id delegate;

- (BOOL)isFullScreenMode;
- (void)setFullScreenMode:(BOOL)flag;
- (IBAction)fullScreenModeOnOff:(id)sender;

@end
