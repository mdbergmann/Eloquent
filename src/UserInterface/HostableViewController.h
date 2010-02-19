//
//  HostableViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@class WindowHostController;

@interface HostableViewController : NSViewController {
    IBOutlet id delegate;
    IBOutlet WindowHostController *hostingDelegate;
    
    BOOL viewLoaded;    
    BOOL isLoadingComleteReported;
}

// properties
@property (assign, readwrite) id delegate;
@property (assign, readwrite) WindowHostController *hostingDelegate;
@property (readwrite) BOOL viewLoaded;

- (void)reportLoadingComplete;

- (void)removeFromSuperview;
- (void)adaptUIToHost;
- (NSString *)label;

@end
