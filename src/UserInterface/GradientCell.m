//
//  GradientCell.m
//  MacSword2
//
//  Created by Manfred Bergmann on 06.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GradientCell.h"
#import "CTGradient.h"


@implementation GradientCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[controlView lockFocus];
    
    NSRect drawRect = NSMakeRect(0.0, cellFrame.origin.y - 1, cellFrame.size.width + cellFrame.origin.x + 3, cellFrame.size.height + 1);    
	if ([self isHighlighted]) {
		if ([[controlView window] isMainWindow] &&
            [[controlView window] isKeyWindow]) {
			[[CTGradient unifiedDarkGradient] fillRect:drawRect angle:270];
		} else {
			[[CTGradient unifiedNormalGradient] fillRect:drawRect angle:270];
		}
	}
    
	[controlView unlockFocus];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    
	// titel merken
	NSString *title = [self stringValue];
    
	// hintergrund wird ohne text gepinselt
	[self setStringValue:@""];
	// den hintergrund
	[super drawWithFrame:cellFrame inView:controlView];

	// text cell
	NSTextFieldCell *textCell = [[NSTextFieldCell alloc] initTextCell:title];
    [textCell setFont:[self font]];
	[textCell drawWithFrame:cellFrame inView:controlView];
    
	// und titel wieder setzen
	[self setStringValue:title];
}
 
@end
