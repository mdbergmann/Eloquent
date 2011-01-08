//
//  ScopeBarView.h
//  Eloquent
//
//  Created by Manfred Bergmann on 28.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>


@interface ScopeBarView : NSView {
    NSImage *bgImageActive;
    NSImage *bgImageInactive;
    BOOL windowActive;
}

@property (readwrite) BOOL windowActive;
@property (retain, readwrite) NSImage *bgImageActive;
@property (retain, readwrite) NSImage *bgImageInactive;

@end
