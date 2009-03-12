/*	SwordBible.h - Sword API wrapper for Biblical Texts.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import <Cocoa/Cocoa.h>
#import "SwordModule.h"

@class SwordManager, SwordBibleBook;

typedef enum {
	OldTestament,
	NewTestament
}Testament;

@interface SwordBible : SwordModule <SwordModuleAccess> {
    NSMutableDictionary *books;
}

@property (retain, readwrite) NSMutableDictionary *books;

// ----------- class methods -------------
+ (void)decodeRef:(NSString *)ref intoBook:(NSString **)bookName book:(int *)book chapter:(int *)chapter verse:(int *)verse;
+ (NSString *)firstRefName:(NSString *)abbr;
+ (NSString *)context:(NSString *)abbr;

// ----------- instance methods ------------
- (id)initWithName:(NSString *)name swordManager:(SwordManager *)aManager;

- (BOOL)hasReference:(NSString *)ref;
- (int)numberOfVerseKeysForReference:(NSString *)aReference;

// book lists
- (NSArray *)bookList;

// some numbers
- (int)chaptersForBookName:(NSString *)bookName;
- (int)versesForChapter:(int)chapter bookName:(NSString *)bookName;
- (int)versesForBible;

// ------- SwordModuleAccess ---------
- (NSArray *)stripedTextForRef:(NSString *)reference;
- (NSArray *)renderedTextForRef:(NSString *)reference;
- (long)entryCount;
- (void)writeEntry:(NSString *)value forRef:(NSString *)reference;

@end