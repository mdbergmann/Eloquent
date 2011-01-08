//
//  LeftSideBarAccessoryUIController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 30.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "LeftSideBarAccessoryUIController.h"


@implementation LeftSideBarAccessoryUIController

@synthesize delegate;
@synthesize hostingDelegate;

- (id)init {
    return [super init];
}

- (id)initWithDelegate:(id<LeftSideBarDelegate>)aDelegate hostingDelegate:(WindowHostController *)aHostingDelegate {    
    self = [self init];
    if(self) {
        self.delegate = aDelegate;
        self.hostingDelegate = aHostingDelegate;        
    }
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)delegateReload {
    [delegate reloadForController:self];
}

- (void)delegateDoubleClick {
    [delegate doubleClick];
}

- (id)delegateSelectedObject {
    return [delegate objectForClickedRow];
}

@end
