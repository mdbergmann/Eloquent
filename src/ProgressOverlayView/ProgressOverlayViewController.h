//
//  ProgressOverlayViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 10.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@interface ProgressOverlayViewController : NSViewController {
    // Progress overlay view
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet id delegate;
}

@property (readwrite) id delegate;

+ (ProgressOverlayViewController *) defaultController;

/**
 when using this initializer, the delegate should implement -contentViewInitFinished:
 in order to be notified when the loading of progress indcator is done
 */
- (id)initWithDelegate:(id)aDelegate;

- (void)startProgressAnimation;
- (void)stopProgressAnimation;

@end
