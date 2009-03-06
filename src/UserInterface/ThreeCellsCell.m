//
//  ThreeCellsCell.m
//  ThreeCellsCell
//
//  Created by Manfred Bergmann on 16.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreeCellsCell.h"
#import "CTGradient.h"

@implementation ThreeCellsCell

@synthesize image;
@synthesize numberValue;
@synthesize textColor;

- (id)init {
    self = [super init];
    if(self) {
        self.textColor = [NSColor blackColor];
        self.numberValue = nil;
        self.image = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
	ThreeCellsCell *cell = (ThreeCellsCell *)[super copyWithZone:zone];
	return cell;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[controlView lockFocus];
    
    NSRect drawRect = NSMakeRect(0.0, cellFrame.origin.y - 1, cellFrame.size.width + cellFrame.origin.x + 3, cellFrame.size.height + 1);

	if ([self isHighlighted]) {
		if ([[controlView window] isMainWindow] &&
            [[controlView window] isKeyWindow]) {
			[[CTGradient mailActiveGradient] fillRect:drawRect angle:270];
		} else {
			[[CTGradient mailInactiveGradient] fillRect:drawRect angle:270];
		}
	}
    
	[controlView unlockFocus];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {

	// titel merken
	NSString *title = [self stringValue];
	
    // image cell
    NSRect imageFrame;
    imageFrame = cellFrame;
    imageFrame.size.width = cellFrame.size.height + 6;  // we set the width of the image to height of cell
    NSImageCell *imageCell = nil;
    if(image == nil) {
        imageFrame.size.width = 0;    
    } else {
        imageCell = [[[NSImageCell alloc] initImageCell:[self image]] autorelease];
        // leave some pixels between the arrow and the image
        imageFrame.origin.x += 3;
    }
    
    // recessed button cell
    NSRect buttonFrame;
    buttonFrame = cellFrame;
    buttonFrame.size.width = 20;
    if(numberValue == nil) {
        buttonFrame.size.width = 0;
    }
    buttonFrame.origin.x = cellFrame.size.width - buttonFrame.size.width;
    
    NSSegmentedCell *buttonCell = nil;
    if(numberValue != nil) {
        buttonCell = [[[NSSegmentedCell alloc] init] autorelease];
        [buttonCell setSegmentCount:1];
        [buttonCell setSegmentStyle:NSSegmentStyleCapsule];
        [buttonCell setControlSize:NSMiniControlSize];
        [buttonCell setLabel:[numberValue stringValue] forSegment:0];
        [buttonCell setFont:[self font]];
    }
    
	// text cell
	NSTextFieldCell *textCell = [[[NSTextFieldCell alloc] initTextCell:title] autorelease];
	[textCell setTextColor:textColor];
    [textCell setFont:[self font]];
    
    // text cell
	NSRect textFrame;
	textFrame = cellFrame;
	textFrame.origin.x += imageFrame.size.width;
	textFrame.size.width -= (imageFrame.size.width + buttonFrame.size.width);

	// hintergrund wird ohne text gepinselt
	[self setStringValue: @""];
	// den hintergrund
	[super drawWithFrame:cellFrame inView:controlView];

    // draw cells
    if(imageCell) {
        [imageCell drawWithFrame:imageFrame inView:controlView];
    }
	[textCell drawWithFrame:textFrame inView:controlView];
    if(buttonCell) {
        [buttonCell drawWithFrame:buttonFrame inView:controlView];    
    }
	
	// und titel wieder setzen
	[self setStringValue:title];
}

@end
