//
//  NSMutableDictionary+ModuleDisplaySettings.h
//  Eloquent
//
//  Created by Manfred Bergmann on 15.12.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMutableDictionary (ModuleDisplaySettings)

- (void)setDisplayFont:(NSFont *)aFont;
- (void)setDisplayFontBold:(NSFont *)aFont;
- (void)setDisplayDefaultFonts;

@end
