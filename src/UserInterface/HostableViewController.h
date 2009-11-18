//
//  HostableViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@interface HostableViewController : NSViewController {
    // the delegate
    IBOutlet id delegate;
    
    // hosting component
    id hostingDelegate;
    
    // is view loaded?
    BOOL viewLoaded;
    
    // has been reported loading complete already?
    BOOL isLoadingComleteReported;
}

// properties
@property (assign, readwrite) id delegate;
@property (assign, readwrite) id hostingDelegate;
@property (readwrite) BOOL viewLoaded;

- (void)reportLoadingComplete;

// host data
- (void)removeFromSuperview;
- (void)adaptUIToHost;
- (NSString *)label;

@end
