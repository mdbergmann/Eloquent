//
//  OptionsHeaderView.h
//  Eloquent
//
//  Created by Manfred Bergmann on 28.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OptionsHeaderView : NSView {
    // the image
    NSImage *bgImage;
}

@property (retain, readwrite) NSImage *bgImage;

@end
