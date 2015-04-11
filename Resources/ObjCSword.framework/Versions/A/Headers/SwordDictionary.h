/*	SwordDict.h - Sword API wrapper for lexicons and Dictionaries.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import <Foundation/Foundation.h>

@class SwordManager, SwordModule;

@interface SwordDictionary : SwordModule {
    /** only keys are buffered here */
	NSMutableArray *keys;
}

- (NSArray *)allKeys;
- (NSString *)entryForKey:(NSString *)aKey;

@end
