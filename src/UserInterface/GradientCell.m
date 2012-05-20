//
//  GradientCell.m
//  Eloquent
//
//  Created by Manfred Bergmann on 06.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GradientCell.h"
#import "CTGradient.h"


@implementation GradientCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)parentView {
	[parentView lockFocus];
    
    NSRect drawRect = NSMakeRect(0.0, cellFrame.origin.y - 1, cellFrame.size.width + cellFrame.origin.x + 3, cellFrame.size.height + 1);    
	if ([self isHighlighted]) {
		if ([[parentView window] isMainWindow] &&
            [[parentView window] isKeyWindow]) {
			[[CTGradient unifiedDarkGradient] fillRect:drawRect angle:270];
		} else {
			[[CTGradient unifiedNormalGradient] fillRect:drawRect angle:270];
		}
	}
    
	[parentView unlockFocus];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)parentView {
    
	// titel merken
	NSString *title = [self stringValue];
    
	// hintergrund wird ohne text gepinselt
	[self setStringValue:@""];
	// den hintergrund
	[super drawWithFrame:cellFrame inView:parentView];

	// text cell
	NSTextFieldCell *textCell = [[[NSTextFieldCell alloc] initTextCell:title] autorelease];
    [textCell setFont:[self font]];
	[textCell drawWithFrame:cellFrame inView:parentView];
    
	// und titel wieder setzen
	[self setStringValue:title];
}
 
@end
