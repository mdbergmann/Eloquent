//
//  WindowHostController+SplitViewDelegate.m
//  Eloquent
//
//  Created by Manfred Bergmann on 29.03.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "HostableViewController.h"
#import "WindowHostController+SplitViewDelegate.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "LeftSideBarViewController.h"
#import "RightSideBarViewController.h"

@implementation WindowHostController (SplitViewDelegate)

#pragma mark - NSSplitView delegate methods

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize {
    //detect if it's a window resize
    if([sender inLiveResize]) {
        //CocoLog(LEVEL_DEBUG, @"splitView live resize");
        [self resizeSplitView:sender];
    } else {
        //CocoLog(LEVEL_DEBUG, @"splitView no live resize");
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
                [userDefaults setInteger:(NSInteger) s.width forKey:DefaultsLSBWidth];
            }
        } else if(sv == contentSplitView) {
            NSSize s = [[rsbViewController view] frame].size;
            if(s.width > 10) {
                rsbWidth = (float) s.width;
                [userDefaults setInteger:(NSInteger) s.width forKey:DefaultsRSBWidth];
            }
        }
    }
}

@end
