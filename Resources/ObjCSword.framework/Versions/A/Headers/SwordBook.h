/*	SwordBook.h - Sword API wrapper for GenBooks.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import <Foundation/Foundation.h>
#import "SwordModule.h"

#ifdef __cplusplus
#include <treekeyidx.h>
#endif

#define GenBookRootKey @"root"

@class SwordModule, SwordManager, SwordModuleTreeEntry;

@interface SwordBook : SwordModule {
	NSMutableDictionary *contents;
}

@property(readwrite, strong) NSMutableDictionary *contents;

/**
 return the tree content for the given treeKey
 the treeKey has to be already loaded
 @param[in]: treeKey that we should look for, nil for root
 @return: SwordTreeEntry
 */
- (SwordModuleTreeEntry *)treeEntryForKey:(NSString *)treeKey;

@end
