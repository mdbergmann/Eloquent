//
//  SearchBookSetEditorController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 18.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@class SearchBookSet;

@interface SearchBookSetEditorController : NSViewController {
    IBOutlet NSPopUpButton *searchBookSetsPopUpButton;
    IBOutlet NSTableView *booksTableView;
    IBOutlet NSTextField *nameTextField;
    IBOutlet NSButton *addButton;
    IBOutlet NSButton *removeButton;
    IBOutlet NSButton *allButton;
    IBOutlet NSButton *noneButton;
    IBOutlet NSButton *invertButton;
    
    SearchBookSet *selectedBookSet;
    
    id delegate;
}

@property (retain, readwrite) SearchBookSet *selectedBookSet;
@property (assign, readwrite) id delegate;

- (NSMenu *)bookSetsMenu;

// actions
- (IBAction)bookEnabled:(id)sender;
- (IBAction)bookSetChanged:(id)sender;
- (IBAction)addBookSet:(id)sender;
- (IBAction)removeBookSet:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)selectNone:(id)sender;
- (IBAction)selectInverse:(id)sender;

@end
