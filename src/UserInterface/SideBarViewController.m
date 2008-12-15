//
//  SideBarViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SideBarViewController.h"


@interface SideBarViewController ()

@property (retain, readwrite) NSMutableDictionary *additionalViews;

@end

@implementation SideBarViewController

@synthesize additionalViews;

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[SideBarViewController -init] loading nib");
        
        // set delegate
        self.delegate = aDelegate;
        
        // init additional views dict
        self.additionalViews = [NSMutableDictionary dictionary];
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:SIDEBAROUTLINEVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SideBarViewController -init] unable to load nib!");
        } else {
            // default view is modules
            
        }            
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[SideBarViewController -awakeFromNib]");
    
    // loading finished
    viewLoaded = YES;

    // init menu
    viewMenu = [[NSMenu alloc] init];

    [self reportLoadingComplete];
}

/** abstract, sub class should override */
- (void)selectViewForTag:(int)aTag {
}

- (void)selectViewForName:(NSString *)aName {
    [placeholderView setContentView:[additionalViews objectForKey:aName]];
    [viewSwitcher selectItem:[viewMenu itemWithTitle:aName]];
}

- (void)addView:(NSView *)aView withName:(NSString *)aName {
    
    if([additionalViews objectForKey:aName] == nil) {
        NSMenuItem *item = [[NSMenuItem alloc] init];
        [item setTag:[viewMenu numberOfItems] + 1];
        [item setTarget:self];
        [item setTitle:aName];
        [item setAction:@selector(viewMenuChanged:)];
        [viewMenu addItem:item];
        
        // add view
        [additionalViews setObject:aView forKey:aName];
    }
    
    // when adding a new view controller, the view is selected
    [self selectViewForName:aName];
}

- (void)removeView:(NSView *)aView withName:(NSString *)aName {
    [additionalViews removeObjectForKey:aName];
    [viewMenu removeItem:[viewMenu itemWithTitle:aName]];
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOG(MBLOG_DEBUG, @"[SideBarViewController -contentViewInitFinished:]");
    // check if this view has completed loading annd also all of the subviews    
    if(viewLoaded == YES) {
        BOOL loaded = YES;
        
        if(loaded) {
            // report to super controller
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

/** abstract method to be implemented in subclasses */
- (IBAction)viewMenuChanged:(id)sender {
    // get label
    NSString *label = [(NSMenuItem *)sender title];
    // get view controller for label
    NSView *v = [additionalViews objectForKey:label];
    // show this view
    [placeholderView setContentView:v];
}

@end
