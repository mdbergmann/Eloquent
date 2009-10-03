/*	SwordBible.mm - Sword API wrapper for Biblical Texts.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import "SwordBible.h"
#import "MBPreferenceController.h"
#import "globals.h"
#import "utils.h"
#import "SwordBibleBook.h"
#import "SwordListKey.h"
#import "SwordModuleTextEntry.h"

using sword::AttributeTypeList;
using sword::AttributeList;
using sword::AttributeValue;
#include "versemgr.h"

@interface SwordBible ()

- (void)buildBookList;
- (BOOL)containsBookNumber:(int)aBookNum;

@end

@implementation SwordBible

@dynamic books;

#pragma mark - class methods

NSLock *bibleLock = nil;

// changes an abbreviated reference into a full
// eg. Dan4:5-7 => Daniel4:5
+ (void)decodeRef:(NSString *)ref intoBook:(NSString **)bookName book:(int *)book chapter:(int *)chapter verse:(int *)verse {
    
	if(!bibleLock) bibleLock = [[NSLock alloc] init];
	[bibleLock lock];
	
	sword::VerseKey vk([ref UTF8String]);
	
	*bookName = [NSString stringWithUTF8String:vk.getBookName()];
    *book = vk.Book();
	*chapter = vk.Chapter();
	*verse = vk.Verse();
    
	[bibleLock unlock];
}

+ (NSString *)firstRefName:(NSString *)abbr {
	if(!bibleLock) bibleLock = [[NSLock alloc] init];
	[bibleLock lock];
	
	sword::VerseKey vk([abbr UTF8String]);
	NSString *result = [NSString stringWithUTF8String:vk];
    
	[bibleLock unlock];
	
	return result;
}

+ (NSString *)context:(NSString *)abbr {

	//get parsed simple ref
	NSString *first = [SwordBible firstRefName:abbr];
	NSArray *firstbits = [first componentsSeparatedByString:@":"];
	
	//if abbr contains : or . then we are a verse so return a chapter
	if([abbr rangeOfString:@":"].location != NSNotFound || [abbr rangeOfString:@"."].location != NSNotFound) {
		return [firstbits objectAtIndex:0];
    }
	
	//otherwise return a book
	firstbits = [first componentsSeparatedByString:@" "];
	
	if([firstbits count] > 0) {
		return [firstbits objectAtIndex:0];
    }
	
	return abbr;
}

/**
 get book index for versekey
 that is: book number + testament * 100
 */
+ (int)bookIndexForSWKey:(sword::VerseKey *)key {
    return key->Book() + key->Testament() * 100;
}

#pragma mark - instance methods

- (id)initWithName:(NSString *)aName swordManager:(SwordManager *)aManager {    
	self = [super initWithName:aName swordManager:aManager];
    if(self) {
        [self setBooks:nil];
	}
    
	return self;
}

- (id)initWithSWModule:(sword::SWModule *)aModule swordManager:(SwordManager *)aManager {
    self = [super initWithSWModule:aModule swordManager:aManager];
    if(self) {
        [self setBooks:nil];    
    }
    
    return self;
}

- (void)finalize {
	[super finalize];
}

- (void)buildBookList {
    
	[moduleLock lock];
    
    sword::VerseMgr *vmgr = sword::VerseMgr::getSystemVerseMgr();
    const sword::VerseMgr::System *system = vmgr->getVersificationSystem([[self versification] UTF8String]);

    NSMutableDictionary *buf = [NSMutableDictionary dictionary];
    int bookCount = system->getBookCount();
    for(int i = 0;i < bookCount;i++) {
        sword::VerseMgr::Book *book = (sword::VerseMgr::Book *)system->getBook(i);
        
        SwordBibleBook *bb = [[SwordBibleBook alloc] initWithBook:book];
        [bb setNumber:i+1];
        
        [buf setObject:bb forKey:[bb name]];
    }
    self.books = buf;
    
	[moduleLock unlock];
}

- (BOOL)containsBookNumber:(int)aBookNum {
    for(SwordBibleBook *bb in [self books]) {
        if([bb number] == aBookNum) {
            return YES;
        }
    }
    return NO;
}

- (NSMutableDictionary *)books {
    if(books == nil) {
        [self buildBookList];
    }
    return books;
}

- (void)setBooks:(NSMutableDictionary *)aBooks {
    [aBooks retain];
    [books release];
    books = aBooks;
}

- (NSArray *)bookList {
    NSDictionary *b = [self books];
    NSArray *bl = [[b allValues] sortedArrayUsingSelector:@selector(compare:)];
    return bl;
}

- (BOOL)hasReference:(NSString *)ref {
    BOOL ret = NO;    
    
	[moduleLock lock];
	
	sword::VerseKey	*key = (sword::VerseKey *)(swModule->CreateKey());
	(*key) = [ref UTF8String];
    NSString *bookName = [NSString stringWithUTF8String:key->getBookName()];
    int chapter = key->Chapter();
    int verse = key->Verse();
    
    SwordBibleBook *bb = [[self books] objectForKey:bookName];
    if(bb) {
        if(chapter > 0 && chapter < [bb numberOfChapters]) {
            if(verse > 0 && verse < [bb numberOfVersesForChapter:chapter]) {
                ret = YES;
            }
        }
    }    
    
	[moduleLock unlock];
	
	return ret;
}

- (int)numberOfVerseKeysForReference:(NSString *)aReference {
    int ret = 0;
    
    if(aReference && [aReference length] > 0) {
        sword::VerseKey vk;
        sword::ListKey listKey = vk.ParseVerseList([aReference UTF8String], "Gen1", true);
        // unfortunately there is no other way then loop though all verses to know how many
        for(listKey = sword::TOP; !listKey.Error(); listKey++) ret++;    
    }
    
    return ret;
}

- (int)chaptersForBookName:(NSString *)bookName {
	[moduleLock lock];
	
	int maxChapters = 0;
	sword::VerseKey *key = (sword::VerseKey *)swModule->CreateKey();
	(*key) = [bookName UTF8String];
	maxChapters = key->getChapterMax();
	delete key;
	
	[moduleLock unlock];
	
	return maxChapters;
}


- (int)versesForChapter:(int)chapter bookName:(NSString *)bookName {
    int ret = -1;
    
	[moduleLock lock];
	
    SwordBibleBook *bb = [[self books] objectForKey:bookName];
    if(bb) {
        ret = [bb numberOfVersesForChapter:chapter];
    }
    
	[moduleLock unlock];
	
	return ret;
}

- (int)versesForBible {

    int ret = 0;

    for(SwordBibleBook *bb in [self books]) {
        int chapters = [bb numberOfChapters];
        int verses = 0;
        for(int j = 1;j <= chapters;j++) {
            verses += [bb numberOfVersesForChapter:j];
        }
        ret += verses;
    }
    
    return ret;
}

#pragma mark - SwordModuleAccess

- (long)entryCount {
    swModule->setPosition(sword::TOP);
    unsigned long verseLowIndex = swModule->Index();
    swModule->setPosition(sword::BOTTOM);
    unsigned long verseHighIndex = swModule->Index();
    
    return verseHighIndex - verseLowIndex;
}

- (NSArray *)strippedTextEntriesForRef:(NSString *)reference {
    return [self strippedTextEntriesForRef:reference context:0];
}

- (NSArray *)strippedTextEntriesForRef:(NSString *)reference context:(int)context {
    NSMutableArray *ret = [NSMutableArray array];
    
    [moduleLock lock];
    
    const char *cref = [reference UTF8String];
    sword::VerseKey	vk;
    vk.setVersificationSystem([[self versification] UTF8String]);
    sword::ListKey lk = vk.ParseVerseList(cref, vk, true);
    // iterate through keys
    for (lk = sword::TOP; !lk.Error(); lk++) {
        // set current key to vk
        vk.setText(lk.getText());
        NSString *keyString = [NSString stringWithUTF8String:vk.getText()];
        if(context != 0) {
            vk.setVerse(vk.getVerse() - context);
            for(int i = 0;i <= context*2;i++) {
                SwordModuleTextEntry *entry = [self textEntryForKey:keyString textType:TextTypeStripped];
                if(entry) {
                    [ret addObject:entry];        
                }
                vk.increment();
            }
        } else {
            SwordModuleTextEntry *entry = [self textEntryForKey:keyString textType:TextTypeStripped];
            if(entry) {
                [ret addObject:entry];
            }            
        }
    }
    
    [moduleLock unlock];        
    
    return ret;
}

- (NSArray *)renderedTextEntriesForRef:(NSString *)reference {
    return [self renderedTextEntriesForRef:reference context:0];
}

- (NSArray *)renderedTextEntriesForRef:(NSString *)reference context:(int)context {
    NSMutableArray *ret = [NSMutableArray array];
    
    const char *cref = [reference UTF8String];
    sword::VerseKey	vk;
    vk.setVersificationSystem([[self versification] UTF8String]);
    sword::ListKey lk = vk.ParseVerseList(cref, vk, true);
    // iterate through keys
    for (lk = sword::TOP; !lk.Error(); lk++) {
        // set current key to vk
        vk.setText(lk.getText());
        NSString *keyString = [NSString stringWithUTF8String:vk.getText()];
        if(context != 0) {
            vk.setVerse(vk.getVerse() - context);
            for(int i = 0;i <= context*2;i++) {
                SwordModuleTextEntry *entry = [self textEntryForKey:keyString textType:TextTypeRendered];
                if(entry) {
                    [ret addObject:entry];        
                }
                vk.increment();
            }
        } else {
            SwordModuleTextEntry *entry = [self textEntryForKey:keyString textType:TextTypeRendered];
            if(entry) {
                [ret addObject:entry];
            }            
        }
    }
    
    return ret;
}

- (void)writeEntry:(SwordModuleTextEntry *)anEntry {
	[moduleLock lock];
	
	sword::VerseKey vk = sword::VerseKey([[anEntry key] UTF8String]);
    vk.setVersificationSystem([[self versification] UTF8String]);

    const char *data = [[anEntry text] UTF8String];
    int dLen = strlen(data);

    swModule->setKey(vk);
    if(![self error]) {
        swModule->setEntry(data, dLen);	// save text to module at current position    
    } else {
        MBLOG(MBLOG_ERR, @"[SwordBible -writeEntry:] error at positioning module!");
    }

	[moduleLock unlock];
}

@end
