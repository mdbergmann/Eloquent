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
    self[NormalDisplayFontFamilyNameKey] = [aFont familyName];
    self[DisplayFontSizeKey] = @((int) [aFont pointSize]);
}

- (void)setDisplayFontBold:(NSFont *)aFont {
    self[BoldDisplayFontFamilyNameKey] = [aFont familyName];
    self[DisplayFontSizeKey] = @((int) [aFont pointSize]);
}

- (void)setDisplayDefaultFonts {
    // normal font
    NSString *fontFamily = [UserDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey];
    NSInteger fontSize = [UserDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey];
    [self setDisplayFont:[NSFont fontWithName:fontFamily size:(float)fontSize]];
    
    // bold font
    fontFamily = [UserDefaults stringForKey:DefaultsBibleTextDisplayBoldFontFamilyKey];
    fontSize = [UserDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey];
    [self setDisplayFontBold:[NSFont fontWithName:fontFamily size:(float)fontSize]];    
}

@end
