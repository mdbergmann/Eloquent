/*	SwordDict.h - Sword API wrapper for lexicons and Dictionaries.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import <Cocoa/Cocoa.h>
#import <SwordModule.h>

@class SwordManager;

@interface SwordDictionary : SwordModule <SwordModuleAccess> {
	NSMutableArray *entries;
}

- (id)initWithName:(NSString *)aName swordManager:(SwordManager *)aManager;

- (NSArray *)getEntries;
- (BOOL)hasReference:(NSString *)ref;
- (NSString *)fullRefName:(NSString *)ref;

// ------- SwordModuleAccess ---------
- (int)htmlForRef:(NSString *)reference html:(NSString **)htmlString;
- (long)entryCount;
- (void)writeEntry:(NSString *)value forRef:(NSString *)reference;

@end
