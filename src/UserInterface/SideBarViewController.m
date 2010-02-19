//
//  SideBarViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SideBarViewController.h"
#import "ObjectAssotiations.h"
#import "ModulesUIController.h"
#import "BookmarksUIController.h"
#import "NotesUIController.h"

extern char ModuleListUI;
extern char BookmarkMgrUI;
extern char NotesMgrUI;

@interface SideBarViewController ()

@end

@implementation SideBarViewController

- (id)initWithDelegate:(WindowHostController *)aDelegate {
    self = [super init];
    if(self) {
        self.delegate = aDelegate;        
    }
    
    return self;
}

- (void)awakeFromNib {
    viewLoaded = YES;
    [self reportLoadingComplete];
}

- (void)finalize {
    [super finalize];
}

- (NSView *)resizeControl {
    return sidebarResizeControl;
}

- (ModulesUIController *)modulesUIController {
    return [Assotiater objectForAssotiatedObject:self.delegate withKey:&ModuleListUI];
}

- (BookmarksUIController *)bookmarksUIController {
    return [Assotiater objectForAssotiatedObject:self.delegate withKey:&BookmarkMgrUI];    
}

- (NotesUIController *)notesUIController {
    return [Assotiater objectForAssotiatedObject:self.delegate withKey:&NotesMgrUI];    
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
}

- (void)removeSubview:(HostableViewController *)aViewController {
    NSView *view = [aViewController view];
    [view removeFromSuperview];
}

@end
