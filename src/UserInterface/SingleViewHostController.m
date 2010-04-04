//
//  SingleViewHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 16.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SingleViewHostController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "BibleCombiViewController.h"
#import "CommentaryViewController.h"
#import "DictionaryViewController.h"
#import "GenBookViewController.h"
#import "HostableViewController.h"
#import "BibleSearchOptionsViewController.h"
#import "LeftSideBarViewController.h"
#import "RightSideBarViewController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SearchTextObject.h"
#import "FileRepresentation.h"
#import "NotesViewController.h"
#import "WindowHostController+SideBars.h"

@interface SingleViewHostController ()

- (void)_loadNib;

@end

@implementation SingleViewHostController

#pragma mark - Initializers

- (id)init {
    self = [super init];
    if(self) {
        lsbShowing = [userDefaults boolForKey:DefaultsShowLSBSingle];
        rsbShowing = [userDefaults boolForKey:DefaultsShowRSBSingle];
        [self _loadNib];
    }
    return self;
}

- (void)_loadNib {
    BOOL stat = [NSBundle loadNibNamed:SINGLEVIEWHOST_NIBNAME owner:self];
    if(!stat) {
        MBLOG(MBLOG_ERR, @"[SingleViewHostController -init] unable to load nib!");
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];

    if(contentViewController != nil) {
        [self setupForContentViewController];
    }
    
    hostLoaded = YES;
}

#pragma mark - Methods

- (NSView *)contentView {
    return [(NSBox *)placeHolderView contentView];
}

- (void)setContentView:(NSView *)aView {
    [(NSBox *)placeHolderView setContentView:aView];
}

#pragma mark - Actions

- (IBAction)forceReload:(id)sender {
    [(ModuleCommonsViewController *)contentViewController setForceRedisplay:YES];
    [(ModuleCommonsViewController *)contentViewController displayTextForReference:[currentSearchText searchTextForType:[currentSearchText searchType]]];
    [(ModuleCommonsViewController *)contentViewController setForceRedisplay:NO];
}

#pragma mark - SubviewHosting protocol

- (void)addContentViewController:(ContentDisplayingViewController *)aViewController {
    [super addContentViewController:aViewController];
}

- (void)contentViewInitFinished:(HostableViewController *)aView {
    [super contentViewInitFinished:aView];    
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [super removeSubview:aViewController];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {        
        [super initWithCoder:decoder];

        // decode contentViewController
        contentViewController = [decoder decodeObjectForKey:@"HostableViewControllerEncoded"];
        [contentViewController setDelegate:self];
        [contentViewController adaptUIToHost];
        [contentViewController prepareContentForHost:self];
        
        [self _loadNib];

        NSRect frame;
        frame.origin = [decoder decodePointForKey:@"WindowOriginEncoded"];
        frame.size = [decoder decodeSizeForKey:@"WindowSizeEncoded"];
        if(frame.size.width > 0 && frame.size.height > 0) {
            [[self window] setFrame:frame display:YES];
        }

        // restore sidebar widths
        if(lsbShowing) {
            [self restoreLeftSideBarWithWidth:loadedLSBWidth];
        }
        if(rsbShowing) {
            [self restoreRightSideBarWithWidth:loadedRSBWidth];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:contentViewController forKey:@"HostableViewControllerEncoded"];
    
    [super encodeWithCoder:encoder];
}

@end
