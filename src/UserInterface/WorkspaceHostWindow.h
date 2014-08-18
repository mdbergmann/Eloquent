//
//  WorkspaceHostWindow.h
//  Eloquent
//
//  Created by Manfred Bergmann on 16.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HostWindow.h"

/**
 This class is used as first responder for all the main menu actions.
 */
@interface WorkspaceHostWindow : HostWindow {
}

- (IBAction)addTab:(id)sender;

@end
