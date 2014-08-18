//
//  FullScreenView.m
//  Eloquent
//
//  Created by Manfred Bergmann on 09.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FullScreenView.h"
#import "ToolbarController.h"

@interface FullScreenView ()

@end

@implementation FullScreenView

@synthesize delegate;
@synthesize toolbarController;

- (BOOL)isFullScreenMode {
    return [self isInFullScreenMode];
}

#pragma mark - Mouse tracking

@end
