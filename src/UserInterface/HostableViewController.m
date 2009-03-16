//
//  HostableViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HostableViewController.h"
#import "ProgressOverlayViewController.h"
#import "BibleCombiViewController.h"

@implementation HostableViewController

@dynamic hostingDelegate;
@dynamic delegate;
@synthesize viewLoaded;

- (id)init {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[HostableViewController -init]");
        viewLoaded = NO;
        isLoadingComleteReported = NO;
    }
    
    return self;
}

- (id)delegate {
    return delegate;
}

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
    
    // report loaded if view has loaded
    if(viewLoaded) {
        [self reportLoadingComplete];
    }
}

- (void)adaptUIToHost {
    // does nothing here
}

- (NSString *)label {
    return @"";
}

- (id)hostingDelegate {
    return hostingDelegate;
}

- (void)setHostingDelegate:(id)aDelegate {
    hostingDelegate = aDelegate;
}

- (void)reportLoadingComplete {
    if(delegate && isLoadingComleteReported == NO) {
        if([delegate respondsToSelector:@selector(contentViewInitFinished:)]) {
            [delegate performSelector:@selector(contentViewInitFinished:) withObject:self];
            isLoadingComleteReported = YES;
        } else {
            MBLOG(MBLOG_WARN, @"[HostableViewController -reportLoadingComplete] delegate does not respond to selector!");
        }
    } else {
        MBLOG(MBLOG_WARN, @"[HostableViewController -reportLoadingComplete] no delegate set!");        
    }
}

- (void)removeFromSuperview {
    if(delegate) {
        if([delegate respondsToSelector:@selector(removeSubview:)]) {
            [delegate performSelector:@selector(removeSubview:) withObject:self];
        } else {
            MBLOG(MBLOG_WARN, @"[HostableViewController -removeSubview] delegate does not respond to selector!");
        }
    } else {
        MBLOG(MBLOG_WARN, @"[HostableViewController -removeSubview] no delegate set!");        
    }    
}

#pragma mark - ProgressIndicating

- (void)beginIndicateProgress {
    // delegate to host if needed
    // delegates can be:
    // - BibleCombiViewController
    // - SingleViewHostController
    if([delegate isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)delegate beginIndicateProgress];
    } else {
        ProgressOverlayViewController *pc = [ProgressOverlayViewController defaultController];
        if(![[[self view] subviews] containsObject:[pc view]]) {
            // we need the same size
            [[pc view] setFrame:[[self view] frame]];
            [pc startProgressAnimation];
            [[self view] addSubview:[pc view]];
            [[[self view] superview] setNeedsDisplay:YES];
        }
    }
}

- (void)endIndicateProgress {
    // delegate to host if needed
    // delegates can be:
    // - BibleCombiViewController
    // - SingleViewHostController
    if([delegate isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)delegate endIndicateProgress];
    } else {
        ProgressOverlayViewController *pc = [ProgressOverlayViewController defaultController];
        [pc stopProgressAnimation];
        if([[[self view] subviews] containsObject:[pc view]]) {
            [[pc view] removeFromSuperview];    
        }
    }
}

@end
