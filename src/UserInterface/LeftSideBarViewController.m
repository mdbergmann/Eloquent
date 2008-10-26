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

- (void)setupView:(NSView *)aView;

@end

@implementation LeftSideBarViewController

- (id)initWithDelegate:(id)aDelegate {
    self = [super initWithDelegate:aDelegate];
    if(self) {
        // load subview controllers
        moduleViewController = [[ModuleOutlineViewController alloc] initWithDelegate:self];
        bookmarksViewController = [[BookmarkOutlineViewController alloc] initWithDelegate:self];
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[LeftSideBarViewController -awakeFromNib]");
    
    if(!viewLoaded) {
        // create menu with our available views
        viewMenu = [[NSMenu alloc] init];
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
            [self setupView:[moduleViewController view]];
        }
    }
}

- (void)setupView:(NSView *)aView {
    [placeholderView setContentView:aView];
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOGV(MBLOG_DEBUG, @"[LeftSideBarViewController -contentViewInitFinished:] %@", [aView className]);
    
    // check if this view has completed loading annd also all of the subviews    
    if(viewLoaded == YES) {
        if([aView isKindOfClass:[ModuleOutlineViewController class]]) {
            moduleViewController = (ModuleOutlineViewController *)aView;
            [self setupView:[aView view]];
        } else if([aView isKindOfClass:[BookmarkOutlineViewController class]]) {
            bookmarksViewController = (BookmarkOutlineViewController *)aView;
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
    
    switch(tag) {
        case 0:
            [placeholderView setContentView:[moduleViewController view]];
            break;
        case 1:
            [placeholderView setContentView:[bookmarksViewController view]];
            break;
    }
}

@end
