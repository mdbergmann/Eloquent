//
//  FullScreenSplitView.h
//  MacSword2
//
//  Created by Manfred Bergmann on 09.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ProtocolHelper.h>

@class ConfirmationSheetController;

@interface FullScreenSplitView : NSSplitView <FullScreenCapability> {
    ConfirmationSheetController *conf;
}

- (BOOL)isFullScreenMode;
- (void)setFullScreenMode:(BOOL)flag;
- (IBAction)fullScreenModeOnOff:(id)sender;

@end
