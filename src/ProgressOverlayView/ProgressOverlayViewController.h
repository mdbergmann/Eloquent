//
//  ProgressOverlayViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 10.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@interface ProgressOverlayViewController : NSViewController <IndexCreationProgressing> {
    // Progress overlay view
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSProgressIndicator *barProgressIndicator;
    IBOutlet id delegate;
    IBOutlet NSView *barProgressView;
}

@property (assign, readwrite) id delegate;
@property (readonly) NSView *barProgressView;

+ (ProgressOverlayViewController *)defaultController;

/**
 when using this initializer, the delegate should implement -contentViewInitFinished:
 in order to be notified when the loading of progress indcator is done
 */
- (id)initWithDelegate:(id)aDelegate;

- (void)startProgressAnimation;
- (void)stopProgressAnimation;

- (void)addToMaxProgressValue:(double)val;
- (void)setProgressMaxValue:(double)max;
- (void)setProgressCurrentValue:(double)val;
- (void)setProgressIndeterminate:(BOOL)flag;
- (void)incrementProgressBy:(double)increment;

@end
