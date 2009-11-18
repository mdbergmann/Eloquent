//
//  NotesViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 17.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "NotesViewController.h"
#import "FileRepresentation.h"

#define NOTESVIEW_NIBNAME    @"NotesView"

@implementation NotesViewController

@synthesize fileRep;

#pragma mark - Initialisation

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
    return [self initWithDelegate:aDelegate hostingDelegate:nil];
}

- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate {
    return [self initWithDelegate:aDelegate hostingDelegate:aHostingDelegate fileRep:nil];
}

- (id)initWithFileRepresentation:(FileRepresentation *)aFileRep {
    return [self initWithDelegate:nil hostingDelegate:nil fileRep:aFileRep];
}

- (id)initWithDelegate:(id)aDelegate hostingDelegate:(id)aHostingDelegate fileRep:(FileRepresentation *)aFileRep {
    self = [super init];
    if(self) {
        [self setDelegate:aDelegate];
        [self setHostingDelegate:aHostingDelegate];
        [self setFileRep:aFileRep];
        
        BOOL stat = [NSBundle loadNibNamed:NOTESVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[NotesViewController -init] unable to load nib!");
        }        
    }
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)awakeFromNib {
    [self displayText];
    
    viewLoaded = YES;
    [self reportLoadingComplete];
}

- (NSString *)label {
    if(fileRep) {
        return [[fileRep name] stringByDeletingPathExtension];
    }
    return @"";
}

#pragma mark - Methods

- (void)displayText {
    if(fileRep) {
        [textView insertText:[[NSAttributedString alloc] initWithData:[fileRep fileContent] options:nil documentAttributes:nil error:NULL]];
    }    
}

@end
