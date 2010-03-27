//
//  ScopeBarView.h
//  MacSword2
//
//  Created by Manfred Bergmann on 28.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>


@interface ScopeBarView : NSView {
    NSColor *activeTopLine;
    NSColor *activeFill;
    NSColor *inactiveTopLine;
    NSColor *inactiveFill;
    BOOL windowActive;
}

@property (readwrite) BOOL windowActive;

@end
