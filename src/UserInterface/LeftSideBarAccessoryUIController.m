//
//  LeftSideBarAccessoryUIController.m
//  MacSword2
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

- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate {    
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
    if(delegate && [delegate respondsToSelector:@selector(reload)]) {
        [delegate performSelector:@selector(reload) withObject:self];
    }    
}

- (void)delegateDoubleClick {
    if(delegate && [delegate respondsToSelector:@selector(doubleClick)]) {
        [delegate performSelector:@selector(doubleClick)];
    }    
}

- (id)delegateSelectedObject {
    if(delegate && [delegate respondsToSelector:@selector(objectForClickedRow)]) {
        return [delegate performSelector:@selector(objectForClickedRow)];
    }
    return nil;
}

@end
