//
//  NotesUIController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 17.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@class NotesManager;

@interface NotesUIController : NSObject {
    IBOutlet id delegate;
    IBOutlet id hostingDelegate;

    IBOutlet NSMenu *notesMenu;
    
    NotesManager *notesManager;
}

@property (readwrite) id delegate;
@property (readwrite) id hostingDelegate;
@property (readonly) NSMenu *notesMenu;

// actions
- (IBAction)notesMenuClicked:(id)sender;

@end
