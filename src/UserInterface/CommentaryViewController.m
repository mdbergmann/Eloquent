//
//  CommentaryViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 18.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CommentaryViewController.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "BibleCombiViewController.h"
#import "ExtTextViewController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SwordBible.h"
#import "SwordCommentary.h"

@interface CommentaryViewController ()
/** generates HTML for display */
- (NSAttributedString *)displayableHTMLFromVerseData:(NSArray *)verseData;
@end

@implementation CommentaryViewController

- (id)initWithModule:(SwordCommentary *)aModule {
    return [self initWithModule:aModule delegate:nil];
}

- (id)initWithModule:(SwordCommentary *)aModule delegate:(id)aDelegate {
    self = [self init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[CommentaryViewController -init]");
        self.module = (SwordCommentary *)aModule;
        self.delegate = aDelegate;
        
        // create textview controller
        textViewController = [[ExtTextViewController alloc] initWithDelegate:self];
        
        self.nibName = COMMENTARYVIEW_NIBNAME;
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:nibName owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[CommentaryViewController -init] unable to load nib!");
        }
    } else {
        MBLOG(MBLOG_ERR, @"[CommentaryViewController -init] unable init!");
    }
    
    return self;    
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[CommentaryViewController -awakeFromNib]");
    
    [super awakeFromNib];
}

#pragma mark - methods

- (void)adaptUIToHost {
    if(delegate) {
        if([delegate isKindOfClass:[SingleViewHostController class]] || 
            [delegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [closeBtn setEnabled:NO];
            [addBtn setEnabled:NO];
        } else if([delegate isKindOfClass:[BibleCombiViewController class]]) {
            [closeBtn setEnabled:YES];
            [addBtn setEnabled:YES];
        }
    }
}

- (void)populateModulesMenu {
    
    NSMenu *menu = [[NSMenu alloc] init];
    // generate menu
    [[SwordManager defaultManager] generateModuleMenu:&menu 
                                        forModuletype:commentary 
                                       withMenuTarget:self 
                                       withMenuAction:@selector(moduleSelectionChanged:)];
    // add menu
    [modulePopBtn setMenu:menu];
}

- (NSAttributedString *)displayableHTMLFromVerseData:(NSArray *)verseData {
    NSMutableAttributedString *ret = nil;
    
    // get user defaults
    BOOL showBookNames = [userDefaults boolForKey:DefaultsBibleTextShowBookNameKey];
    BOOL showBookAbbr = [userDefaults boolForKey:DefaultsBibleTextShowBookAbbrKey];

    // generate html string for verses
    NSMutableString *htmlString = [NSMutableString string];
    for(NSDictionary *dict in verseData) {
        NSString *verseText = [dict objectForKey:SW_OUTPUT_TEXT_KEY];
        NSString *key = [dict objectForKey:SW_OUTPUT_REF_KEY];
                
        NSString *bookName = @"";
        int book = -1;
        int chapter = -1;
        int verse = -1;
        // decode ref
        [SwordBible decodeRef:key intoBook:&bookName book:&book chapter:&chapter verse:&verse];
        
        // the verse link, later we have to add percent escapes
        NSString *verseInfo = [NSString stringWithFormat:@"%@|%i|%i", bookName, chapter, verse];

        // generate text according to userdefaults
        [htmlString appendFormat:@";;;%@;;;", verseInfo];
        [htmlString appendFormat:@"%@<br />\n", verseText];
    }
    
    // create attributed string
    // setup options
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    // set string encoding
    [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentOption];
    // set web preferences
    [options setObject:[[MBPreferenceController defaultPrefsController] webPreferences] forKey:NSWebPreferencesDocumentOption];
    // set scroll to line height
    NSFont *font = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                   size:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];
    [[textViewController scrollView] setLineScroll:[[[textViewController textView] layoutManager] defaultLineHeightForFont:font]];
    // set text
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    ret = [[NSMutableAttributedString alloc] initWithHTML:data 
                                                  options:options
                                       documentAttributes:nil];
    
    MBLOG(MBLOG_DEBUG, @"[CommentaryViewController -displayableHTMLFromVerseData:] start replacing markers...\n");
    // go through the attributed string and set attributes
    NSRange replaceRange = NSMakeRange(0,0);
    BOOL found = YES;
    NSString *text = [ret string];
    while(found) {
        int tLen = [text length];
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
                NSRange linkRange;
                if(showBookNames) {
                    visible = [NSString stringWithFormat:@"%@ %@:%@:\n", [comps objectAtIndex:0], [comps objectAtIndex:1], [comps objectAtIndex:2]];
                    linkRange.location = replaceRange.location;
                    linkRange.length = [visible length] - 2;
                } else if(showBookAbbr) {
                    // TODO: show abbrevation
                }
                
                // options
                NSMutableDictionary *markerOpts = [NSMutableDictionary dictionaryWithCapacity:2];
                [markerOpts setObject:verseURL forKey:NSLinkAttributeName];
                [markerOpts setObject:verseMarker forKey:TEXT_VERSE_MARKER];
                
                // replace string
                [ret replaceCharactersInRange:replaceRange withString:visible];
                // set attributes
                [ret addAttributes:markerOpts range:linkRange];
                
                // adjust replaceRange
                replaceRange.location += [visible length];
            }
        } else {
            found = NO;
        }
    }
    MBLOG(MBLOG_DEBUG, @"[CommentaryViewController -displayableHTMLFromVerseData:] start replacing markers...done\n");    
    
    return ret;
}

- (NSString *)label {
    if(module != nil) {
        return [module name];
    }
    
    return @"CommentView";
}

#pragma mark - actions

- (IBAction)addButton:(id)sender {
    // call delegate and tell to add a new bible view
    if(delegate) {
        if([delegate respondsToSelector:@selector(addNewCommentViewWithModule:)]) {
            [delegate performSelector:@selector(addNewCommentViewWithModule:) withObject:nil];
        }
    }
}

#pragma mark - NSOutlineView delegate methods

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [super outlineViewSelectionDidChange:notification];
}

- (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {    
    [super outlineView:aOutlineView willDisplayCell:cell forTableColumn:tableColumn item:item];
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [super outlineView:outlineView numberOfChildrenOfItem:item];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
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
    // encode common things first
    [super encodeWithCoder:encoder];
}

@end
