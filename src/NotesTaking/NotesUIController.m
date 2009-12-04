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
#import "FileRepresentation.h"


#define NOTES_UI_NIBNAME @"NotesUI"

enum NotesMenu_Items{
    NotesMenuAddNew = 1,
    NotesMenuAddNewFolder,
    NotesMenuRemove,
    ModuleMenuOpenSingle,
    ModuleMenuOpenWorkspace,
}NotesMenuItems;

@interface NotesUIController ()

- (BOOL)createNewNoteIn:(FileRepresentation *)aFolderRep folder:(BOOL)folder;

@end

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

- (BOOL)createNewNoteIn:(FileRepresentation *)aFolderRep folder:(BOOL)folder {
    @try {
        NSString *newFileName = [NSString stringWithFormat:@"%@.rtf", NSLocalizedString(@"NewNote", @"")];
        [FileRepresentation createWithName:newFileName isFolder:folder destinationDirectoryRep:aFolderRep];
        return YES;
    }
    @catch (NSException * e) {
        MBLOGV(MBLOG_ERR, @"[NotesUIController -createNewNoteIn:] %@", [e reason]);
        
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Error", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") alternateButton:nil otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"ErrorOnCreatingNote", @"")];
        [alert runModal];
    }
    return NO;
}

#pragma mark - Menu Validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	MBLOGV(MBLOG_DEBUG, @"[NotesUIController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = YES;
    
    FileRepresentation *clickedObj = (FileRepresentation *)[self delegateSelectedObject];
    if(delegate && hostingDelegate) {
        int tag = [menuItem tag];        
        switch(tag) {
            case NotesMenuAddNew:
            case NotesMenuAddNewFolder:
                ret = [clickedObj isDirectory];
                break;
            case NotesMenuRemove:
            case ModuleMenuOpenSingle:
            case ModuleMenuOpenWorkspace:
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
            if([self createNewNoteIn:clickedObj folder:NO]) {
                [self delegateReload];
            }
            break;
        case NotesMenuAddNewFolder:
            if([self createNewNoteIn:clickedObj folder:YES]) {
                [self delegateReload];
            }
            break;
        case NotesMenuRemove:
        case ModuleMenuOpenSingle:
        case ModuleMenuOpenWorkspace:
            [self delegateDoubleClick];
            break;
    }    
}

@end
