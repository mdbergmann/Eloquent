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


@implementation ModuleCommonsViewController

@synthesize customFontSize;
@synthesize modDisplayOptions;
@synthesize displayOptions;
@synthesize forceRedisplay;
@synthesize reference;

#pragma mark - Initializers

- (id)init {
    self = [super init];
    if(self) {
        
        [self setReference:@""];
        forceRedisplay = NO;

        customFontSize = [userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey];
    }
    
    return self;
}

- (void)awakeFromNib {
    // set state of menuitem representing font size
    [[[fontSizePopUpButton menu] itemWithTag:customFontSize] setState:NSOnState];

    // init display options
    [self initDefaultModDisplayOptions];
    [self initDefaultDisplayOptions];
}

#pragma mark - Display things

- (void)initDefaultModDisplayOptions {
    NSMutableDictionary *dOpts = [NSMutableDictionary dictionaryWithCapacity:3];
    [dOpts setObject:SW_OFF forKey:SW_OPTION_STRONGS];
    [dOpts setObject:SW_OFF forKey:SW_OPTION_MORPHS];
    [dOpts setObject:SW_OFF forKey:SW_OPTION_FOOTNOTES];
    [dOpts setObject:SW_OFF forKey:SW_OPTION_SCRIPTREFS];
    [dOpts setObject:SW_OFF forKey:SW_OPTION_REDLETTERWORDS];
    [dOpts setObject:SW_OFF forKey:SW_OPTION_HEADINGS];
    [dOpts setObject:SW_OFF forKey:SW_OPTION_HEBREWPOINTS];
    [dOpts setObject:SW_OFF forKey:SW_OPTION_HEBREWCANTILLATION];
    [dOpts setObject:SW_OFF forKey:SW_OPTION_GREEKACCENTS];
    self.modDisplayOptions = dOpts;
    
    // init menu and popup button
    NSMenu *menu = [[NSMenu alloc] init];
    modDisplayOptionsMenu = menu;
    NSMenuItem *item = [menu addItemWithTitle:NSLocalizedString(@"ModOptions", @"") action:nil keyEquivalent:@""];
    [item setHidden:YES];
    // strongs
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowStrongsNumbers", @"") action:@selector(displayOptionShowStrongs:) keyEquivalent:@""];
    [item setTag:1];
    [item setTarget:self];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowMorphNumbers", @"") action:@selector(displayOptionShowMorphs:) keyEquivalent:@""];
    [item setTag:2];
    [item setTarget:self];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowFootnotes", @"") action:@selector(displayOptionShowFootnotes:) keyEquivalent:@""];
    [item setTag:3];
    [item setTarget:self];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowCrossRefs", @"") action:@selector(displayOptionShowCrossRefs:) keyEquivalent:@""];
    [item setTag:4];
    [item setTarget:self];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowRedLetterWords", @"") action:@selector(displayOptionShowRedLetterWords:) keyEquivalent:@""];
    [item setTag:5];
    [item setTarget:self];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowHeadings", @"") action:@selector(displayOptionShowHeadings:) keyEquivalent:@""];
    [item setTag:6];
    [item setTarget:self];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowHebrewPoints", @"") action:@selector(displayOptionShowHebrewPoints:) keyEquivalent:@""];
    [item setTag:7];
    [item setTarget:self];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowHebrewCantillation", @"") action:@selector(displayOptionShowHebrewCantillation:) keyEquivalent:@""];
    [item setTag:8];
    [item setTarget:self];
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowGreekAccents", @"") action:@selector(displayOptionShowGreekAccents:) keyEquivalent:@""];
    [item setTag:9];
    [item setTarget:self];
    // set menu to poup
    [modDisplayOptionsPopUpButton setMenu:menu];
}

- (void)initDefaultDisplayOptions {
    NSMutableDictionary *dOpts = [NSMutableDictionary dictionaryWithCapacity:3];
    [dOpts setObject:[userDefaults objectForKey:DefaultsBibleTextVersesOnOneLineKey] forKey:DefaultsBibleTextVersesOnOneLineKey];
    self.displayOptions = dOpts;        

    // init menu and popup button
    NSMenu *menu = [[NSMenu alloc] init];
    displayOptionsMenu = menu;
    NSMenuItem *item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptions", @"") action:nil keyEquivalent:@""];
    [item setHidden:YES];
    // strongs
    item = [menu addItemWithTitle:NSLocalizedString(@"DisplayOptionShowVOOL", @"") action:@selector(displayOptionVersesOnOneLine:) keyEquivalent:@""];
    [item setTarget:self];
    // set menu to poup
    [displayOptionsPopUpButton setMenu:menu];
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
    self = [super init];
    if(self) {
        // decode reference
        self.reference = [decoder decodeObjectForKey:@"ReferenceEncoded"];
        // decode font size
        NSNumber *fontSize = [decoder decodeObjectForKey:@"CustomFontSizeEncoded"];
        if(fontSize) {
            self.customFontSize = [fontSize intValue];        
        } else {
            self.customFontSize = [userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey];
        }
        // display options
        self.modDisplayOptions = [decoder decodeObjectForKey:@"ReferenceModDisplayOptions"];
        if(!modDisplayOptions) {
            // set defaults
            [self initDefaultModDisplayOptions];
        }
        self.displayOptions = [decoder decodeObjectForKey:@"ReferenceDisplayOptions"];
        if(!displayOptions) {
            // set defaults
            [self initDefaultDisplayOptions];
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
