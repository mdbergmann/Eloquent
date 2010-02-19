//
//  HostableViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HostableViewController.h"
#import "WindowHostController.h"
#import "ObjectAssotiations.h"

@implementation HostableViewController

@dynamic hostingDelegate;
@dynamic delegate;
@synthesize viewLoaded;

- (id)init {
    self = [super init];
    if(self) {
        viewLoaded = NO;
        isLoadingComleteReported = NO;
        
        // while on initialisation, set the hostingDelegate from ObjectAssotiations
        // in order to make the initialisation work
        // the hostingDelegate might get overriden with the same instance later in the init process
        self.hostingDelegate = [Assotiater currentInitialisationHost];
    }
    
    return self;
}

- (id)delegate {
    return delegate;
}

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
    
    if(viewLoaded) {
        [self reportLoadingComplete];
    }
}

/** override in subclass for custom behaviour */
- (void)adaptUIToHost {
}

- (NSString *)label {
    return @"";
}

- (WindowHostController *)hostingDelegate {
    return hostingDelegate;
}

- (void)setHostingDelegate:(WindowHostController *)aDelegate {
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

@end
