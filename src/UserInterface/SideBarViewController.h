//
//  SideBarViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HostableViewController.h>
#import <ProtocolHelper.h>

#define SIDEBAROUTLINEVIEW_NIBNAME   @"SideBarView"

@interface SideBarViewController : HostableViewController <SubviewHosting> {
    IBOutlet NSBox *placeholderView;
    IBOutlet NSPopUpButton *viewSwitcher;
    IBOutlet NSMenu *viewMenu;
    
    NSMutableDictionary *additionalViews;
}

// initialitazion
- (id)initWithDelegate:(id)aDelegate;

// adding additional item views
- (void)addView:(NSView *)aView withName:(NSString *)aName;
- (void)removeView:(NSView *)aView withName:(NSString *)aName;
- (void)selectViewForTag:(int)aTag;
- (void)selectViewForName:(NSString *)aName;

// subviewhosting
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;

// actions
- (IBAction)viewMenuChanged:(id)sender;

@end
