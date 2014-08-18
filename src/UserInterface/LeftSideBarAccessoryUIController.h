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
    IBOutlet id<LeftSideBarDelegate> __strong delegate;
    IBOutlet WindowHostController *__strong hostingDelegate;
}

@property (strong, readwrite) id<LeftSideBarDelegate> delegate;
@property (strong, readwrite) WindowHostController *hostingDelegate;

- (id)initWithDelegate:(id<LeftSideBarDelegate>)aDelegate hostingDelegate:(WindowHostController *)aHostingDelegate;

- (void)delegateReload;
- (void)delegateDoubleClick;
- (id)delegateSelectedObject;

@end
