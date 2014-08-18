//
//  NSDictionary+ModuleDisplaySettings.h
//  Eloquent
//
//  Created by Manfred Bergmann on 15.12.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define NormalDisplayFontFamilyNameKey  @"NormalDisplayFontFamilyNameKey"
#define BoldDisplayFontFamilyNameKey    @"BoldDisplayFontFamilyNameKey"
#define DisplayFontSizeKey              @"DisplayFontSizeKey"

@interface NSDictionary (ModuleDisplaySettings)

- (NSFont *)displayFont;
- (NSFont *)displayFontBold;
- (NSInteger)displayFontSize;

@end
