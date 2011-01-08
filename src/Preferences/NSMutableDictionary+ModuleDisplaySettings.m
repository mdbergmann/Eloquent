//
//  NSMutableDictionary+ModuleDisplaySettings.m
//  Eloquent
//
//  Created by Manfred Bergmann on 15.12.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "NSMutableDictionary+ModuleDisplaySettings.h"
#import "NSDictionary+ModuleDisplaySettings.h"
#import "globals.h"
#import "MBPreferenceController.h"

@implementation NSMutableDictionary (ModuleDisplaySettings)

- (void)setDisplayFont:(NSFont *)aFont {
    [self setObject:[aFont familyName] forKey:NormalDisplayFontFamilyNameKey];
    [self setObject:[NSNumber numberWithInt:(int)[aFont pointSize]] forKey:DisplayFontSizeKey];
}

- (void)setDisplayFontBold:(NSFont *)aFont {
    [self setObject:[aFont familyName] forKey:BoldDisplayFontFamilyNameKey];
    [self setObject:[NSNumber numberWithInt:(int)[aFont pointSize]] forKey:DisplayFontSizeKey];
}

- (void)setDisplayDefaultFonts {
    // normal font
    NSString *fontFamily = [userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey];
    int fontSize = [userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey];
    [self setDisplayFont:[NSFont fontWithName:fontFamily size:(float)fontSize]];
    
    // bold font
    fontFamily = [userDefaults stringForKey:DefaultsBibleTextDisplayBoldFontFamilyKey];
    fontSize = [userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey];
    [self setDisplayFontBold:[NSFont fontWithName:fontFamily size:(float)fontSize]];    
}

@end
