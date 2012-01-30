//
//  LeftSideBarAccessoryUIController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 30.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LeftSideBarAccessoryUIController;

@protocol LeftSideBarDelegate

- (id)objectForClickedRow;
- (void)doubleClick;
- (void)reloadForController:(LeftSideBarAccessoryUIController *)aController;

@end

@class WindowHostController;

@interface LeftSideBarAccessoryUIController : NSObject {
    IBOutlet id<LeftSideBarDelegate> delegate;
    IBOutlet WindowHostController *hostingDelegate;
}

@property (assign, readwrite) id<LeftSideBarDelegate> delegate;
@property (assign, readwrite) WindowHostController *hostingDelegate;

- (id)initWithDelegate:(id<LeftSideBarDelegate>)aDelegate hostingDelegate:(WindowHostController *)aHostingDelegate;

- (void)delegateReload;
- (void)delegateDoubleClick;
- (id)delegateSelectedObject;

@end
