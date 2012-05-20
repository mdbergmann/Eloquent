//
//  BookmarkCell.m
//  Eloquent
//
//  Created by Manfred Bergmann on 27.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "BookmarkCell.h"
#import "globals.h"
#import "Bookmark.h"

#define IMAGE_HEIGHT        16
#define IMAGE_WIDTH         16
#define IMAGE_Y_OFFSET      2.0
#define IMAGE_X_OFFSET      3.0
#define BMTITLE_HEIGHT      IMAGE_HEIGHT
#define BMTITLE_Y_OFFSET    3.0
#define BMTITLE_X_OFFSET    2.0
#define BMREF_HEIGHT        12
#define BMREF_Y_OFFSET      0.0

@implementation BookmarkCell

@synthesize image;
@synthesize bookmark;

- (id)init {
    self = [super init];
    if(self) {
        [self setImage:nil];
        [self setBookmark:nil];
        bmRefFont = [FontTiny retain];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
	BookmarkCell *cell = (BookmarkCell *)[super copyWithZone:zone];
    cell->image = [image retain];
    cell->bookmark = [bookmark retain];
	return cell;
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [bmRefFont release];
    [image release];
    [bookmark release];
    [super dealloc];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)parentView {
    
	// draw background without text
	[self setStringValue:@""];
	[super drawWithFrame:cellFrame inView:parentView];

    // left image frame
    NSRect imageFrame;
    imageFrame = cellFrame;
    imageFrame.origin.x += IMAGE_X_OFFSET;
    imageFrame.origin.y += IMAGE_Y_OFFSET;
    imageFrame.size.width = IMAGE_WIDTH;
    imageFrame.size.height = IMAGE_HEIGHT;    
    // image cell
    NSImageCell *imageCell = nil;
    if(image == nil) {
        imageFrame.size.width = 0;    
    } else {
        imageCell = [[[NSImageCell alloc] initImageCell:[self image]] autorelease];
        [imageCell setImageAlignment:NSImageAlignCenter];
    }
        
    // bookmark title frame
	NSRect bmTitleFrame;
	bmTitleFrame = cellFrame;
	bmTitleFrame.origin.x += IMAGE_WIDTH + BMTITLE_X_OFFSET;
    bmTitleFrame.origin.y += BMTITLE_Y_OFFSET;
    bmTitleFrame.size.height = BMTITLE_HEIGHT;
	bmTitleFrame.size.width -= IMAGE_WIDTH;    
    // draw image cells
    if(imageCell) {
        [imageCell drawWithFrame:imageFrame inView:parentView];
    }    
	// draw bookmark title cell
	NSTextFieldCell *bmTitleCell = [[[NSTextFieldCell alloc] initTextCell:[bookmark name]] autorelease];
    [bmTitleCell setWraps:NO];
    [bmTitleCell setTruncatesLastVisibleLine:YES];
    [bmTitleCell setLineBreakMode:NSLineBreakByTruncatingTail];
    [bmTitleCell setFont:[self font]];
	[bmTitleCell drawWithFrame:bmTitleFrame inView:parentView];
    
    // bookmark reference frame
	NSRect bmRefFrame;
	bmRefFrame = cellFrame;
    bmRefFrame.origin.y += BMTITLE_HEIGHT + BMTITLE_Y_OFFSET + BMREF_Y_OFFSET;
    bmRefFrame.size.height = BMREF_HEIGHT;
	// draw bookmark ref cell
	NSTextFieldCell *bmRefCell = [[[NSTextFieldCell alloc] initTextCell:[bookmark reference]] autorelease];
    [bmRefCell setWraps:NO];
    [bmRefCell setTruncatesLastVisibleLine:YES];
    [bmRefCell setLineBreakMode:NSLineBreakByTruncatingTail];
    [bmRefCell setFont:bmRefFont];
	[bmRefCell drawWithFrame:bmRefFrame inView:parentView];
}

@end
