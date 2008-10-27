//
//  HostableViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HostableViewController.h"


@implementation HostableViewController

@synthesize hostingDelegate;
@dynamic delegate;
@synthesize viewLoaded;

- (id)init {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[HostableViewController -init]");
        viewLoaded = NO;
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

- (void)reportLoadingComplete {
    if(delegate) {
        if([delegate respondsToSelector:@selector(contentViewInitFinished:)]) {
            [delegate performSelector:@selector(contentViewInitFinished:) withObject:self];
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

- (void)adaptUIToHost {
    // does nothing here
}

@end
