//
//  HostableViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <ProtocolHelper.h>

@interface HostableViewController : NSViewController <ProgressIndicating> {
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

/** report the loading of the view is completed */
- (void)reportLoadingComplete;
- (void)removeFromSuperview;
- (void)adaptUIToHost;
- (NSString *)label;

// ProgressIndicating
- (void)beginIndicateProgress;
- (void)endIndicateProgress;

@end
