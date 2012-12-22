//
//  WindowHostController+SplitViewDelegate.h
//  Eloquent
//
//  Created by Manfred Bergmann on 29.03.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowHostController.h"

@interface WindowHostController (SplitViewDelegate)

- (void)resizeSplitView:(NSSplitView *)aSplitView;

@end
