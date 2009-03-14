//
//  MBTextView.m
//  MacSword2
//
//  Created by Manfred Bergmann on 31.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MBTextView.h"


@implementation MBTextView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

/** we react on save menu item */
- (IBAction)saveDocument:(id)sender {
    [[self delegate] saveDocument:sender];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    
    if([menuItem action] == @selector(saveDocument:)) {
        if(![self isEditable]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return [super validateMenuItem:menuItem];
    }
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    MBLOGV(MBLOG_DEBUG, @"[MBTextView -menuForEvent:] %@\n", [event description]);
    
    NSMenu *ret = [[self delegate] menuForEvent:event];
    if(!ret) {
        ret = [super menuForEvent:event];
    }
    
    return ret;
}

/*
- (void)resetCursorRects {
    // The resetCursorRects is called by the system, please see the documentation on it
    // This implementation looks for links in the current text, and adds appropriate cursor rects

    MBLOG(MBLOG_DEBUG, @"[MBTextView -resetCursorRects:]...");

	NSTextStorage * contents;
	NSRange effectiveRange;
	NSURL * linkURL;
	int	i = 0;
	contents = [self textStorage];
	while (i < [contents length]) {
		linkURL = [contents attribute:NSLinkAttributeName atIndex:i effectiveRange:&effectiveRange];
		if(linkURL) {
			NSRange glyphRange;
			NSRect	boundingRect;
            
			glyphRange = [[self layoutManager] glyphRangeForCharacterRange:effectiveRange actualCharacterRange:nil];
			boundingRect = [[self layoutManager] boundingRectForGlyphRange:glyphRange inTextContainer:[self textContainer]];
			[self addCursorRect:boundingRect cursor:[NSCursor pointingHandCursor]];
		}
		i += effectiveRange.length;
	}    
    MBLOG(MBLOG_DEBUG, @"[MBTextView -resetCursorRects:]...done");
}
*/

@end
