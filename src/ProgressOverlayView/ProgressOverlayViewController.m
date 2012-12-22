//
//  ProgressOverlayViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 10.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordModule+SearchKitIndex.h"
#import "ProgressOverlayViewController.h"


@implementation ProgressOverlayViewController

@synthesize delegate;
@synthesize barProgressView;

+ (ProgressOverlayViewController *)defaultController {
	static ProgressOverlayViewController *singleton = nil;
	
	if(singleton == nil) {
		singleton = [[ProgressOverlayViewController alloc] init];
	}
	
	return singleton;
}

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"[ProgressOverlayViewController -init]");
	} else {        
        delegate = aDelegate;
        
        BOOL success = [NSBundle loadNibNamed:@"ProgressOverlayView" owner:self];
        if(success == NO) {
            CocoLog(LEVEL_WARN, @"[ProgressOverlayViewController init] could not load nib");
        }
	}
	
	return self;    
}

- (void)awakeFromNib {
    // set some view things
    [progressIndicator setUsesThreadedAnimation:YES];
    [barProgressIndicator setUsesThreadedAnimation:YES];
    //[progressIndicator scaleUnitSquareToSize:NSMakeSize(0.5, 0.5)];
    
    if(delegate) {
        if([delegate respondsToSelector:@selector(contentViewInitFinished:)]) {
            [delegate performSelector:@selector(contentViewInitFinished:) withObject:self];
        }
    }
}

- (void)finalize {
	[super finalize];
}

- (void)startProgressAnimation {
    [progressIndicator startAnimation:self];
    [barProgressIndicator startAnimation:self];
}

- (void)stopProgressAnimation {
    [progressIndicator stopAnimation:self];
    [barProgressIndicator stopAnimation:self];
}

- (void)addToMaxProgressValue:(double)val {
    [barProgressIndicator setMaxValue:[barProgressIndicator maxValue] + val];
}

- (void)setProgressMaxValue:(double)max {
    [barProgressIndicator setMaxValue:max];
}

- (void)setProgressCurrentValue:(double)val {
    [barProgressIndicator setDoubleValue:val];
}

- (void)setProgressIndeterminate:(BOOL)flag {
    [barProgressIndicator setIndeterminate:flag];
}

- (void)incrementProgressBy:(double)increment {
    [barProgressIndicator incrementBy:increment];
}

@end
