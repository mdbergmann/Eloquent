//
//  WindowHostController+SplitViewDelegate.m
//  MacSword2
//
//  Created by Manfred Bergmann on 29.03.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "WindowHostController+SplitViewDelegate.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "LeftSideBarViewController.h"

@implementation WindowHostController (SplitViewDelegate)

#pragma mark - NSSplitView delegate methods

/*
- (void)setMinimumLength:(CGFloat)minLength forViewAtIndex:(NSInteger)viewIndex {
	if (!lengthsByViewIndex) {
		lengthsByViewIndex = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	[lengthsByViewIndex setObject:[NSNumber numberWithDouble:minLength]
                           forKey:[NSNumber numberWithInteger:viewIndex]];
}

- (void)setPriority:(NSInteger)priorityIndex forViewAtIndex:(NSInteger)viewIndex {
	if (!viewIndicesByPriority) {
		viewIndicesByPriority = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	[viewIndicesByPriority setObject:[NSNumber numberWithInteger:viewIndex]
                              forKey:[NSNumber numberWithInteger:priorityIndex]];
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset {
	NSView *subview = [[sender subviews] objectAtIndex:offset];
	NSRect subviewFrame = subview.frame;
	CGFloat frameOrigin;
	if ([sender isVertical]) {
		frameOrigin = subviewFrame.origin.x;
	} else {
		frameOrigin = subviewFrame.origin.y;
	}
	
	CGFloat minimumSize = [[lengthsByViewIndex objectForKey:[NSNumber numberWithInteger:offset]] doubleValue];
	
	return frameOrigin + minimumSize;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset {
	NSView *growingSubview = [[sender subviews] objectAtIndex:offset];
	NSView *shrinkingSubview = [[sender subviews] objectAtIndex:offset + 1];
	NSRect growingSubviewFrame = growingSubview.frame;
	NSRect shrinkingSubviewFrame = shrinkingSubview.frame;
	CGFloat shrinkingSize;
	CGFloat currentCoordinate;
	if([sender isVertical]) {
		currentCoordinate =
        growingSubviewFrame.origin.x + growingSubviewFrame.size.width;
		shrinkingSize = shrinkingSubviewFrame.size.width;
	} else {
		currentCoordinate =
        growingSubviewFrame.origin.y + growingSubviewFrame.size.height;
		shrinkingSize = shrinkingSubviewFrame.size.height;
	}
	
	CGFloat minimumSize =
    [[lengthsByViewIndex objectForKey:[NSNumber numberWithInteger:offset + 1]] doubleValue];
	
	return currentCoordinate + (shrinkingSize - minimumSize);
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
	NSArray *subviews = [sender subviews];
	NSInteger subviewsCount = [subviews count];
	
	BOOL isVertical = [sender isVertical];
	
	CGFloat delta = [sender isVertical] ?
    (sender.bounds.size.width - oldSize.width) :
    (sender.bounds.size.height - oldSize.height);
	
	NSInteger viewCountCheck = 0;
	
	for (NSNumber *priorityIndex in [[viewIndicesByPriority allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
		NSNumber *viewIndex = [viewIndicesByPriority objectForKey:priorityIndex];
		NSInteger viewIndexValue = [viewIndex integerValue];
		if(viewIndexValue >= subviewsCount) {
			continue;
		}
		
		NSView *view = [subviews objectAtIndex:viewIndexValue];
		
		NSSize frameSize = [view frame].size;
		NSNumber *minLength = [lengthsByViewIndex objectForKey:viewIndex];
		CGFloat minLengthValue = [minLength doubleValue];
		
		if(isVertical) {
			frameSize.height = sender.bounds.size.height;
			if (delta > 0 ||
				frameSize.width + delta >= minLengthValue) {
				frameSize.width += delta;
				delta = 0;
			} else if (delta < 0) {
				delta += frameSize.width - minLengthValue;
				frameSize.width = minLengthValue;
			}
		} else {
			frameSize.width = sender.bounds.size.width;
			if (delta > 0 ||
				frameSize.height + delta >= minLengthValue) {
				frameSize.height += delta;
				delta = 0;
			} else if (delta < 0) {
				delta += frameSize.height - minLengthValue;
				frameSize.height = minLengthValue;
			}
		}
		
		[view setFrameSize:frameSize];
		viewCountCheck++;
	}
	
	NSAssert1(viewCountCheck == [subviews count],
              @"Number of valid views in priority list is less than the subview count"
              @" of split view %p.",
              sender);
	NSAssert3(fabs(delta) < 0.5,
              @"Split view %p resized smaller than minimum %@ of %f",
              sender,
              isVertical ? @"width" : @"height",
              sender.frame.size.width - delta);
	
	CGFloat offset = 0;
	CGFloat dividerThickness = [sender dividerThickness];
	for (NSView *subview in subviews) {
		NSRect viewFrame = subview.frame;
		NSPoint viewOrigin = viewFrame.origin;
		viewOrigin.x = offset;
		[subview setFrameOrigin:viewOrigin];
		offset += viewFrame.size.width + dividerThickness;
	}
}
*/

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    //detect if it's a window resize
    if([sender inLiveResize]) {
        MBLOG(MBLOG_DEBUG, @"splitView live resize");
        [self resizeSplitView:sender];
    } else {
        MBLOG(MBLOG_DEBUG, @"splitView no live resize");
        if(inFullScreenTransition) {
            [self resizeSplitView:sender];            
        } else {
            [sender adjustSubviews];            
        }
    }
}

- (void)resizeSplitView:(NSSplitView *)aSplitView {
    //info needed
    NSRect tmpRect = [aSplitView bounds];
    NSArray *subviews = [aSplitView subviews];
    
    if(aSplitView == mainSplitView) {
        NSView *left = nil;
        NSRect leftRect = NSZeroRect;
        NSView *mid = nil;
        if([subviews count] > 1) {
            left = [subviews objectAtIndex:0];
            leftRect = [left bounds];
            mid = [subviews objectAtIndex:1];
        } else {
            mid = [subviews objectAtIndex:0];                
        }
        
        // left side stays fixed
        if(left) {
            tmpRect.size.width = leftRect.size.width;
            tmpRect.origin.x = 0;
            [left setFrame:tmpRect];                
        }
        
        // mid dynamic
        tmpRect.size.width = [aSplitView bounds].size.width - (leftRect.size.width + [aSplitView dividerThickness]);
        tmpRect.origin.x = leftRect.size.width + [aSplitView dividerThickness];
        [mid setFrame:tmpRect];
    } else if(aSplitView == contentSplitView) {
        NSView *left = [subviews objectAtIndex:0];
        NSView *right = nil;
        NSRect rightRect = NSZeroRect;
        if([subviews count] > 1) {
            right = [subviews objectAtIndex:1];
            rightRect = [right bounds];
        }
        
        // left side is dynamic
        tmpRect.size.width = [aSplitView bounds].size.width - (rightRect.size.width + [aSplitView dividerThickness]);
        tmpRect.origin.x = 0;
        [left setFrame:tmpRect];
        
        // right is fixed
        tmpRect.size.width = rightRect.size.width;
        tmpRect.origin.x = [aSplitView bounds].size.width - (rightRect.size.width + [aSplitView dividerThickness]) + 1;
        [right setFrame:tmpRect];
    }    
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification {
    if(hostLoaded) {
        NSSplitView *sv = [aNotification object];
        if(sv == mainSplitView) {
            NSSize s = [[lsbViewController view] frame].size;
            if(s.width > 20) {
                [userDefaults setInteger:s.width forKey:DefaultsLSBWidth];
            }
        } else if(sv == contentSplitView) {
            NSSize s = [[rsbViewController view] frame].size;
            if(s.width > 10) {
                rsbWidth = s.width;
                [userDefaults setInteger:rsbWidth forKey:DefaultsRSBWidth];
            }
        }        
    }
}

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
    if(splitView == mainSplitView) {
        return [[lsbViewController resizeControl] convertRect:[(NSView *)[lsbViewController resizeControl] bounds] toView:splitView];
    }
    
    return NSZeroRect;
}

@end
