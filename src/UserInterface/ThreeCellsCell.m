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
@synthesize rightImage;
@synthesize numberValue;
@synthesize textColor;

- (id)init {
    self = [super init];
    if(self) {
        self.numberValue = nil;
        self.image = nil;
        self.rightImage = nil;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
	ThreeCellsCell *cell = (ThreeCellsCell *)[super copyWithZone:zone];
	return cell;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[controlView lockFocus];
    
    NSRect drawRect = NSMakeRect(0.0, cellFrame.origin.y - 0.5, cellFrame.size.width + cellFrame.origin.x + 3, cellFrame.size.height);

	if ([self isHighlighted]) {
		if ([[controlView window] isMainWindow] &&
            [[controlView window] isKeyWindow]) {
			[[CTGradient mailActiveGradient] fillRect:drawRect angle:270];
            [self setTextColor:[NSColor whiteColor]];
		} else {
			[[CTGradient mailInactiveGradient] fillRect:drawRect angle:270];
            [self setTextColor:[NSColor blackColor]];
		}
	}
    
	[controlView unlockFocus];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {

	// titel merken
	NSString *title = [self stringValue];
	
	// hintergrund wird ohne text gepinselt
	[self setStringValue: @""];
	// den hintergrund
	[super drawWithFrame:cellFrame inView:controlView];

    // left image frame
    NSRect imageFrame;
    imageFrame = cellFrame;
    imageFrame.size.width = cellFrame.size.height + 6;  // we set the width of the image to height of cell
    // image cell
    NSImageCell *imageCell = nil;
    if(image == nil) {
        imageFrame.size.width = 0;    
    } else {
        imageCell = [[NSImageCell alloc] initImageCell:[self image]];
        [imageCell setImageAlignment:NSImageAlignCenter];
        // leave some pixels between the arrow and the image
        imageFrame.origin.x += 3;
    }
    
    // right frame
    NSRect rightFrame;
    rightFrame = cellFrame;
    rightFrame.size.width = 20;
    if(numberValue == nil && rightImage == nil) {
        rightFrame.size.width = 0;
    } else if(rightImage != nil) {
        rightFrame.size.width = [rightImage size].width;
    }
    rightFrame.origin.x = (cellFrame.origin.x + cellFrame.size.width) - (rightFrame.size.width + 5);
    // right cell
    NSCell *rightCell = nil;
    if(numberValue != nil) {
        rightCell = [[NSSegmentedCell alloc] init];
        [(NSSegmentedCell *)rightCell setSegmentCount:1];
        [(NSSegmentedCell *)rightCell setSegmentStyle:NSSegmentStyleCapsule];
        [(NSSegmentedCell *)rightCell setControlSize:NSMiniControlSize];
        [(NSSegmentedCell *)rightCell setLabel:[numberValue stringValue] forSegment:0];
        [(NSSegmentedCell *)rightCell setFont:[self font]];
    } else if(rightImage != nil) {
        rightCell = [[NSImageCell alloc] initImageCell:rightImage];
        [(NSImageCell *)rightCell setImageAlignment:NSImageAlignCenter];
    }

    // text frame
	NSRect textFrame;
	textFrame = cellFrame;
	textFrame.origin.x += imageFrame.size.width + 3;
	textFrame.size.width -= (imageFrame.size.width + rightFrame.size.width);
	// text cell
	NSTextFieldCell *textCell = [[NSTextFieldCell alloc] initTextCell:title];
	[textCell setTextColor:[self textColor]];
    [textCell setFont:[self font]];
        
    // draw cells
    if(imageCell) {
        [imageCell drawWithFrame:imageFrame inView:controlView];
    }
    // draw text cell
	[textCell drawWithFrame:textFrame inView:controlView];
    // draw right cell
    if(rightCell) {
        [rightCell drawWithFrame:rightFrame inView:controlView];    
    }
	
	// und titel wieder setzen
	[self setStringValue:title];
}

@end
