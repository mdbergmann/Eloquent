//
//  ScrollSynchronizableView.h
//  MacSword2
//
//  Created by Manfred Bergmann on 20.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScrollSynchronizableView : NSView {
    IBOutlet NSScrollView *syncScrollView;
    IBOutlet NSTextView *textView;
}

@property (readwrite) NSScrollView *syncScrollView;
@property (readwrite) NSTextView *textView;

@end
