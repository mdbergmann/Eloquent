//
//  ModuleOutlineViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 08.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ModuleOutlineViewController.h"


@implementation ModuleOutlineViewController

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[ModuleOutlineViewController -init] loading nib");
        
        // set delegate
        self.delegate = aDelegate;
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:MODULEOUTLINEVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[ModuleOutlineViewController -init] unable to load nib!");
        } else {
        }            
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[ModuleOutlineViewController -awakeFromNib]");

    // loading finished
    viewLoaded = YES;
    [self reportLoadingComplete];
}

@end
