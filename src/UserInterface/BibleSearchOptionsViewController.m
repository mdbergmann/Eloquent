//
//  BibleSearchOptionsController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 10.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BibleSearchOptionsViewController.h"


@implementation BibleSearchOptionsViewController

@synthesize target;

- (id)initWithDelegate:(id)aDelegate andTarget:(id)aTarget {
    self = [super initWithDelegate:aDelegate andTarget:aTarget];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[BibleSearchOptionsViewController -init]");
        // load nib
        BOOL stat = [NSBundle loadNibNamed:BIBLESEARCHOPTIONSVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BibleSearchOptionsViewController -init] unable to load nib!");
        }        
    } else {
        MBLOG(MBLOG_ERR, @"[BibleSearchOptionsViewController -init] unable init!");
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[BibleSearchOptionsViewController -awakeFromNib]");
        
    [super awakeFromNib];
}

#pragma mark - actions

- (IBAction)viewSearchDirection:(id)sender {
    
    int clickedSegment = [sender selectedSegment];
    int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    if(clickedSegmentTag == 0) {
        if(target && [target respondsToSelector:@selector(viewSearchPrevious)]) {
            [target performSelector:@selector(viewSearchPrevious)];
        } else {
            MBLOG(MBLOG_WARN, @"[BibleSearchOptionsViewController -previous:] no target or doesn't respond!");
        }        
    } else {
        if(target && [target respondsToSelector:@selector(viewSearchNext)]) {
            [target performSelector:@selector(viewSearchNext)];
        } else {
            MBLOG(MBLOG_WARN, @"[BibleSearchOptionsViewController -next:] no target or doesn't respond!");
        }        
    }    
}

@end
