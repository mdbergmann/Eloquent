//
//  SideBarViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 26.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SideBarViewController.h"
#import "ObjectAssociations.h"
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

- (ModulesUIController *)modulesUIController {
    return [Associater objectForAssociatedObject:self.delegate withKey:&ModuleListUI];
}

- (BookmarksUIController *)bookmarksUIController {
    return [Associater objectForAssociatedObject:self.delegate withKey:&BookmarkMgrUI];
}

- (NotesUIController *)notesUIController {
    return [Associater objectForAssociatedObject:self.delegate withKey:&NotesMgrUI];
}

@end
