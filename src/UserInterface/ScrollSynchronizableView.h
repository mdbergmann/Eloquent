//
//  ScrollSynchronizableView.h
//  Eloquent
//
//  Created by Manfred Bergmann on 20.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScrollSynchronizableView : NSView {
    IBOutlet NSScrollView *syncScrollView;
    IBOutlet NSTextView *textView;
}

@property (retain, readwrite) NSScrollView *syncScrollView;
@property (retain, readwrite) NSTextView *textView;

@end
