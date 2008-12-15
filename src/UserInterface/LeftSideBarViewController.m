//
//  LeftSideBarViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LeftSideBarViewController.h"
#import "ModuleOutlineViewController.h"
#import "BookmarkOutlineViewController.h"

@interface LeftSideBarViewController ()

@end

@implementation LeftSideBarViewController

- (id)initWithDelegate:(id)aDelegate {
    self = [super initWithDelegate:aDelegate];
    if(self) {
        // load subview controllers
        moduleViewController = [[ModuleOutlineViewController alloc] initWithDelegate:self];
        [moduleViewController setHostingDelegate:delegate];        
        bookmarksViewController = [[BookmarkOutlineViewController alloc] initWithDelegate:self];
        [bookmarksViewController setHostingDelegate:delegate];
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[LeftSideBarViewController -awakeFromNib]");
    
    if(!viewLoaded) {
        // create menu with our available views
        NSMenuItem *item = [[NSMenuItem alloc] init];
        [item setTag:0];
        [item setTarget:self];
        [item setTitle:@"Modules"];
        [item setAction:@selector(viewMenuChanged:)];
        [viewMenu addItem:item];
        
        item = [[NSMenuItem alloc] init];
        [item setTag:1];
        [item setTarget:self];
        [item setTitle:@"Bookmarks"];
        [item setAction:@selector(viewMenuChanged:)];
        [viewMenu addItem:item];
        // set menu
        [viewSwitcher setMenu:viewMenu];
        
        BOOL loaded = NO;
        if([moduleViewController viewLoaded] && [bookmarksViewController viewLoaded]) {
            loaded = YES;
        }
        
        // loading finished
        viewLoaded = YES;
        if(loaded) {
            [self reportLoadingComplete];
            [placeholderView setContentView:[moduleViewController view]];
        }
    }
}

/** abstract, sub class should override */
- (void)selectViewForTag:(int)aTag {
    NSMenuItem *item = [viewMenu itemWithTag:aTag];
    [viewSwitcher selectItem:item];
    if(aTag == 0) {
        [placeholderView setContentView:[moduleViewController view]];
    } else if(aTag == 1) {
        [placeholderView setContentView:[bookmarksViewController view]];    
    } else {
        // let super class handle
        [super selectViewForTag:aTag];
    }
}

- (void)selectViewForName:(NSString *)aName {
    
    NSMenuItem *item = [viewMenu itemWithTitle:aName];
    if(item != nil) {
        [viewSwitcher selectItem:item]; 

        if([aName isEqualToString:@"Modules"]) {
            [placeholderView setContentView:[moduleViewController view]];
        } else if([aName isEqualToString:@"Bookmarks"]) {
            [placeholderView setContentView:[bookmarksViewController view]];        
        } else {
            // let super class handle
            [super selectViewForName:aName];
        }
    }
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOGV(MBLOG_DEBUG, @"[LeftSideBarViewController -contentViewInitFinished:] %@", [aView className]);
    
    // check if this view has completed loading annd also all of the subviews    
    if(viewLoaded == YES) {
        if([aView isKindOfClass:[ModuleOutlineViewController class]]) {
            moduleViewController = (ModuleOutlineViewController *)aView;
            [moduleViewController setHostingDelegate:delegate];
            [placeholderView setContentView:[aView view]];
        } else if([aView isKindOfClass:[BookmarkOutlineViewController class]]) {
            bookmarksViewController = (BookmarkOutlineViewController *)aView;
            [bookmarksViewController setHostingDelegate:delegate];
        }

        if([moduleViewController viewLoaded] && [bookmarksViewController viewLoaded]) {
            [self reportLoadingComplete];
        }
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    // remove the view of the send controller from our hosts
    NSView *view = [aViewController view];
    [view removeFromSuperview];
}

#pragma mark - Actions

- (IBAction)viewMenuChanged:(id)sender {
	MBLOGV(MBLOG_DEBUG, @"[LeftSideBarViewController -menuClicked:] %@", [sender description]);
    
    int tag = [sender tag];
    
    if(tag <= 2) {
        switch(tag) {
            case 0:
                [placeholderView setContentView:[moduleViewController view]];
                break;
            case 1:
                [placeholderView setContentView:[bookmarksViewController view]];
                break;
        }        
    } else {
        // super class will handle everything else
        [super viewMenuChanged:sender];
    }
}

@end
