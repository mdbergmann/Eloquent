//
//  WorkspaceHostWindow.m
//  Eloquent
//
//  Created by Manfred Bergmann on 16.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WorkspaceHostWindow.h"


@implementation WorkspaceHostWindow

- (IBAction)addTab:(id)sender {
    [[self delegate] performSelector:@selector(addTab:) withObject:sender];
}

@end
