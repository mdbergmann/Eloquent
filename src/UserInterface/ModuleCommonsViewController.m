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
        
        // init display options
        [self initDefaultModDisplayOptions];
        [self initDefaultDisplayOptions];        
    }
    
    return self;
}

- (void)awakeFromNib {
    // set state of menuitem representing font size
    [[[fontSizePopUpButton menu] itemWithTag:customFontSize] setState:NSOnState];
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
    self.modDisplayOptions = dOpts;
}

- (void)initDefaultDisplayOptions {
    NSMutableDictionary *dOpts = [NSMutableDictionary dictionaryWithCapacity:3];
    [dOpts setObject:[userDefaults objectForKey:DefaultsBibleTextVersesOnOneLineKey] forKey:DefaultsBibleTextVersesOnOneLineKey];
    self.displayOptions = dOpts;        
}

/** 
 abstract method, subclasses should override
 this is for validating the module display options
 */
- (void)validateModDisplayOptions {
    // nothing done here
    // we need a module to validate options
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
