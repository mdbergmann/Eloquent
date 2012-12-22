//
//  ThickDividerSplitView.m
//  Eloquent
//
//  Created by Manfred Bergmann on 15.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ThickDividerSplitView.h"


@implementation ThickDividerSplitView

- (void)awakeFromNib {
	bar = [NSImage imageNamed:@"SplitViewDividerBar.tiff"];
	[bar setFlipped:YES];
    
	grip = [NSImage imageNamed:@"SplitViewDividerDimple.tiff"];
	[grip setFlipped:YES];
}

- (CGFloat)dividerThickness {
	return (10.0);
}

- (void)drawDividerInRect:(NSRect)aRect {	
    // Create a canvas
	NSImage *canvas = [[[NSImage alloc] initWithSize:aRect.size] autorelease];
	
    // Draw bar and grip onto the canvas
	NSRect canvasRect = NSMakeRect(0, 0, [canvas size].width, [canvas size].height);
	NSRect gripRect = canvasRect;
	gripRect.origin.x = (NSMidX(canvasRect) - ([grip size].width/2));
	gripRect.origin.y = (NSMidY(canvasRect) - ([grip size].height/2));
	[canvas lockFocus];
	[bar setSize:aRect.size];
	[bar drawInRect:canvasRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[grip drawInRect:gripRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[canvas unlockFocus];
	
    // Draw canvas to divider bar
	[self lockFocus];
	[canvas drawInRect:aRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[self unlockFocus];
}

@end
