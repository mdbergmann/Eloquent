//
//  ProgressOverlayViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 10.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProgressOverlayViewController.h"


@implementation ProgressOverlayViewController

@synthesize delegate;

+ (ProgressOverlayViewController *)defaultController {
	static ProgressOverlayViewController *singleton;
	
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
		MBLOG(MBLOG_ERR,@"[ProgressOverlayViewController -init]");
	} else {
        
        // set delegate
        delegate = aDelegate;
        
        // load nib
        BOOL success = [NSBundle loadNibNamed:@"ProgressOverlayView" owner:self];
        if(success == NO) {
            MBLOG(MBLOG_WARN, @"[ProgressOverlayViewController init] could not load nib");
        }
	}
	
	return self;    
}

- (void)awakeFromNib {
    
    // set some view things
    [progressIndicator setUsesThreadedAnimation:YES];
    //[progressIndicator scaleUnitSquareToSize:NSMakeSize(0.5, 0.5)];
    
    // calls delegate to notify when loading is finished
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
}

- (void)stopProgressAnimation {
    [progressIndicator stopAnimation:self];
}

@end
