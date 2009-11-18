//
//  ContentDisplayingViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 18.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "ContentDisplayingViewController.h"


@implementation ContentDisplayingViewController

#pragma mark - AccessoryViewProviding

/** subclasses should provide real view */
- (NSView *)topAccessoryView {
    return nil;
}

/** subclasses should provide real view */
- (NSView *)rightAccessoryView {
    return nil;
}

#pragma mark - ProgressIndicating

- (void)beginIndicateProgress {
}

- (void)endIndicateProgress {
}

@end
