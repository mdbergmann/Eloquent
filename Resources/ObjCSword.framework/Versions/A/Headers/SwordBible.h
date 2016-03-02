/*	SwordBible.h - Sword API wrapper for Biblical Texts.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#import "versekey.h"
#endif

@class SwordModule, SwordManager, SwordBibleBook, SwordModuleTextEntry, SwordBibleTextEntry;
@class SwordKey;

typedef enum {
	OldTestament = 1,
	NewTestament
}Testament;

@interface SwordBible : SwordModule {
    NSDictionary *_books;
}

@property (strong, readwrite) NSDictionary *books;

// ----------- class methods -------------
+ (void)decodeRef:(NSString *)ref intoBook:(NSString **)bookName book:(int *)book chapter:(int *)chapter verse:(int *)verse;
+ (NSString *)firstRefName:(NSString *)abbr;
+ (NSString *)context:(NSString *)abbr;
#ifdef __cplusplus
+ (int)bookIndexForSWKey:(sword::VerseKey *)key;
#endif


- (BOOL)hasReference:(NSString *)ref;
- (int)numberOfVerseKeysForReference:(NSString *)aReference;

// book lists
- (NSArray *)bookList;

- (NSString *)bookIntroductionFor:(SwordBibleBook *)aBook;
- (NSString *)chapterIntroductionIn:(SwordBibleBook *)aBook forChapter:(int)chapter;
- (NSString *)moduleIntroduction;

// some numbers
- (SwordBibleBook *)bookWithNamePrefix:(NSString *)aPrefix;
- (SwordBibleBook *)bookForName:(NSString *)bookName;
- (int)chaptersForBookName:(NSString *)bookName;
- (int)versesForChapter:(int)chapter bookName:(NSString *)bookName;
- (int)versesForBible;

// Text pulling

/**
* @return SwordBibleTextEntry
*/
- (SwordModuleTextEntry *)textEntryForKey:(SwordKey *)aKey textType:(TextPullType)aType;
- (NSArray *)strippedTextEntriesForRef:(NSString *)reference context:(int)context;
- (NSArray *)renderedTextEntriesForRef:(NSString *)reference context:(int)context;
/**
 Override from super class
 @return Array of SwordBibleTextEntry
 */
- (NSArray *)textEntriesForReference:(NSString *)aReference textType:(TextPullType)textType;

@end