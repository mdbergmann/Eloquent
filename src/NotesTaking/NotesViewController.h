//
//  NotesViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 17.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import "ProtocolHelper.h"
#import "Indexer.h"

@class FileRepresentation;

@interface NotesViewController : ContentDisplayingViewController <NSTextViewDelegate, TextDisplayable, TextContentProviding> {
    IBOutlet NSTextView *textView;
    IBOutlet NSButton *saveButton;
    FileRepresentation *fileRep;
    NSRange lastFoundRange;
}

@property (readwrite, retain) FileRepresentation *fileRep;

- (id)initWithFileRepresentation:(FileRepresentation *)aFileRep;
- (id)initWithDelegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate;
- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate fileRep:(FileRepresentation *)aFileRep;

// TextDisplayable
- (void)displayText;
- (void)displayTextForReference:(NSString *)aReference;
- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType;

// TextContentProviding
- (NSTextView *)textView;
- (NSScrollView *)scrollView;
- (void)setAttributedString:(NSAttributedString *)aString;
- (void)textChanged:(NSNotification *)aNotification;

// actions
- (IBAction)saveDocument:(id)sender;
- (IBAction)createSwordLinkFromTextSelection:(id)sender;

@end
