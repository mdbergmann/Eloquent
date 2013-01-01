//
//  WorkspaceViewHostController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 06.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PSMTabBarControl/PSMTabBarControl.h>
#import <PSMTabBarControl/PSMTabStyle.h>
#import <ObjCSword/SwordModule.h>
#import "WindowHostController.h"

@class ContentDisplayingViewController;
@class SwordModule;
@class FileRepresentation;
@class InitialInfoViewController;

@interface WorkspaceViewHostController : WindowHostController <NSCoding, NSTabViewDelegate> {

    /** the view switcher */
    //IBOutlet NSSegmentedControl *tabControl;
    IBOutlet PSMTabBarControl *tabControl;
    IBOutlet NSTabView *tabView;
    
    IBOutlet InitialInfoViewController *initialViewController;
    IBOutlet NSView *defaultMainView;
    
    /** each tabItem should have this menu */
    IBOutlet NSMenu *tabItemMenu;

    /** one view controller for each tab */
    NSMutableArray *viewControllers;
    
    /** array of search text objects */
    NSMutableArray *searchTextObjs;
}

// methods
- (NSView *)contentView;
- (void)setContentView:(NSView *)aView;
- (NSString *)computeTabTitle;

// actions
- (IBAction)addTab:(id)sender;
- (IBAction)menuItemSelected:(id)sender;
- (IBAction)openModuleInstaller:(id)sender;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
