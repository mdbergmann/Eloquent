//
//  LeftSideBarAccessoryUIController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 30.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LeftSideBarAccessoryUIController : NSObject {
    IBOutlet id delegate;
    IBOutlet id hostingDelegate;
}

@property (readwrite) id delegate;
@property (readwrite) id hostingDelegate;

- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate;

- (void)delegateReload;
- (void)delegateDoubleClick;
- (id)delegateSelectedObject;

@end
