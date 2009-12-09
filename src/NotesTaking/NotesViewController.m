//
//  NotesViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 17.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "NotesViewController.h"
#import "FileRepresentation.h"
#import "NSTextView+LookupAdditions.h"

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
        lastFoundRange = NSMakeRange(NSNotFound, 0);        
        
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
    
    [saveButton setEnabled:NO];
    
    viewLoaded = YES;
    [self reportLoadingComplete];
}

- (NSString *)label {
    if(fileRep) {
        return [[fileRep name] stringByDeletingPathExtension];
    }
    return @"";
}

#pragma mark - TextDisplayable protocol

- (void)displayText {    
    if(fileRep) {
        NSData *textData = [fileRep fileContent];
        if([textData length] > 0) {
            [textView insertText:[[NSAttributedString alloc] initWithData:[fileRep fileContent] options:nil documentAttributes:nil error:NULL]];            
        }
    }
}

- (void)displayTextForReference:(NSString *)aReference {
    [self displayTextForReference:aReference searchType:IndexSearchType];
}

- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType {
    if(!aReference || [aReference length] == 0) {
        [self displayText];
    } else {
        [self setReference:aReference];

        NSRange inputRange = NSMakeRange(NSNotFound, 0);
        if(self.forceRedisplay) {
            inputRange = lastFoundRange;
        }
        NSRange foundRange = [textView rangeOfTextToken:aReference lastFound:inputRange directionRight:YES];
        if(foundRange.location != NSNotFound) {
            // scroll
            NSRect foundRect = [textView rectForTextRange:foundRange];
            [[textView enclosingScrollView] scrollRectToVisible:foundRect];
            [textView showFindIndicatorForRange:foundRange];
        }
    }
}


#pragma mark - AccessoryViewProviding protocol

- (BOOL)showsRightSideBar {
    return NO;
}

#pragma mark - Printing

- (NSView *)printViewForInfo:(NSPrintInfo *)printInfo {
    NSSize paperSize = [printInfo paperSize];
    
    NSSize printSize = NSMakeSize(paperSize.width - ([printInfo leftMargin] + [printInfo rightMargin]), 
                                  paperSize.height - ([printInfo topMargin] + [printInfo bottomMargin]));
    
    // create print view
    NSTextView *printView = [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, printSize.width, printSize.height)];
    [printView insertText:[textView attributedString]];
    
    return printView;
}

#pragma mark - NSTextView delegate methods

- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    [saveButton setEnabled:YES];
    return YES;
}

#pragma mark - Actions

- (IBAction)save:(id)sender {
    NSData *rtfData = [textView RTFFromRange:NSMakeRange(0, [[textView string] length])];
    [fileRep setFileContent:rtfData];
    [saveButton setEnabled:NO];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        self.fileRep = [[FileRepresentation alloc] initWithPath:[decoder decodeObjectForKey:@"NoteFilePath"]];
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:NOTESVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[NotesViewController -initWithCoder:] unable to load nib!");
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:[fileRep filePath] forKey:@"NoteFilePath"];
}

@end
