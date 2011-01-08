//
//  FullScreenView.h
//  Eloquent
//
//  Created by Manfred Bergmann on 09.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <ProtocolHelper.h>

@class ConfirmationSheetController;
@class ToolbarController;

@interface FullScreenView : NSView <FullScreenCapability> {
    IBOutlet ToolbarController *toolbarController;
    IBOutlet id delegate;

    ConfirmationSheetController *conf;
    
    NSDictionary *trackingData;
}

@property (readwrite) id delegate;
@property (readwrite) ToolbarController *toolbarController;

- (BOOL)isFullScreenMode;
- (void)setFullScreenMode:(BOOL)flag;
- (IBAction)fullScreenModeOnOff:(id)sender;

@end
