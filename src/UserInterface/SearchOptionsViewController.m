//
//  SearchOptionsViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 14.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SearchOptionsViewController.h"


@implementation SearchOptionsViewController

@synthesize target;

- (id)init {
    return [self initWithDelegate:nil andTarget:nil];
}

- (id)initWithDelegate:(id)aDelegate {
    return [self initWithDelegate:aDelegate andTarget:nil];
}

- (id)initWithDelegate:(id)aDelegate andTarget:(id)aTarget {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[SearchOptionsViewController -init]");
        self.delegate = aDelegate;
        self.target = aTarget;
    } else {
        MBLOG(MBLOG_ERR, @"[SearchOptionsViewController -init] unable init!");
    }
    
    return self;    
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[SearchOptionsViewController -awakeFromNib]");

    // save size
    referenceSearchOptionsViewSize = [referenceSearchOptionsView frame].size;
    indexSearchOptionsViewSize = [indexSearchOptionsView frame].size;
    viewSearchOptionsViewSize = [viewSearchOptionsView frame].size;
    
    // loading finished
    viewLoaded = YES;
    
    [self reportLoadingComplete];
}

- (NSView *)optionsViewForSearchType:(SearchType)aType {
    
    NSView *ret = nil;
    
    switch(aType) {
        case ReferenceSearchType:
            ret = referenceSearchOptionsView;
        case IndexSearchType:
            ret = indexSearchOptionsView;
        case ViewSearchType:
            ret = viewSearchOptionsView;
    }
    
    return ret;
}

- (NSSize)optionsViewSizeForSearchType:(SearchType)aType {
    NSSize ret;
    
    switch(aType) {
        case ReferenceSearchType:
            ret = referenceSearchOptionsViewSize;
        case IndexSearchType:
            ret = indexSearchOptionsViewSize;
        case ViewSearchType:
            ret = viewSearchOptionsViewSize;
    }
    
    return ret;    
}

@end
