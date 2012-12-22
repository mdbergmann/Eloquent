//
//  NotesUIController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 17.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "LeftSideBarAccessoryUIController.h"
#import "NotesUIController.h"
#import "HostableViewController.h"
#import "NotesManager.h"
#import "FileRepresentation.h"
#import "AppController.h"

#define NOTES_UI_NIBNAME @"NotesUI"

enum NotesMenu_Items{
    NotesMenuAddNew = 1,
    NotesMenuAddNewFolder,
    NotesMenuRemove,
    NotesMenuOpenSingle,
    NotesMenuOpenWorkspace,
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

- (id)initWithDelegate:(id<LeftSideBarDelegate>)aDelegate hostingDelegate:(WindowHostController *)aHostingDelegate {
    self = [super initWithDelegate:aDelegate hostingDelegate:aHostingDelegate];
    if(self) {
        notesManager = [NotesManager defaultManager];
        
        BOOL stat = [NSBundle loadNibNamed:NOTES_UI_NIBNAME owner:self];
        if(!stat) {
            CocoLog(LEVEL_ERR, @"[NotesUIController -init] unable to load nib!");
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
        if(folder) {
            newFileName = [NSString stringWithString:NSLocalizedString(@"NewFolder", @"")];
        }
        [FileRepresentation createWithName:newFileName isFolder:folder destinationDirectoryRep:aFolderRep];
        
        return YES;
    }
    @catch (NSException * e) {
        CocoLog(LEVEL_ERR, @"[NotesUIController -createNewNoteIn:] %@", [e reason]);
        
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Error", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"") alternateButton:nil otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"ErrorOnCreatingNote", @"")];
        [alert runModal];
    }
    return NO;
}

#pragma mark - Menu Validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	CocoLog(LEVEL_DEBUG, @"[NotesUIController -validateMenuItem:] %@", [menuItem description]);
    
    BOOL ret = NO;
    
    FileRepresentation *clickedObj = (FileRepresentation *)[self delegateSelectedObject];
    int tag = [menuItem tag];        
    switch(tag) {
        case NotesMenuAddNew:
        case NotesMenuAddNewFolder:
            ret = (([clickedObj isKindOfClass:[FileRepresentation class]] && [clickedObj isDirectory]) ||
                   [clickedObj isKindOfClass:[NSString class]]);
            break;
        case NotesMenuRemove:
            ret = ([clickedObj isKindOfClass:[FileRepresentation class]] || 
                   ([clickedObj isKindOfClass:[FileRepresentation class]] && [clickedObj isDirectory]));
            break;
        case NotesMenuOpenSingle:
        case NotesMenuOpenWorkspace:
            ret = ([clickedObj isKindOfClass:[FileRepresentation class]] && ![clickedObj isDirectory]);
            break;
    }
    
    return ret;
}

#pragma mark - Actions

- (IBAction)notesMenuClicked:(id)sender {
	CocoLog(LEVEL_DEBUG, @"[NotesUIController -menuClicked:] %@", [sender description]);
    
    id clickedObj = [self delegateSelectedObject];
    if([clickedObj isKindOfClass:[NSString class]] && [(NSString *)clickedObj isEqualToString:NSLocalizedString(@"LSBNotes", @"")]) {
        clickedObj = [notesManager notesFileRep];
    }
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
        {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Confirmation", @"")
                                             defaultButton:NSLocalizedString(@"OK", @"")
                                           alternateButton:NSLocalizedString(@"Cancel", @"")
                                               otherButton:nil 
                                 informativeTextWithFormat:NSLocalizedString(@"ConfirmDelete", @"")];
            if([alert runModal] == NSAlertDefaultReturn) {
                [FileRepresentation deleteComplete:clickedObj];
                [self delegateReload];
            }
            break;            
        }
        case NotesMenuOpenSingle:
            [[AppController defaultAppController] openSingleHostWindowForNote:clickedObj];
            break;
        case NotesMenuOpenWorkspace:
            [self delegateDoubleClick];
            break;
    }    
}

@end
