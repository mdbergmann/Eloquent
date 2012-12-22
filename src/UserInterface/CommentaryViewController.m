//
//  CommentaryViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 18.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HostableViewController.h"
#import "ContentDisplayingViewController.h"
#import "ModuleCommonsViewController.h"
#import "CommentaryViewController.h"
#import "WindowHostController.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "BibleCombiViewController.h"
#import "globals.h"
#import "CacheObject.h"
#import "MBPreferenceController.h"
#import "ObjCSword/SwordManager.h"
#import "ObjCSword/SwordModuleTextEntry.h"
#import "NSButton+Color.h"
#import "NSTextView+LookupAdditions.h"
#import "ModulesUIController.h"
#import "ObjCSword/SwordVerseKey.h"
#import "ObjCSword/SwordListKey.h"
#import "NSUserDefaults+Additions.h"
#import "BibleViewController+TextDisplayGeneration.h"
#import "SwordModule+SearchKitIndex.h"

@interface CommentaryViewController ()
/** generates HTML for display */
- (NSAttributedString *)displayableHTMLForReferenceLookup;
/** stores the edited comment */
- (void)saveCommentaryText;
- (void)replaceLinksWithAnchorTags;
- (void)applyModuleEditability;
- (void)_loadNib;
@end

@implementation CommentaryViewController

- (id)init {
    self = [super init];
    if(self) {
        [self _loadNib];
    }
    return self;
}

- (id)initWithModule:(SwordCommentary *)aModule {
    return [self initWithModule:aModule delegate:nil];
}

- (id)initWithModule:(SwordCommentary *)aModule delegate:(id)aDelegate {
    self = [super init];
    if(self) {
        self.module = aModule;
        self.delegate = aDelegate;
        editEnabled = NO;
        
        self.nibName = COMMENTARYVIEW_NIBNAME;
        
        [self _loadNib];
    } else {
        CocoLog(LEVEL_ERR, @"unable init!");
    }
    
    return self;    
}

- (void)commonInit {
    [super commonInit];
    self.nibName = COMMENTARYVIEW_NIBNAME;    
}

- (void)_loadNib {
    BOOL stat = [NSBundle loadNibNamed:nibName owner:self];
    if(!stat) {
        CocoLog(LEVEL_ERR, @"unable to load nib!");
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self applyModuleEditability];
}

#pragma mark - Methods

- (void)applyModuleEditability {
    BOOL editable = NO;
    if(module) {
        if([module isEditable]) {
            editable = YES;
        }
    }
    [editButton setEnabled:editable];    
}

- (void)populateModulesMenu {    
    NSMenu *menu = [[[NSMenu alloc] init] autorelease];
    [[self modulesUIController] generateModuleMenu:&menu 
                                     forModuletype:Commentary 
                                    withMenuTarget:self 
                                    withMenuAction:@selector(moduleSelectionChanged:)];
    [modulePopBtn setMenu:menu];
    
    if(self.module != nil) {
        if(![[SwordManager defaultManager] moduleWithName:[module name]]) {
            NSArray *modArray = [[SwordManager defaultManager] modulesForType:Commentary];
            if([modArray count] > 0) {
                [self setModule:[modArray objectAtIndex:0]];
                [self displayTextForReference:searchString searchType:searchType];
            }
        }
        [modulePopBtn selectItemWithTitle:[module name]];
    }
}

- (void)moduleSelectionChanged:(id)sender {
    [super moduleSelectionChanged:sender];
    
    // do some additional stuff
    // check whether this module is editable
    BOOL editable = NO;
    if(module) {
        if([module isEditable]) {
            editable = YES;
        }
    }
    [editButton setEnabled:editable];
}

- (void)populateAddPopupMenu {
    commentariesMenu = [[NSMenu alloc] init];
    [[self modulesUIController] generateModuleMenu:&commentariesMenu 
                                     forModuletype:Commentary 
                                    withMenuTarget:self 
                                    withMenuAction:@selector(addModule:)];

    NSMenu *allMenu = [[[NSMenu alloc] init] autorelease];
    [allMenu addItemWithTitle:@"+" action:nil keyEquivalent:@""];
    NSMenuItem *mi = [allMenu addItemWithTitle:NSLocalizedString(@"Commentary", @"") action:nil keyEquivalent:@""];
    [mi setSubmenu:commentariesMenu];
    
    [addPopBtn setMenu:allMenu];
}

- (NSAttributedString *)displayableHTMLForReferenceLookup {
    // get user defaults
    BOOL showBookNames = [userDefaults boolForKey:DefaultsBibleTextShowBookNameKey];
    BOOL showBookAbbr = [userDefaults boolForKey:DefaultsBibleTextShowBookAbbrKey];

    NSMutableString *htmlString = [NSMutableString string];
    
    // background color cannot be set this way
    CGFloat fr, fg, fb = 0.0;
    NSColor *fCol = [userDefaults colorForKey:DefaultsTextForegroundColor];
    [fCol getRed:&fr green:&fg blue:&fb alpha:NULL];
    [htmlString appendFormat:@"\
     <style>\
     body {\
     color:rgb(%i%%, %i%%, %i%%);\
     }\
     </style>\n", 
     (int)(fr * 100.0), (int)(fg * 100.0), (int)(fb * 100.0)];

    [module lockModuleAccess];
    // we skip consecutive links. Commentary module does that by default.
    SwordListKey *lk = [SwordListKey listKeyWithRef:searchString v11n:[module versification]];    
    [lk setPersist:YES];
    [lk setPosition:SWPOS_TOP];
    [module setSwordKey:lk];
    NSInteger numberOfVerses = 0;
    NSString *ref;
    NSString *rendered;
    while(![module error]) {
        ref = [lk keyText];
        rendered = [module renderedText];
        
        NSString *bookName;
        int chapter;
        int verse;
        SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:ref v11n:[module versification]];
        bookName = [verseKey bookName];
        chapter = [verseKey chapter];
        verse = [verseKey verse];
        
        // the verse link, later we have to add percent escapes
        NSString *verseInfo = [NSString stringWithFormat:@"%@|%i|%i", bookName, chapter, verse];

        [htmlString appendFormat:@";;;%@;;;", verseInfo];
        [htmlString appendFormat:@"%@<br />\n", rendered];

        [module incKeyPosition];
        numberOfVerses++;
    }
    // reset key
    [module setKeyString:@"gen1.1"];
    [module unlockModuleAccess];
    [contentCache setCount:numberOfVerses];
    
    // create attributed string
    // setup options
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentOption];
    // set web preferences
    WebPreferences *webPrefs = [[MBPreferenceController defaultPrefsController] defaultWebPreferencesForModuleName:[[self module] name]];
    [webPrefs setDefaultFontSize:[self customFontSize]];
    [options setObject:webPrefs forKey:NSWebPreferencesDocumentOption];
    // set scroll to line height
    NSFont *normalDisplayFont = [[MBPreferenceController defaultPrefsController] normalDisplayFontForModuleName:[[self module] name]];
    NSFont *font = [NSFont fontWithName:[normalDisplayFont familyName] 
                                   size:[self customFontSize]];
    [[(id<TextContentProviding>)contentDisplayController scrollView] setLineScroll:[[[(id<TextContentProviding>)contentDisplayController textView] layoutManager] defaultLineHeightForFont:font]];
    // set text
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    tempDisplayString = [[NSMutableAttributedString alloc] initWithHTML:data 
                                                                options:options
                                                     documentAttributes:nil];
    
    // add pointing hand cursor to all links
    CocoLog(LEVEL_DEBUG, @"setting pointing hand cursor...");
    [self applyLinkCursorToLinks];
    CocoLog(LEVEL_DEBUG, @"setting pointing hand cursor...done");

    CocoLog(LEVEL_DEBUG, @"start replacing markers...");
    // go through the attributed string and set attributes
    NSRange replaceRange = NSMakeRange(0,0);
    BOOL found = YES;
    NSString *text = [tempDisplayString string];
    while(found) {
        NSUInteger tLen = [text length];
        NSRange start = [text rangeOfString:@";;;" options:0 range:NSMakeRange(replaceRange.location, tLen-replaceRange.location)];
        if(start.location != NSNotFound) {
            NSRange stop = [text rangeOfString:@";;;" options:0 range:NSMakeRange(start.location+3, tLen-(start.location+3))];
            if(stop.location != NSNotFound) {
                replaceRange.location = start.location;
                replaceRange.length = stop.location+3 - start.location;
                
                // create marker
                NSString *marker = [text substringWithRange:NSMakeRange(replaceRange.location+3, replaceRange.length-6)];
                NSArray *comps = [marker componentsSeparatedByString:@"|"];
                NSString *verseMarker = [NSString stringWithFormat:@"%@ %@:%@", [comps objectAtIndex:0], [comps objectAtIndex:1], [comps objectAtIndex:2]];
                
                // prepare verse URL link
                NSString *verseLink = [NSString stringWithFormat:@"sword://%@/%@", [module name], verseMarker];
                NSURL *verseURL = [NSURL URLWithString:[verseLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                // prepare various link usages
                NSString *visible = @"";
                NSRange linkRange = NSMakeRange(0, 0);
                if(showBookNames) {
                    visible = [NSString stringWithFormat:@"%@ %@:%@:\n", [comps objectAtIndex:0], [comps objectAtIndex:1], [comps objectAtIndex:2]];
                    linkRange.location = replaceRange.location;
                    linkRange.length = [visible length] - 2;
                } else if(showBookAbbr) {
                    // TODO: show abbrevation
                }
                
                // options
                NSMutableDictionary *markerOpts = [NSMutableDictionary dictionaryWithCapacity:3];
                [markerOpts setObject:verseURL forKey:NSLinkAttributeName];
                [markerOpts setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
                [markerOpts setObject:verseMarker forKey:TEXT_VERSE_MARKER];
                
                // replace string
                [tempDisplayString replaceCharactersInRange:replaceRange withString:visible];
                // set attributes
                [tempDisplayString addAttributes:markerOpts range:linkRange];
                
                // adjust replaceRange
                replaceRange.location += [visible length];
            }
        } else {
            found = NO;
        }
    }
    CocoLog(LEVEL_DEBUG, @"start replacing markers...done");    
    
    [self applyWritingDirection];
    
    return tempDisplayString;
}

- (void)saveCommentaryText {
    // go through the text and store it
    NSAttributedString *attrString = [[(id<TextContentProviding>)contentDisplayController textView] attributedString];
    NSString *text = [[(id<TextContentProviding>)contentDisplayController textView] string];
    NSArray *lines = [text componentsSeparatedByString:@"\n"];
    NSUInteger lineStartIndex = 0;
    NSString *currentVerse = nil;
    NSMutableString *currentText = [NSMutableString string];
    for(NSUInteger i = 0;i < [lines count];i++) {
        NSMutableString *line = [NSMutableString stringWithString:[lines objectAtIndex:i]];
        // add new line for all lines except the last
        if(i < [lines count]-1) {
            [line appendString:@"\n"];
        }
        // line start still in range?
        if(lineStartIndex < [text length]) {
            NSDictionary *attrs = [attrString attributesAtIndex:lineStartIndex effectiveRange:nil];
            // we need to write if either we encounter another verse marker or it is the last line
            if([[attrs allKeys] containsObject:TEXT_VERSE_MARKER] || i == [lines count]-1) {
                // if we had a text before, store it under the current verse
                if(currentVerse != nil && [currentText length] > 0) {
                    if([currentText hasSuffix:@"\n"]) {
                        [currentText replaceCharactersInRange:NSMakeRange([currentText length]-1, 1) withString:@""];
                    }
                    [currentText replaceOccurrencesOfString:@"\n" withString:@"<BR/>" options:0 range:NSMakeRange(0, [currentText length])];
                    [module writeEntry:[SwordModuleTextEntry textEntryForKey:currentVerse andText:currentText]];

                    // reset currentText
                    currentText = [NSMutableString string];
                }
                
                // this is a verse marker
                currentVerse = [attrs objectForKey:TEXT_VERSE_MARKER];
            } else {
                [currentText appendString:line];
            }
            
            lineStartIndex += [line length];                
        } else if(lineStartIndex <= [text length] && [line length] == 0) {
            // last line/verse
            if(currentVerse != nil && [currentText length] > 0) {
                // remove last '\n' if there
                if([currentText hasSuffix:@"\n"]) {
                    [currentText replaceCharactersInRange:NSMakeRange([currentText length]-1, 1) withString:@""];
                }
                // replace all '\n' characters with <br/>
                [currentText replaceOccurrencesOfString:@"\n" withString:@"<BR/>" options:0 range:NSMakeRange(0, [currentText length])];
                [module writeEntry:[SwordModuleTextEntry textEntryForKey:currentVerse andText:currentText]];
            }
        }
    }    
}

- (void)adaptUIToHost {
    if(delegate) {
        if([delegate isKindOfClass:[SingleViewHostController class]] || 
           [delegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [closeBtn setEnabled:NO];
            [addPopBtn setEnabled:NO];
        } else if([delegate isKindOfClass:[BibleCombiViewController class]]) {
            [closeBtn setEnabled:YES];
            [addPopBtn setEnabled:YES];
        }
    }
}

- (void)setupPopupButtonsForSearchType {
    [textContextPopUpButton setEnabled:NO];
}

#pragma mark - HostViewDelegate

- (void)searchStringChanged:(NSString *)aSearchString {
    if(![self hasUnsavedContent]) {
        [super searchStringChanged:aSearchString];
        [self displayTextForReference:searchString];        
    }
}

#pragma mark - Actions

- (IBAction)closeButton:(id)sender {
    // do not close if we still are in editing mode
    if(editEnabled) {
        // show Alert
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"StillInEditingMode", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"")
                                       alternateButton:NSLocalizedString(@"Cancel", @"") 
                                           otherButton:nil 
                             informativeTextWithFormat:NSLocalizedString(@"StillInEditingModeText", @"")];
        if([alert runModal] == NSAlertAlternateReturn) {
            // send close view to super view
            [self removeFromSuperview];            
        }
    } else {
        // send close view to super view
        [self removeFromSuperview];    
    }
}

- (IBAction)addButton:(id)sender {
    // call delegate and tell to add a new bible view
    if(delegate) {
        if([delegate respondsToSelector:@selector(addNewCommentViewWithModule:)]) {
            [delegate performSelector:@selector(addNewCommentViewWithModule:) withObject:nil];
        }
    }
}

- (IBAction)toggleEdit:(id)sender {
    if(editEnabled == NO) {
        [self replaceLinksWithAnchorTags];
        
        [[(id<TextContentProviding>)contentDisplayController textView] setEditable:YES];
        [[(id<TextContentProviding>)contentDisplayController textView] setContinuousSpellCheckingEnabled:YES];
        [[(id<TextContentProviding>)contentDisplayController textView] setAllowsUndo:YES];
        [[(id<TextContentProviding>)contentDisplayController textView] setAutomaticLinkDetectionEnabled:NO];
        [editButton setTextColor:[NSColor redColor]];
        
        // set the delegate to be us temporarily
        [[(id<TextContentProviding>)contentDisplayController textView] setDelegate:self];

    } else {
        [self saveCommentaryText];
        [module deleteSKSearchIndex];
        
        [[(id<TextContentProviding>)contentDisplayController textView] setEditable:NO];
        [[(id<TextContentProviding>)contentDisplayController textView] setContinuousSpellCheckingEnabled:NO];
        [[(id<TextContentProviding>)contentDisplayController textView] setAllowsUndo:NO];
        [[(id<TextContentProviding>)contentDisplayController textView] setAutomaticLinkDetectionEnabled:YES];
        [editButton setTextColor:[NSColor blackColor]];
        
        // set the delegate back to where it belongs
        [[(id<TextContentProviding>)contentDisplayController textView] setDelegate:contentDisplayController];
		
        [editButton setTitle:NSLocalizedString(@"Edit", @"")];
        
        forceRedisplay = YES;
        [self displayTextForReference:searchString searchType:searchType];
    }
    
    editEnabled = !editEnabled;
}

- (void)replaceLinksWithAnchorTags {
    NSRange effectiveRange;
    NSMutableAttributedString *displayString = [[[NSMutableAttributedString alloc] initWithAttributedString:[[(id<TextContentProviding>)contentDisplayController textView] attributedString]] autorelease];
	NSUInteger i = 0;
	while (i < [displayString length]) {
        NSDictionary *attrs = [displayString attributesAtIndex:i effectiveRange:&effectiveRange];
        NSURL *url = [attrs objectForKey:NSLinkAttributeName];
		if(url && ![attrs objectForKey:TEXT_VERSE_MARKER]) {
            NSString *passage = [url path];
            if([passage hasPrefix:@"/"]) {
                passage = [passage stringByReplacingOccurrencesOfString:@"/" withString:@""];
            }
            NSString *replacementString = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", [url absoluteString], passage];
            [displayString replaceCharactersInRange:effectiveRange withString:replacementString];
            
            effectiveRange.length = [replacementString length];

            attrs = [[attrs mutableCopy] autorelease];
            [(NSMutableDictionary *)attrs removeObjectForKey:NSCursorAttributeName];
            [(NSMutableDictionary *)attrs removeObjectForKey:NSLinkAttributeName];
            [displayString setAttributes:attrs range:effectiveRange];
		}
		i += effectiveRange.length;
	}
    [(id<TextContentProviding>)contentDisplayController setAttributedString:displayString];
}

#pragma mark - ContentSaving

- (BOOL)hasUnsavedContent {
    return [[editButton title] hasPrefix:@"*"];
}

- (void)saveContent {
    [self saveDocument:self];
}

#pragma mark - HostViewDelegate protocol

- (void)prepareContentForHost:(WindowHostController *)aHostController {
    [super prepareContentForHost:aHostController];
    [self applyModuleEditability];    
}

#pragma mark - ContentSaving protocol

- (IBAction)saveDocument:(id)sender {
    [self saveCommentaryText];
    
    // text has changed, change the label of the Edit button to indicate that hacnges have been made
    [editButton setTitle:NSLocalizedString(@"Edit", @"")];
    [editButton setTextColor:[NSColor redColor]];
}

#pragma mark - NSTextView delegate methods

- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    // changing text in lines with verse text markers it not allowed
    NSRange lineRange = [aTextView rangeOfLineAtIndex:affectedCharRange.location];
    if(lineRange.location != NSNotFound) {
        NSDictionary *attrs = [[aTextView attributedString] attributesAtIndex:lineRange.location effectiveRange:nil];    
        if([[attrs allKeys] containsObject:TEXT_VERSE_MARKER]) {
            [self setStatusText:NSLocalizedString(@"EditingNotAllowedInThisLine", @"")];
            return NO;
        }
        else {
            [self setStatusText:@""];
        }
    }

    // text has changed, change the label of the Edit button to indicate that hacnges have been made
    [editButton setTitle:[NSString stringWithFormat:@"*%@", NSLocalizedString(@"Edit", @"")]];
    [editButton setTextColor:[NSColor redColor]];
    
    return YES;
}

/** 
 for as long as we are delegate, forward to text controller
 */
- (NSString *)textView:(NSTextView *)textView willDisplayToolTip:(NSString *)tooltip forCharacterAtIndex:(NSUInteger)characterIndex {
    return [(id<TextContentProviding>)contentDisplayController textView:textView willDisplayToolTip:tooltip forCharacterAtIndex:characterIndex];
}

/** 
 for as long as we are delegate, forward to text controller
 */
- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    return [(id<TextContentProviding>)contentDisplayController textView:aTextView clickedOnLink:link atIndex:charIndex];
}

#pragma mark - NSOutlineView delegate methods

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [super outlineViewSelectionDidChange:notification];
}

- (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {    
    [super outlineView:aOutlineView willDisplayCell:cell forTableColumn:tableColumn item:item];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [super outlineView:outlineView numberOfChildrenOfItem:item];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return [super outlineView:outlineView child:index ofItem:item];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return [super outlineView:outlineView objectValueForTableColumn:tableColumn byItem:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [super outlineView:outlineView isItemExpandable:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return [super outlineView:outlineView shouldEditTableColumn:tableColumn item:item];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
}

@end
