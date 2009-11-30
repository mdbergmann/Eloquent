//
//  NotesUIController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 17.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "NotesUIController.h"
#import "LeftSideBarViewController.h"
#import "NotesManager.h"


#define NOTES_UI_NIBNAME @"NotesUI"

enum NotesMenu_Items{
    NotesMenuAddNew = 1,
    NotesMenuAddNewFolder,
    NotesMenuRemove,
    NotesMenuOpenInNew,
    NotesMenuOpenInCurrent,
}NotesMenuItems;

@implementation NotesUIController

@synthesize notesMenu;

#pragma mark - Initialisation

- (id)init {
    return [super init];
}

- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate {
    self = [super initWithDelegate:aDelegate hostingDelegate:aHostingDelegate];
    if(self) {
        notesManager = [NotesManager defaultManager];
        
        BOOL stat = [NSBundle loadNibNamed:NOTES_UI_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[NotesUIController -init] unable to load nib!");
        }        
    }
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)awakeFromNib {
    
}

#pragma mark - Menu Validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	MBLOGV(MBLOG_DEBUG, @"[NotesUIController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = YES;
    
    if(delegate && hostingDelegate) {
        int tag = [menuItem tag];        
        switch(tag) {
            case NotesMenuAddNew:
            case NotesMenuAddNewFolder:
            case NotesMenuRemove:
            case NotesMenuOpenInNew:
            case NotesMenuOpenInCurrent:
                break;
        }
    } else {
        MBLOG(MBLOG_ERR, @"[NotesUIController -validateMenuItem:] delegate and hostingDelegate are not available!");
    }
    
    return ret;
}

#pragma mark - Actions

- (IBAction)notesMenuClicked:(id)sender {
	MBLOGV(MBLOG_DEBUG, @"[NotesUIController -menuClicked:] %@", [sender description]);
    
    FileRepresentation *clickedObj = (FileRepresentation *)[self delegateSelectedObject];
    int tag = [sender tag];
    switch(tag) {
        case NotesMenuAddNew:
        case NotesMenuAddNewFolder:
        case NotesMenuRemove:
        case NotesMenuOpenInNew:
        case NotesMenuOpenInCurrent:
            [self delegateDoubleClick];
            break;
    }    
}

@end
