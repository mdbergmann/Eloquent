//
//  NotesViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 17.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "HostableViewController.h"
#import "ContentDisplayingViewController.h"
#import "NotesViewController.h"
#import "globals.h"
#import "FileRepresentation.h"
#import "NSTextView+LookupAdditions.h"
#import "ModuleCommonsViewController.h"
#import "ModuleViewController.h"
#import "MBPreferenceController.h"
#import "ObjectAssociations.h"
#import "LeftSideBarAccessoryUIController.h"
#import "NotesUIController.h"
#import "NSUserDefaults+Additions.h"
#import "SearchTextFieldOptions.h"

#define NOTESVIEW_NIBNAME    @"NotesView"

extern char NotesMgrUI;

@interface NotesViewController ()

- (NSAttributedString *)swordLinkStringFromReference:(NSString *)aReference ofModule:(NSString *)aModuleName;
- (NotesUIController *)notesUIController;

@end

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
        [self setSearchType:IndexSearchType];
        [self setDelegate:aDelegate];
        [self setHostingDelegate:aHostingDelegate];
        [self setFileRep:aFileRep];
        lastFoundRange = NSMakeRange(NSNotFound, 0);
        contentDisplayController = self;
        
        BOOL stat = [NSBundle loadNibNamed:NOTESVIEW_NIBNAME owner:self];
        if(!stat) {
            CocoLog(LEVEL_ERR, @"[NotesViewController -init] unable to load nib!");
        }        
    }
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [fileRep release];
    [super dealloc];
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [textView setBackgroundColor:[userDefaults colorForKey:DefaultsTextBackgroundColor]];
    
    [self displayText];
    [saveButton setEnabled:NO];
    
    viewLoaded = YES;
    [self reportLoadingComplete];
}

- (NotesUIController *)notesUIController {
    return [Associater objectForAssociatedObject:hostingDelegate withKey:&NotesMgrUI];
}

- (NSAttributedString *)swordLinkStringFromReference:(NSString *)aReference ofModule:(NSString *)aModuleName {
    
    NSString *keyLink = [NSString stringWithFormat:@"sword://%@/%@", aModuleName, aReference];
    NSURL *keyURL = [NSURL URLWithString:[keyLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // add attributes
    NSMutableDictionary *keyAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
    [keyAttributes setObject:keyURL forKey:NSLinkAttributeName];
    [keyAttributes setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];                
    [keyAttributes setObject:aReference forKey:TEXT_VERSE_MARKER];
    
    // prepare output
    NSAttributedString *keyString = [[[NSAttributedString alloc] initWithString:aReference attributes:keyAttributes] autorelease];
    if(!keyString) {
        keyString = [[[NSAttributedString alloc] init] autorelease];
    }
    return keyString;
}

#pragma mark - Context Menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    SEL selector = [menuItem action];
    if([menuItem menu] == textContextMenu) {
        if(selector == @selector(createSwordLinkFromTextSelection:)) {
            if([[[self textView] selectedString] length] > 0) {
                return YES;                
            }
            return NO;
        }
    }
    
    return [super validateMenuItem:menuItem];
}

#pragma mark - TextContentProviding protocol

- (NSTextView *)textView {
    return textView;
}

- (NSScrollView *)scrollView {
    return [textView enclosingScrollView];
}

- (void)setAttributedString:(NSAttributedString *)aString {
    [[textView textStorage] setAttributedString:aString];
    [self textChanged:[NSNotification notificationWithName:@"TextChangedNotification" object:textView]];
}

- (void)setString:(NSString *)aString {
    [textView setString:aString]; 
}

- (void)textChanged:(NSNotification *)aNotification {
    [saveButton setEnabled:YES];
}

#pragma mark - TextDisplayable protocol

- (void)displayText {    
    if(fileRep) {
        NSData *textData = [fileRep fileContent];
        if([textData length] > 0) {
            [[textView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithData:[fileRep fileContent] options:nil documentAttributes:nil error:NULL] autorelease]];
        }
    }
}

- (void)displayTextForReference:(NSString *)aReference {
    [self displayTextForReference:aReference searchType:IndexSearchType];
}

- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType {
    if(aReference && [aReference length] > 0) {
        [self setSearchString:aReference];

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
    } else if(([aReference length] == 0) && forceRedisplay) {
        [self displayText];
    }
}


#pragma mark - HostViewDelegate protocol

- (BOOL)showsRightSideBar {
    return NO;
}

- (NSString *)title {
    if(fileRep) {
        return [[fileRep name] stringByDeletingPathExtension];
    }
    return @"";
}

- (SearchTextFieldOptions *)searchFieldOptions {
    SearchTextFieldOptions *options = [[[SearchTextFieldOptions alloc] init] autorelease];
    if(searchType == ReferenceSearchType) {
        [options setContinuous:YES];
        [options setSendsSearchStringImmediately:YES];
        [options setSendsWholeSearchString:YES];
    } else {
        [options setContinuous:NO];
        [options setSendsSearchStringImmediately:NO];
        [options setSendsWholeSearchString:YES];        
    }
    return options;
}

#pragma mark - Printing

- (NSView *)printViewForInfo:(NSPrintInfo *)printInfo {
    NSSize paperSize = [printInfo paperSize];
    
    NSSize printSize = NSMakeSize(paperSize.width - ([printInfo leftMargin] + [printInfo rightMargin]), 
                                  paperSize.height - ([printInfo topMargin] + [printInfo bottomMargin]));
    
    // create print view
    NSTextView *printView = [[[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, printSize.width, printSize.height)] autorelease];
    [printView insertText:[textView attributedString]];
    
    return printView;
}

#pragma mark - NSTextView delegate methods

- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    [saveButton setEnabled:YES];
    return YES;
}

#pragma mark - ContentSaving

- (BOOL)hasUnsavedContent {
    return [saveButton isEnabled];
}

- (void)saveContent {
    [self saveDocument:self];
}

#pragma mark - Actions

- (IBAction)saveDocument:(id)sender {
    NSData *rtfData = [textView RTFFromRange:NSMakeRange(0, [[textView string] length])];
    [fileRep setFileContent:rtfData];
    [saveButton setEnabled:NO];
}

- (IBAction)createSwordLinkFromTextSelection:(id)sender {
    NSString *selectedText = [[self textView] selectedString];
    NSString *trimmedText = [selectedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([trimmedText length] > 0) {
        
        // get default bible module
        NSString *defBibleName = [userDefaults stringForKey:DefaultsBibleModule];
        if(defBibleName == nil) {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"NoDefaultBibleSelected", @"") 
                                             defaultButton:NSLocalizedString(@"OK" , @"")
                                           alternateButton:nil 
                                               otherButton:nil
                                 informativeTextWithFormat:NSLocalizedString(@"NoDefaultBibleSelectedText", @"")];
            [alert runModal];
        } else {
            NSAttributedString *replacementString = [self swordLinkStringFromReference:trimmedText ofModule:defBibleName];
            [[[self textView] textStorage] replaceCharactersInRange:[[self textView] selectedRange] withAttributedString:replacementString];
            [self textChanged:nil];
        }
    }
}

#pragma mark - NSTextView delegates

- (NSMenu *)menuForEvent:(NSEvent *)event {
    return [super menuForEvent:event];
}

- (NSString *)textView:(NSTextView *)aTextView willDisplayToolTip:(NSString *)tooltip forCharacterAtIndex:(NSUInteger)characterIndex {
    // create URL
    NSURL *url = [NSURL URLWithString:[tooltip stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if(!url) {
        CocoLog(LEVEL_WARN, @"[ExtTextViewController -textView:willDisplayToolTip:] no URL: %@\n", tooltip);
    } else {
        return [self processPreviewDisplay:url];
    }
    
    return @"";
}

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    [self processPreviewDisplay:(NSURL *)link];
    [self linkClicked:link];
    return YES;
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        self.fileRep = [[[FileRepresentation alloc] initWithPath:[decoder decodeObjectForKey:@"NoteFilePath"]] autorelease];
        lastFoundRange = NSMakeRange(NSNotFound, 0);
        contentDisplayController = self;        
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:NOTESVIEW_NIBNAME owner:self];
        if(!stat) {
            CocoLog(LEVEL_ERR, @"[NotesViewController -initWithCoder:] unable to load nib!");
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:[fileRep filePath] forKey:@"NoteFilePath"];
}

@end
