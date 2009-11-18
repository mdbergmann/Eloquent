//
//  ContentDisplayingViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 18.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HostableViewController.h>
#import <ProtocolHelper.h>

@interface ContentDisplayingViewController : HostableViewController <AccessoryViewProviding, ProgressIndicating> {

}

// AccessoryViewProviding protocol
- (NSView *)topAccessoryView;
- (NSView *)rightAccessoryView;

// ProgressIndicating
- (void)beginIndicateProgress;
- (void)endIndicateProgress;

@end
