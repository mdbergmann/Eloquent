//
//  ModuleCommonsViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 16.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HostableViewController.h"
#import "ContentDisplayingViewController.h"
#import "ModuleCommonsViewController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "ObjCSword/SwordManager.h"
#import "WindowHostController.h"
#import "BibleCombiViewController.h"
#import "SwordModule+SearchKitIndex.h"
#import "ProgressOverlayViewController.h"
#import "ObjectAssociations.h"
#import "ModulesUIController.h"
#import "BookmarksUIController.h"
#import "WindowHostController+Fullscreen.h"

extern char BookmarkMgrUI;

@interface ModuleCommonsViewController ()

@end

@implementation ModuleCommonsViewController

@dynamic customFontSize;
@synthesize textContext;
@synthesize modDisplayOptions;
@synthesize displayOptions;
@synthesize modDisplayOptionsPopUpButton;
@synthesize displayOptionsPopUpButton;
@synthesize fontSizePopUpButton;
@synthesize textContextPopUpButton;

#pragma mark - Initializers

- (id)init {
    self = [super init];
    if(self) {
        customFontSize = -1;
        textContext = 0;

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
        [displayOptions setObject:[userDefaults objectForKey:DefaultsBibleTextVerseNumberingTypeKey] forKey:DefaultsBibleTextVerseNumberingTypeKey];
        [displayOptions setObject:[userDefaults objectForKey:DefaultsBibleTextHighlightBookmarksKey] forKey:DefaultsBibleTextHighlightBookmarksKey];
    }
    
    return self;
}

- (void)dealloc {
    [modDisplayOptions release];
    [displayOptions release];
    [displayOptionsMenu release];
    [verseNumberingMenu release];
    [modDisplayOptionsMenu release];
    [super dealloc];
}

- (void)commonInit {
    [super commonInit];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // init display options
    [self initDefaultModDisplayOptions];
    [self initDefaultDisplayOptions];
    [self initFontSizeOptions];
    [self initTextContextOptions];    
}

- (BookmarksUIController *)bookmarksUIController {
    return [Associater objectForAssociatedObject:hostingDelegate withKey:&BookmarkMgrUI];
}

#pragma mark - Display things

- (void)setGlobalOptionsFromModOptions {
    for(NSString *key in modDisplayOptions) {
        NSString *val = [modDisplayOptions objectForKey:key];
        [[SwordManager defaultManager] setGlobalOption:key value:val];
    }    
}

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
    [item setTag:1];
    
    verseNumberingMenu = [[NSMenu alloc] init];
    item = [[[NSMenuItem alloc] init] autorelease];
    [item setTitle:NSLocalizedString(@"DisplayOptionVerseNumbering", @"")];
    [item setSubmenu:verseNumberingMenu];
    [menu addItem:item];
    // Full
    item = [verseNumberingMenu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowFullVerseNumbering", @"") action:@selector(displayOptionShowFullVerseNumbering:) keyEquivalent:@""];
    [item setTarget:self];
    [item setState:[[displayOptions objectForKey:DefaultsBibleTextVerseNumberingTypeKey] intValue] == FullVerseNumbering ? 1 : 0];
    [item setTag:FullVerseNumbering];
    item = [verseNumberingMenu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowVerseNumberOnly", @"") action:@selector(displayOptionShowVerseNumberOnly:) keyEquivalent:@""];
    [item setTarget:self];
    [item setState:[[displayOptions objectForKey:DefaultsBibleTextVerseNumberingTypeKey] intValue] == VerseNumbersOnly ? 1 : 0];    
    [item setTag:VerseNumbersOnly];
    item = [verseNumberingMenu addItemWithTitle:NSLocalizedString(@"DisplayOptionHideVerseNumbering", @"") action:@selector(displayOptionHideVerseNumbering:) keyEquivalent:@""];
    [item setTarget:self];
    [item setState:[[displayOptions objectForKey:DefaultsBibleTextVerseNumberingTypeKey] intValue] == NoVerseNumbering ? 1 : 0];    
    [item setTag:NoVerseNumbering];
    
    // Highlight bookmarks
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionHighlightBookmarks", @"") action:@selector(displayOptionHighlightBookmarks:) keyEquivalent:@""];
    [item setTarget:self];
    [item setState:[[displayOptions objectForKey:DefaultsBibleTextHighlightBookmarksKey] boolValue] == YES ? 1 : 0];
    [item setTag:4];
    
    // set menu to poup
    [displayOptionsPopUpButton setMenu:menu];
}

- (void)initFontSizeOptions {
    // init menu and popup button
    NSMenu *menu = [[[NSMenu alloc] init] autorelease];
    NSMenuItem *item = [menu addItemWithTitle:NSLocalizedString(@"FontSize", @"") action:nil keyEquivalent:@""];
    [item setHidden:YES];
    
    for(int i = 8;i <= 11;i++) {
        item = [[[NSMenuItem alloc] init] autorelease];
        [menu addItem:item];    
        [item setTitle:[NSString stringWithFormat:@"%d", i]];
        [item setTag:i];
        [item setState:0];        
    }
    
    for(int i = 12;i <= 78;i+=2) {
        item = [[[NSMenuItem alloc] init] autorelease];
        [menu addItem:item];    
        [item setTitle:[NSString stringWithFormat:@"%d", i]];
        [item setTag:i];
        [item setState:0];        
    }

    // set menu to poup
    [fontSizePopUpButton setMenu:menu];
    [fontSizePopUpButton setTarget:self];
    [fontSizePopUpButton setAction:@selector(fontSizeChange:)];
}

- (void)initTextContextOptions {
    // init menu and popup button
    NSMenu *menu = [[[NSMenu alloc] init] autorelease];
    NSMenuItem *item = [menu addItemWithTitle:NSLocalizedString(@"TextContext", @"") action:nil keyEquivalent:@""];
    [item setHidden:YES];

    item = [[[NSMenuItem alloc] init] autorelease];
    [menu addItem:item];    
    [item setTitle:@"0"];
    [item setTag:0];
    [item setState:0];

    item = [[[NSMenuItem alloc] init] autorelease];
    [menu addItem:item];    
    [item setTitle:@"1"];
    [item setTag:1];
    [item setState:0];

    item = [[[NSMenuItem alloc] init] autorelease];
    [menu addItem:item];    
    [item setTitle:@"2"];
    [item setTag:2];
    [item setState:0];

    item = [[[NSMenuItem alloc] init] autorelease];
    [menu addItem:item];    
    [item setTitle:@"3"];
    [item setTag:3];
    [item setState:0];
    
    item = [[[NSMenuItem alloc] init] autorelease];
    [menu addItem:item];    
    [item setTitle:@"5"];
    [item setTag:5];
    [item setState:0];

    item = [[[NSMenuItem alloc] init] autorelease];
    [menu addItem:item];    
    [item setTitle:@"7"];
    [item setTag:7];
    [item setState:0];

    item = [[[NSMenuItem alloc] init] autorelease];
    [menu addItem:item];    
    [item setTitle:@"10"];
    [item setTag:10];
    [item setState:0];

    // set menu to poup
    [textContextPopUpButton setMenu:menu];
    [textContextPopUpButton setTarget:self];
    [textContextPopUpButton setAction:@selector(textContextChange:)];
}

- (NSInteger)customFontSize {
    if([(WindowHostController *)hostingDelegate isFullScreenMode]) {
        return customFontSize + [[NSUserDefaults standardUserDefaults] integerForKey:DefaultsFullscreenFontSizeAddKey];
    }
    return customFontSize;
}

- (void)setCustomFontSize:(NSInteger)aSize {
    customFontSize = aSize;
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
    [self displayTextForReference:searchString];
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
    [self displayTextForReference:searchString];
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
    [self displayTextForReference:searchString];
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
    [self displayTextForReference:searchString];
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
    [self displayTextForReference:searchString];
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
    [self displayTextForReference:searchString];
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
    [self displayTextForReference:searchString];
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
    [self displayTextForReference:searchString];
}

- (IBAction)displayOptionShowHebrewCantillation:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_HEBREWCANTILLATION];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_HEBREWCANTILLATION];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    forceRedisplay = YES;
    [self displayTextForReference:searchString];
}

- (IBAction)displayOptionShowGreekAccents:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_GREEKACCENTS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_GREEKACCENTS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    forceRedisplay = YES;
    [self displayTextForReference:searchString];    
}

- (IBAction)displayOptionVersesOnOneLine:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [displayOptions setObject:[NSNumber numberWithBool:NO] forKey:DefaultsBibleTextVersesOnOneLineKey];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [displayOptions setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextVersesOnOneLineKey];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    forceRedisplay = YES;
    [self displayTextForReference:searchString];
}

- (IBAction)displayOptionShowFullVerseNumbering:(id)sender {
    [displayOptions setObject:[NSNumber numberWithInt:FullVerseNumbering] forKey:DefaultsBibleTextVerseNumberingTypeKey];
    [(NSMenuItem *)sender setState:NSOnState];
    // disable all other options
    [[verseNumberingMenu itemWithTag:1] setState:NSOffState];
    [[verseNumberingMenu itemWithTag:2] setState:NSOffState];
    
    
    forceRedisplay = YES;
    [self displayTextForReference:searchString];    
}

- (IBAction)displayOptionShowVerseNumberOnly:(id)sender {
    [displayOptions setObject:[NSNumber numberWithInt:VerseNumbersOnly] forKey:DefaultsBibleTextVerseNumberingTypeKey];
    [(NSMenuItem *)sender setState:NSOnState];
    // disable all other options
    [[verseNumberingMenu itemWithTag:0] setState:NSOffState];
    [[verseNumberingMenu itemWithTag:2] setState:NSOffState];
    
    forceRedisplay = YES;
    [self displayTextForReference:searchString];    
}

- (IBAction)displayOptionHideVerseNumbering:(id)sender {
    [displayOptions setObject:[NSNumber numberWithInt:NoVerseNumbering] forKey:DefaultsBibleTextVerseNumberingTypeKey];
    [(NSMenuItem *)sender setState:NSOnState];
    // disable all other options
    [[verseNumberingMenu itemWithTag:0] setState:NSOffState];
    [[verseNumberingMenu itemWithTag:1] setState:NSOffState];
    
    forceRedisplay = YES;
    [self displayTextForReference:searchString];    
}

- (IBAction)displayOptionHighlightBookmarks:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [displayOptions setObject:[NSNumber numberWithBool:NO] forKey:DefaultsBibleTextHighlightBookmarksKey];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [displayOptions setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextHighlightBookmarksKey];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    forceRedisplay = YES;
    [self displayTextForReference:searchString];    
}

- (IBAction)bookPagerAction:(id)sender {
    int clickedSegment = [sender selectedSegment];
    int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    if(clickedSegmentTag == 0) {
        // up
        [hostingDelegate previousBook:self];
    } else if(clickedSegmentTag == 2) {
        // down
        [hostingDelegate nextBook:self];
    }
}

- (IBAction)chapterPagerAction:(id)sender {
    int clickedSegment = [sender selectedSegment];
    int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    if(clickedSegmentTag == 0) {
        // up
        [hostingDelegate previousChapter:self];
    } else if(clickedSegmentTag == 2) {
        // down
        [hostingDelegate nextChapter:self];
    }    
}

#pragma mark - AccessoryProvidingProtocol

- (NSView *)topAccessoryView {
    return referenceOptionsView;
}

- (void)prepareContentForHost:(WindowHostController *)aHostController {
    [super prepareContentForHost:aHostController];
    [self checkAndAddFontSizeMenuItemIfNotExists];
    [[[fontSizePopUpButton menu] itemWithTag:customFontSize] setState:NSOnState];
    [[[textContextPopUpButton menu] itemWithTag:textContext] setState:NSOnState];
    [self setupPopupButtonsForSearchType];
}

- (void)checkAndAddFontSizeMenuItemIfNotExists {
    if(customFontSize > -1) {
        NSMenu *m = [fontSizePopUpButton menu];
        if(m && ![m itemWithTag:customFontSize]) {
            NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
            [item setTitle:[[NSNumber numberWithInt:customFontSize] stringValue]];
            [item setTag:customFontSize];
            [item setState:0];
            
            [m addItem:[NSMenuItem separatorItem]];
            [m addItem:item];            
        }
    }
}

- (void)searchTypeChanged:(SearchType)aSearchType withSearchString:(NSString *)aSearchString {
    [super searchTypeChanged:aSearchType withSearchString:aSearchString];
    [self setupPopupButtonsForSearchType];
}

- (void)setupPopupButtonsForSearchType {
    if(searchType == ReferenceSearchType) {
        [[self modDisplayOptionsPopUpButton] setEnabled:YES];
        [[self displayOptionsPopUpButton] setEnabled:YES];
        [[self fontSizePopUpButton] setEnabled:YES];
        [[self textContextPopUpButton] setEnabled:YES];
    } else {
        [[self modDisplayOptionsPopUpButton] setEnabled:NO];
        [[self displayOptionsPopUpButton] setEnabled:NO];
        [[self fontSizePopUpButton] setEnabled:YES];
        [[self textContextPopUpButton] setEnabled:YES];
    }
}

#pragma mark - ProgressIndicating

- (void)beginIndicateProgress {
    if(viewLoaded) {
        // delegate to host if needed
        // delegates can be:
        // - BibleCombiViewController
        // - SingleViewHostController
        if([delegate isKindOfClass:[BibleCombiViewController class]]) {
            [(BibleCombiViewController *)delegate beginIndicateProgress];
        } else {
            [self putProgressOverlayView];
        }        
    }
}

- (void)endIndicateProgress {
    if(viewLoaded) {
        // delegate to host if needed
        // delegates can be:
        // - BibleCombiViewController
        // - SingleViewHostController
        if([delegate isKindOfClass:[BibleCombiViewController class]]) {
            [(BibleCombiViewController *)delegate endIndicateProgress];
        } else {
            [self removeProgressOverlayView];
        }
        // reset progress indicator values
        [progressController setProgressMaxValue:0.0];
        [progressController setProgressCurrentValue:0.0];
    }
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if(self) {
        NSNumber *fontSize = [decoder decodeObjectForKey:@"CustomFontSizeEncoded"];
        if(fontSize) {
            self.customFontSize = [fontSize intValue];
        }
        self.textContext = [decoder decodeIntegerForKey:@"TextContextKey"];

        NSDictionary *dOpts = [decoder decodeObjectForKey:@"ReferenceModDisplayOptions"];
        if(dOpts) {
            self.modDisplayOptions = [NSMutableDictionary dictionaryWithDictionary:dOpts];
        }
        dOpts = [decoder decodeObjectForKey:@"ReferenceDisplayOptions"];
        if(dOpts) {
            self.displayOptions = [NSMutableDictionary dictionaryWithDictionary:dOpts];
        }
        NSNumber *showingRSB = [decoder decodeObjectForKey:@"ShowingRSBPreferred"];
        if(showingRSB) {
            [self setShowingRSBPreferred:[showingRSB boolValue]];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[NSNumber numberWithInt:customFontSize] forKey:@"CustomFontSizeEncoded"];
    [encoder encodeInteger:textContext forKey:@"TextContextKey"];    
    [encoder encodeObject:modDisplayOptions forKey:@"ReferenceModDisplayOptions"];
    [encoder encodeObject:displayOptions forKey:@"ReferenceDisplayOptions"];
    [encoder encodeObject:[NSNumber numberWithBool:showingRSBPreferred] forKey:@"ShowingRSBPreferred"];
}

@end
