//
//  ThreeCellsCell.m
//  ThreeCellsCell
//
//  Created by Manfred Bergmann on 16.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ThreeCellsCell.h"

#define RADIUS 7.0
#define WIDTH_MIN 20
#define MARGIN_X 7
#define MARGIN_Y 1

@interface ThreeCellsCell ()

@property(readwrite, retain) NSFont *countFont;

@end

@implementation ThreeCellsCell

@synthesize image;
@synthesize rightImage;
@synthesize rightCounter;
@synthesize leftCounter;
@synthesize countFont;

- (id)init {
    self = [super init];
    if(self) {
        [self setRightCounter:0];
        [self setLeftCounter:0];
        [self setImage:nil];
        [self setRightImage:nil];
        [self setCountFont:[[NSFontManager sharedFontManager] convertFont:[NSFont fontWithName:@"Helvetica" size:11.0] toHaveTrait:NSBoldFontMask]];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
	ThreeCellsCell *cell = (ThreeCellsCell *)[super copyWithZone:zone];
    cell->image = [image retain];
    cell->rightImage = [rightImage retain];
    cell->countFont = [countFont retain];
	return cell;
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [image release];
    [rightImage release];
    [countFont release];
    [super dealloc];
}

- (NSAttributedString *)attributedObjectLeftCountValue {
    NSString *contents = [NSString stringWithFormat:@"%i", leftCounter];
    // hightlighted?
    NSDictionary *attr;
    if(![self isHighlighted]) {
        attr = [[[NSDictionary alloc] initWithObjectsAndKeys:countFont, NSFontAttributeName,
                 [[NSColor whiteColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
                 nil, nil] autorelease];        
    } else {
        attr = [[[NSDictionary alloc] initWithObjectsAndKeys:countFont, NSFontAttributeName,
                 [[NSColor darkGrayColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
                 nil, nil] autorelease];
    }
    
    return [[[NSMutableAttributedString alloc] initWithString:contents attributes:attr] autorelease];
}

- (NSAttributedString *)attributedObjectRightCountValue {
    NSString *contents = [NSString stringWithFormat:@"%i", rightCounter];
    // hightlighted?
    NSDictionary *attr;
    if(![self isHighlighted]) {
        attr = [[[NSDictionary alloc] initWithObjectsAndKeys:countFont, NSFontAttributeName,
                 [[NSColor whiteColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
                 nil, nil] autorelease];        
    } else {
        attr = [[[NSDictionary alloc] initWithObjectsAndKeys:countFont, NSFontAttributeName,
                 [[NSColor darkGrayColor] colorWithAlphaComponent:0.85], NSForegroundColorAttributeName,
                 nil, nil] autorelease];
    }
    
    return [[[NSMutableAttributedString alloc] initWithString:contents attributes:attr] autorelease];
}

- (NSRect)counterRectForCellFrame:(NSRect)cellFrame {
    if(leftCounter == 0 && rightCounter == 0) {
        return NSZeroRect;
    }
    
    float counterWidth = 0;
    if(leftCounter != 0) {
        counterWidth += [[self attributedObjectLeftCountValue] size].width;
    }
    if(rightCounter != 0) {
        counterWidth += [[self attributedObjectRightCountValue] size].width;        
    }
    
    if(leftCounter != 0 && rightCounter != 0) {
        counterWidth += (2 * RADIUS + 10.0);
    } else {
        counterWidth += (2 * RADIUS - 5.0);    
    }
    if (counterWidth < WIDTH_MIN) {
        counterWidth = WIDTH_MIN;
    }
    
    NSRect result;
    result.size = NSMakeSize(counterWidth, 2 * RADIUS); // temp
    result.origin.x = cellFrame.origin.x + cellFrame.size.width - MARGIN_X - result.size.width;
    result.origin.y = cellFrame.origin.y + MARGIN_Y + 3.0;
    
    return result;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)parentView {
    
	// backup title
	NSString *title = [self stringValue];
	    
    // left image frame
    NSRect imageFrame;
    imageFrame = cellFrame;
    imageFrame.size.width = cellFrame.size.height + 6;  // we set the width of the image to height of cell
    // image cell
    NSImageCell *imageCell = nil;
    if(image == nil) {
        imageFrame.size.width = 0;    
    } else {
        imageCell = [[[NSImageCell alloc] initImageCell:[self image]] autorelease];
        [imageCell setImageAlignment:NSImageAlignCenter];
        // leave some pixels between the arrow and the image
        imageFrame.origin.x += 3;
    }
    
    // numberValue frame
    NSRect counterRect = [self counterRectForCellFrame:cellFrame];
    // right frame
    NSRect rightFrame;
    rightFrame = cellFrame;
    if(leftCounter == 0 && rightCounter == 0 && rightImage == nil) {
        rightFrame.size.width = 0;
    }
    // right cell
    NSCell *rightCell = nil;
    // counter part drawing
    if(rightCounter > 0 && leftCounter > 0) {
        rightFrame = counterRect;
        NSBezierPath *path = [NSBezierPath bezierPath];
        // set color for drawing
        if(![self isHighlighted]) {
            [[NSColor colorWithCalibratedWhite:0.3 alpha:0.6] set];
        } else {
            [[NSColor whiteColor] set];            
        }
        // we start on the right side
        NSPoint point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2.0, counterRect.origin.y);
        [path moveToPoint:point];
        // draw line to begin of right arc
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y);
        [path lineToPoint:point];
        // position of center for arc
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y + RADIUS);
        // draw right half arc
        [path appendBezierPathWithArcWithCenter:point radius:RADIUS startAngle:270.0 endAngle:90.0 clockwise:NO];
        // draw top line until mid
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2, counterRect.origin.y + counterRect.size.height);
        [path lineToPoint:point];
        // draw line to buttom
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2, counterRect.origin.y);
        [path lineToPoint:point];
        // fill this bezier
        [path fill];
        [path setLineWidth:0.5];
        [[NSColor blackColor] set];
        [path stroke];
        
        // draw attributed string centered in right area
        NSRect counterStringRect;
        NSAttributedString *counterString = [self attributedObjectRightCountValue];
        counterStringRect.size = [counterString size];
        counterStringRect.origin.x = counterRect.origin.x + counterRect.size.width/2.0 + ((counterRect.size.width/2.0 - counterStringRect.size.width) / 2.0) + 0.25;
        counterStringRect.origin.y = counterRect.origin.y + ((counterRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
        [counterString drawInRect:counterStringRect];
        
        // now draw left side
        if(![self isHighlighted]) {
            [[NSColor colorWithDeviceRed:0.3 green:0.2 blue:0.1 alpha:1.0] set];
        } else {
            [[NSColor whiteColor] set];            
        }
        path = [NSBezierPath bezierPath];
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2, counterRect.origin.y);
        [path moveToPoint:point];
        // draw line to begin of arc on left side
        point = NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y);
        [path lineToPoint:point];
        // draw half arc on left
        point = NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + RADIUS);
        [path appendBezierPathWithArcWithCenter:point radius:RADIUS startAngle:270.0 endAngle:90.0 clockwise:YES];
        // move point to top of arc
        //point = NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + counterRect.size.height);
        //[path moveToPoint:point];
        // draw to mid
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2, counterRect.origin.y + counterRect.size.height);    
        [path lineToPoint:point];
        // draw line to buttom
        point = NSMakePoint(counterRect.origin.x + counterRect.size.width/2, counterRect.origin.y);
        [path lineToPoint:point];
        // fill this bezier
        [path fill];
        [path setLineWidth:0.5];
        [[NSColor grayColor] set];
        [path stroke];
        
        // draw attributed string centered in left area
        counterString = [self attributedObjectLeftCountValue];
        counterStringRect.size = [counterString size];
        counterStringRect.origin.x = counterRect.origin.x + ((counterRect.size.width/2.0 - counterStringRect.size.width) / 2.0) + 0.25;
        counterStringRect.origin.y = counterRect.origin.y + ((counterRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
        [counterString drawInRect:counterStringRect];
    } else if(leftCounter > 0 && rightCounter == 0) {
        rightFrame = counterRect;
        // set color for drawing
        if(![self isHighlighted]) {
            [[NSColor colorWithCalibratedWhite:0.3 alpha:0.6] set];
        } else {
            [[NSColor whiteColor] set];            
        }
        NSBezierPath *path = [NSBezierPath bezierPath];
        counterRect.origin.y -= 1.0;
        [path moveToPoint:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y)];
        [path lineToPoint:NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y + RADIUS) radius:RADIUS startAngle:270.0 endAngle:90.0];
        [path lineToPoint:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + counterRect.size.height)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + RADIUS) radius:RADIUS startAngle:90.0 endAngle:270.0];
        [path fill];
        [path setLineWidth:0.5];
        [[NSColor grayColor] set];
        [path stroke];
        
        // draw attributed string centered in area
        NSRect counterStringRect;
        NSAttributedString *counterString = [self attributedObjectLeftCountValue];
        counterStringRect.size = [counterString size];
        counterStringRect.origin.x = counterRect.origin.x + ((counterRect.size.width - counterStringRect.size.width) / 2.0) + 0.25;
        counterStringRect.origin.y = counterRect.origin.y + ((counterRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
        [counterString drawInRect:counterStringRect];        
    } else if(leftCounter == 0 && rightCounter > 0) {
        rightFrame = counterRect;
        // set color for drawing
        if(![self isHighlighted]) {
            [[NSColor colorWithDeviceRed:0.3 green:0.2 blue:0.1 alpha:1.0] set];
        } else {
            [[NSColor whiteColor] set];            
        }
        NSBezierPath *path = [NSBezierPath bezierPath];
        counterRect.origin.y -= 1.0;
        [path moveToPoint:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y)];
        [path lineToPoint:NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(counterRect.origin.x + counterRect.size.width - RADIUS, counterRect.origin.y + RADIUS) radius:RADIUS startAngle:270.0 endAngle:90.0];
        [path lineToPoint:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + counterRect.size.height)];
        [path appendBezierPathWithArcWithCenter:NSMakePoint(counterRect.origin.x + RADIUS, counterRect.origin.y + RADIUS) radius:RADIUS startAngle:90.0 endAngle:270.0];
        [path fill];
        [path setLineWidth:0.5];
        [[NSColor grayColor] set];
        [path stroke];
        
        // draw attributed string centered in area
        NSRect counterStringRect;
        NSAttributedString *counterString = [self attributedObjectRightCountValue];
        counterStringRect.size = [counterString size];
        counterStringRect.origin.x = counterRect.origin.x + ((counterRect.size.width - counterStringRect.size.width) / 2.0) + 0.25;
        counterStringRect.origin.y = counterRect.origin.y + ((counterRect.size.height - counterStringRect.size.height) / 2.0) + 0.5;
        [counterString drawInRect:counterStringRect];        
    } else if(rightImage != nil) {
        rightFrame.size.width = [rightImage size].width;
        rightFrame.origin.x = (cellFrame.origin.x + cellFrame.size.width) - (rightFrame.size.width + 5);
        rightCell = [[[NSImageCell alloc] initImageCell:rightImage] autorelease];
        [(NSImageCell *)rightCell setImageAlignment:NSImageAlignCenter];
    }
    
    // text frame
	NSRect textFrame;
	textFrame = cellFrame;
	textFrame.origin.x += imageFrame.size.width + 2.0;
    textFrame.origin.y += 1.0;
    textFrame.size.height -= 2.0;
	textFrame.size.width -= (imageFrame.size.width + rightFrame.size.width + 8.0);
    
    // draw cells
    if(imageCell) {
        [imageCell drawWithFrame:imageFrame inView:parentView];
    }
    // draw right cell
    if(rightCell) {
        [rightCell drawWithFrame:rightFrame inView:parentView];    
    }
    // draw text cell
	[super drawWithFrame:textFrame inView:parentView];
	
	// und titel wieder setzen
	[self setStringValue:title];
}

@end
