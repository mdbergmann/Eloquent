//
//  ModuleCommonsViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 16.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ModuleCommonsViewController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "SwordManager.h"
#import "AppController.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "BibleCombiViewController.h"
#import "NSImage+Additions.h"

@implementation ModuleCommonsViewController

@synthesize customFontSize;
@synthesize modDisplayOptions;
@synthesize displayOptions;
@synthesize forceRedisplay;
@synthesize searchType;
@synthesize reference;
@synthesize modDisplayOptionsPopUpButton;
@synthesize displayOptionsPopUpButton;
@synthesize fontSizePopUpButton;
@synthesize textContextPopUpButton;

#pragma mark - Initializers

- (id)init {
    self = [super init];
    if(self) {
        
        [self setReference:@""];
        forceRedisplay = NO;

        customFontSize = [userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey];

        // init modDisplayOptions Dictionary
        self.modDisplayOptions = [NSMutableDictionary dictionary];
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_STRONGS];
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_MORPHS];
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_FOOTNOTES];
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_SCRIPTREFS];
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_REDLETTERWORDS];
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_HEADINGS];
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_HEBREWPOINTS];
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_HEBREWCANTILLATION];
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_GREEKACCENTS];
        
        // init displayOptions dictionary        
        self.displayOptions = [NSMutableDictionary dictionary];
        [displayOptions setObject:[userDefaults objectForKey:DefaultsBibleTextVersesOnOneLineKey] forKey:DefaultsBibleTextVersesOnOneLineKey];
        [displayOptions setObject:[userDefaults objectForKey:DefaultsBibleTextShowVerseNumberOnlyKey] forKey:DefaultsBibleTextShowVerseNumberOnlyKey];
        [displayOptions setObject:[userDefaults objectForKey:DefaultsBibleTextHighlightBookmarksKey] forKey:DefaultsBibleTextHighlightBookmarksKey];
    }
    
    return self;
}

- (void)awakeFromNib {
    // init display options
    [self initDefaultModDisplayOptions];
    [self initDefaultDisplayOptions];
    [self initFontSizeOptions];
    [self initTextContextOptions];

    // set state of menuitem representing font size
    [[[fontSizePopUpButton menu] itemWithTag:customFontSize] setState:NSOnState];
}

#pragma mark - Display things

- (void)initDefaultModDisplayOptions {    
    // init menu and popup button
    NSMenu *menu = [[NSMenu alloc] init];
    modDisplayOptionsMenu = menu;
    NSMenuItem *item = [menu addItemWithTitle:NSLocalizedString(@"ModOptions", @"") action:nil keyEquivalent:@""];
    [item setHidden:YES];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowStrongsNumbers", @"") action:@selector(displayOptionShowStrongs:) keyEquivalent:@""];
    [item setTag:1];
    [item setTarget:self];
    [item setState:[[modDisplayOptions objectForKey:SW_OPTION_STRONGS] isEqualToString:SW_ON] ? 1 : 0];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowMorphNumbers", @"") action:@selector(displayOptionShowMorphs:) keyEquivalent:@""];
    [item setTag:2];
    [item setTarget:self];
    [item setState:[[modDisplayOptions objectForKey:SW_OPTION_MORPHS] isEqualToString:SW_ON] ? 1 : 0];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowFootnotes", @"") action:@selector(displayOptionShowFootnotes:) keyEquivalent:@""];
    [item setTag:3];
    [item setTarget:self];
    [item setState:[[modDisplayOptions objectForKey:SW_OPTION_FOOTNOTES] isEqualToString:SW_ON] ? 1 : 0];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowCrossRefs", @"") action:@selector(displayOptionShowCrossRefs:) keyEquivalent:@""];
    [item setTag:4];
    [item setTarget:self];
    [item setState:[[modDisplayOptions objectForKey:SW_OPTION_SCRIPTREFS] isEqualToString:SW_ON] ? 1 : 0];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowRedLetterWords", @"") action:@selector(displayOptionShowRedLetterWords:) keyEquivalent:@""];
    [item setTag:5];
    [item setTarget:self];
    [item setState:[[modDisplayOptions objectForKey:SW_OPTION_REDLETTERWORDS] isEqualToString:SW_ON] ? 1 : 0];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowHeadings", @"") action:@selector(displayOptionShowHeadings:) keyEquivalent:@""];
    [item setTag:6];
    [item setTarget:self];
    [item setState:[[modDisplayOptions objectForKey:SW_OPTION_HEADINGS] isEqualToString:SW_ON] ? 1 : 0];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowHebrewPoints", @"") action:@selector(displayOptionShowHebrewPoints:) keyEquivalent:@""];
    [item setTag:7];
    [item setTarget:self];
    [item setState:[[modDisplayOptions objectForKey:SW_OPTION_HEBREWPOINTS] isEqualToString:SW_ON] ? 1 : 0];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowHebrewCantillation", @"") action:@selector(displayOptionShowHebrewCantillation:) keyEquivalent:@""];
    [item setTag:8];
    [item setTarget:self];
    [item setState:[[modDisplayOptions objectForKey:SW_OPTION_HEBREWCANTILLATION] isEqualToString:SW_ON] ? 1 : 0];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowGreekAccents", @"") action:@selector(displayOptionShowGreekAccents:) keyEquivalent:@""];
    [item setTag:9];
    [item setTarget:self];
    [item setState:[[modDisplayOptions objectForKey:SW_OPTION_GREEKACCENTS] isEqualToString:SW_ON] ? 1 : 0];

    // set menu to poup
    [modDisplayOptionsPopUpButton setMenu:menu];
}

- (void)initDefaultDisplayOptions {
    // init menu and popup button
    NSMenu *menu = [[NSMenu alloc] init];
    displayOptionsMenu = menu;
    NSMenuItem *item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptions", @"") action:nil keyEquivalent:@""];
    [item setHidden:YES];
    // VersesOnOneLine
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowVOOL", @"") action:@selector(displayOptionVersesOnOneLine:) keyEquivalent:@""];
    [item setTarget:self];
    [item setState:[[displayOptions objectForKey:DefaultsBibleTextVersesOnOneLineKey] boolValue] == YES ? 1 : 0];
    // ShowVerseNumberOnly
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowVerseNumberOnly", @"") action:@selector(displayOptionShowVerseNumberOnly:) keyEquivalent:@""];
    [item setTarget:self];
    [item setState:[[displayOptions objectForKey:DefaultsBibleTextShowVerseNumberOnlyKey] boolValue] == YES ? 1 : 0];
    // Highlight bookmarks
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionHighlightBookmarks", @"") action:@selector(displayOptionHighlightBookmarks:) keyEquivalent:@""];
    [item setTarget:self];
    [item setState:[[displayOptions objectForKey:DefaultsBibleTextHighlightBookmarksKey] boolValue] == YES ? 1 : 0];
    
    // set menu to poup
    [displayOptionsPopUpButton setMenu:menu];
}

- (void)initFontSizeOptions {
    // init menu and popup button
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *item = [menu addItemWithTitle:NSLocalizedString(@"FontSize", @"") action:nil keyEquivalent:@""];
    [item setHidden:YES];
    
    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"8"];
    [item setTag:8];
    [item setState:0];
    
    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"9"];
    [item setTag:9];
    [item setState:0];
    
    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"10"];
    [item setTag:10];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"11"];
    [item setTag:11];
    [item setState:0];
    
    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"12"];
    [item setTag:12];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"13"];
    [item setTag:13];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"14"];
    [item setTag:14];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"16"];
    [item setTag:16];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"18"];
    [item setTag:18];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"20"];
    [item setTag:20];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"22"];
    [item setTag:22];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"24"];
    [item setTag:24];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"26"];
    [item setTag:26];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"28"];
    [item setTag:28];
    [item setState:0];
    
    // set menu to poup
    [fontSizePopUpButton setMenu:menu];
    [fontSizePopUpButton setTarget:self];
    [fontSizePopUpButton setAction:@selector(fontSizeChange:)];
}

- (void)initTextContextOptions {
    // init menu and popup button
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *item = [menu addItemWithTitle:NSLocalizedString(@"TextContext", @"") action:nil keyEquivalent:@""];
    [item setHidden:YES];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"0"];
    [item setTag:0];
    [item setState:1];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"1"];
    [item setTag:1];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"2"];
    [item setTag:2];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"3"];
    [item setTag:3];
    [item setState:0];
    
    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"5"];
    [item setTag:5];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"7"];
    [item setTag:7];
    [item setState:0];

    item = [[NSMenuItem alloc] init];
    [menu addItem:item];    
    [item setTitle:@"10"];
    [item setTag:10];
    [item setState:0];

    // set menu to poup
    [textContextPopUpButton setMenu:menu];
    [textContextPopUpButton setTarget:self];
    [textContextPopUpButton setAction:@selector(textContextChange:)];
}

#pragma mark - Printing

/** to be overriden by subclasses */
- (NSView *)printViewForInfo:(NSPrintInfo *)printInfo {
    return nil;
}

#pragma mark - Actions

- (IBAction)fontSizeChange:(id)sender {
    // get selected font size
    int tag = [(NSPopUpButton *)sender selectedTag];
    
    // loop over all menuitem and set disabled state
    for(NSMenuItem *mi in [[(NSPopUpButton *)sender menu] itemArray]) {
        [mi setState:NSOffState];
    }
    // set the selected one
    [[(NSPopUpButton *)sender selectedItem] setState:NSOnState];
    
    // set new value
    self.customFontSize = tag;
    
    // force redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

/**
 only generic things here.
 BibleViews should override for redisplay
 */
- (IBAction)textContextChange:(id)sender {
    // loop over all menuitem and set disabled state
    for(NSMenuItem *mi in [[(NSPopUpButton *)sender menu] itemArray]) {
        [mi setState:NSOffState];
    }
    // set the selected one
    [[(NSPopUpButton *)sender selectedItem] setState:NSOnState];
}

- (IBAction)displayOptionShowStrongs:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_STRONGS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_STRONGS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

- (IBAction)displayOptionShowMorphs:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_MORPHS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_MORPHS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

- (IBAction)displayOptionShowFootnotes:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_FOOTNOTES];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_FOOTNOTES];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

- (IBAction)displayOptionShowCrossRefs:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_SCRIPTREFS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_SCRIPTREFS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

- (IBAction)displayOptionShowRedLetterWords:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_REDLETTERWORDS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_REDLETTERWORDS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

- (IBAction)displayOptionShowHeadings:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_HEADINGS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_HEADINGS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

- (IBAction)displayOptionShowHebrewPoints:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_HEBREWPOINTS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_HEBREWPOINTS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

- (IBAction)displayOptionShowHebrewCantillation:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_HEBREWCANTILLATION];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_HEBREWCANTILLATION];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

- (IBAction)displayOptionShowGreekAccents:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_GREEKACCENTS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_GREEKACCENTS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];    
}

- (IBAction)displayOptionVersesOnOneLine:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [displayOptions setObject:[NSNumber numberWithBool:NO] forKey:DefaultsBibleTextVersesOnOneLineKey];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [displayOptions setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextVersesOnOneLineKey];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

- (IBAction)displayOptionShowVerseNumberOnly:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [displayOptions setObject:[NSNumber numberWithBool:NO] forKey:DefaultsBibleTextShowVerseNumberOnlyKey];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [displayOptions setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextShowVerseNumberOnlyKey];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];    
}

- (IBAction)displayOptionHighlightBookmarks:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [displayOptions setObject:[NSNumber numberWithBool:NO] forKey:DefaultsBibleTextHighlightBookmarksKey];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [displayOptions setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextHighlightBookmarksKey];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];    
}

- (IBAction)bookPagerAction:(id)sender {
    int clickedSegment = [sender selectedSegment];
    int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    if(clickedSegmentTag == 0) {
        // up
        [(WindowHostController *)hostingDelegate previousBook:self];
    } else if(clickedSegmentTag == 2) {
        // down
        [(WindowHostController *)hostingDelegate nextBook:self];
    }
}

- (IBAction)chapterPagerAction:(id)sender {
    int clickedSegment = [sender selectedSegment];
    int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    if(clickedSegmentTag == 0) {
        // up
        [(WindowHostController *)hostingDelegate previousChapter:self];
    } else if(clickedSegmentTag == 2) {
        // down
        [(WindowHostController *)hostingDelegate nextChapter:self];    
    }    
}

#pragma mark - TextDisplayable protocol

- (void)displayTextForReference:(NSString *)aReference {
    // do nothing here, subclass will handle    
}

- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType {
    // do nothing here, subclass will handle
}

- (NSView *)referenceOptionsView {
    return referenceOptionsView;
}

#pragma mark - MouseTracking protocol

- (void)mouseEntered:(NSView *)theView {
    //MBLOG(MBLOG_DEBUG, @"[ModuleViewController - mouseEntered]");
}

- (void)mouseExited:(NSView *)theView {
    //MBLOG(MBLOG_DEBUG, @"[ModuleViewController - mouseExited]");
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if(self) {
        // decode reference
        self.reference = [decoder decodeObjectForKey:@"ReferenceEncoded"];
        // decode font size
        NSNumber *fontSize = [decoder decodeObjectForKey:@"CustomFontSizeEncoded"];
        if(fontSize) {
            self.customFontSize = [fontSize intValue];        
        }
        // display options
        NSDictionary *dOpts = [decoder decodeObjectForKey:@"ReferenceModDisplayOptions"];
        if(dOpts) {
            // set defaults
            self.modDisplayOptions = [NSMutableDictionary dictionaryWithDictionary:dOpts];
        }
        dOpts = [decoder decodeObjectForKey:@"ReferenceDisplayOptions"];
        if(dOpts) {
            // set defaults
            self.displayOptions = [NSMutableDictionary dictionaryWithDictionary:dOpts];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode custom font size
    [encoder encodeObject:[NSNumber numberWithInt:customFontSize] forKey:@"CustomFontSizeEncoded"];
    // encode reference
    [encoder encodeObject:reference forKey:@"ReferenceEncoded"];
    // display options
    [encoder encodeObject:modDisplayOptions forKey:@"ReferenceModDisplayOptions"];
    // display options
    [encoder encodeObject:displayOptions forKey:@"ReferenceDisplayOptions"];
}

@end
