//
//  ScopeBarView.h
//  MacSword2
//
//  Created by Manfred Bergmann on 28.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ScopeBarView : NSView {
    // the image
    NSImage *bgImageActive;
    NSImage *bgImageNoneActive;
    BOOL windowActive;
}

@property (retain, readwrite) NSImage *bgImageActive;
@property (retain, readwrite) NSImage *bgImageNoneActive;
@property (readwrite) BOOL windowActive;

@end
