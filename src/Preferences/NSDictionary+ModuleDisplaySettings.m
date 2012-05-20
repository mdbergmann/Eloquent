//
//  NSDictionary+ModuleDisplaySettings.m
//  Eloquent
//
//  Created by Manfred Bergmann on 15.12.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "NSDictionary+ModuleDisplaySettings.h"

@implementation NSDictionary (ModuleDisplaySettings)

- (NSFont *)displayFont {
    NSString *fontFamily = [self objectForKey:NormalDisplayFontFamilyNameKey];
    int fontSize = [[self objectForKey:DisplayFontSizeKey] intValue];
    return [NSFont fontWithName:fontFamily size:(float)fontSize];
}

- (NSFont *)displayFontBold {
    NSString *fontFamily = [self objectForKey:BoldDisplayFontFamilyNameKey];
    int fontSize = [[self objectForKey:DisplayFontSizeKey] intValue];
    return [NSFont fontWithName:fontFamily size:(float)fontSize];
}

- (NSInteger)displayFontSize {
    return [[self objectForKey:DisplayFontSizeKey] integerValue];
}

@end
