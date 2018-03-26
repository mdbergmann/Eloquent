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

@interface SwordBible : SwordModule

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
 * Delegates to textEntriesForReference:context:textType:
 * @param aReference the reference like 'Gen 1'
 * @param context a context setting. when set > 0 then verses surrounding a key will also be retrieved.
 * @return
 */
- (NSArray *)strippedTextEntriesForReference:(NSString *)aReference context:(int)context;

/**
 * Delegates to textEntriesForReference:context:textType:
 * @param aReference the reference like 'Gen 1'
 * @param context a context setting. when set > 0 then verses surrounding a key will also be retrieved.
 * @return
 */
- (NSArray *)renderedTextEntriesForReference:(NSString *)aReference context:(int)context;

/**
 Override from super class
 Delegates to textEntriesForReference:context:textType:

 The block received an instance of SwordBibleTextEntry

 @return Array of SwordBibleTextEntry
 */
- (NSArray *)textEntriesForReference:(NSString *)aReference
                          renderType:(RenderType)aType
                           withBlock:(void(^)(SwordModuleTextEntry *))entryResult;

/**
 * The actual implementation.
 *
 * It locks and unlock the module.
 *
 * The block received an instance of SwordBibleTextEntry
 *
 * @param aReference
 * @param context
 * @param aType
 * @return
 */
- (NSArray *)textEntriesForReference:(NSString *)aReference
                             context:(int)context
                          renderType:(RenderType)aType
                           withBlock:(void(^)(SwordModuleTextEntry *))entryResult;

/**
 * Overriding from SwordModule to return SwordBibleTextEntry.
 * @param aReference
 * @param aType
 * @return
 */
- (SwordModuleTextEntry *)textEntryForReference:(NSString *)aReference renderType:(RenderType)aType;

@end