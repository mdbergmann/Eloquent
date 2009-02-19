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

using sword::AttributeTypeList;
using sword::AttributeList;
using sword::AttributeValue;
#include "versemgr.h"

@interface SwordBible ()

- (void)getBookData;
- (NSNumber *)bookNumberForSWKey:(sword::VerseKey *)key;
- (BOOL)containsBookNumber:(NSNumber *)aBookNum;

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

#pragma mark - instance methods

- (id)initWithName:(NSString *)aName swordManager:(SwordManager *)aManager {
    
	self = [super initWithName:aName swordManager:aManager];
    if(self) {
        // init bookData
        [self setBooks:nil];
	}
    
	return self;
}

- (void)finalize {
	[super finalize];
}

/**
 build book list
 */
- (void)getBookData {
    
	[moduleLock lock];
    
    sword::VerseMgr *vmgr = sword::VerseMgr::getSystemVerseMgr();
    const sword::VerseMgr::System *system = vmgr->getVersificationSystem("KJV");
        
    // number of books in this module
    NSMutableDictionary *buf = [NSMutableDictionary dictionary];
    int bookCount = system->getBookCount();
    for(int i = 0;i < bookCount;i++) {
        sword::VerseMgr::Book *book = (sword::VerseMgr::Book *)system->getBook(i);
        /*
        int maxChapters = book->getChapterMax();
        const char *cbookn = book->getLongName();
        
        NSString *bookName = @"";
        bookName = [NSString stringWithUTF8String:cbookn];
        SwordBibleBook *bb = [[SwordBibleBook alloc] initWithName:bookName];
        [bb setNumber:[NSNumber numberWithInt:i+1]];
        [bb setNumberOfChapters:[NSNumber numberWithInt:maxChapters]];
         */
        
        SwordBibleBook *bb = [[SwordBibleBook alloc] initWithBook:book];
        [bb setNumber:[NSNumber numberWithInt:i+1]];
        
        [buf setObject:bb forKey:[bb name]];
    }
    self.books = buf;
    
    /*
	bool skipsLinks;
    
    // save this
	skipsLinks = swModule->getSkipConsecutiveLinks();
	swModule->setSkipConsecutiveLinks(true);
	
	sword::VerseKey	currentKey, bottom;
	int lastBook;
    
    // position bottom marker
	bottom.setPosition(sword::BOTTOM);
	*swModule = sword::BOTTOM;
	bottom = swModule->Key();
	
    // we start from top
	*swModule = sword::TOP;
	
	NSMutableArray *buf = [NSMutableArray array];
	currentKey = (sword::VerseKey)swModule->Key();	
	while (!swModule->Key().Error() && currentKey < bottom) {
		currentKey = (sword::VerseKey)swModule->Key();
        const char *cbookn = currentKey.getBookName();
        // bookname and number
        NSString *bookName = @"";
        bookName = [NSString stringWithUTF8String:cbookn];
        SwordBibleBook *bb = [[SwordBibleBook alloc] initWithName:bookName];
        [bb setNumber:[self bookNumberForSWKey:&currentKey]];
        [bb setNumberOfChapters:[NSNumber numberWithInt:[self chaptersForBookName:bookName]]];
        
        // get english bookname
        sword::VerseKey engKey = currentKey;
        engKey.setLocale("en");
        cbookn = engKey.getBookName();
        NSString *engBookName = [NSString stringWithUTF8String:cbookn];
        [bb setEngName:engBookName];
        [buf addObject:bb];
        
		lastBook = currentKey.Book();
		currentKey.Book(currentKey.Book() + 1 );
		swModule->setKey(currentKey);
	}
	
    // add arrays
    self.books = buf;
    
    // set back
	swModule->setSkipConsecutiveLinks(skipsLinks);
     */
	
	[moduleLock unlock];    
}

/**
 get book number for versekey
 TODO: create new version which uses SwordBibleBook
 */
- (NSNumber *)bookNumberForSWKey:(sword::VerseKey *)key {
    return [NSNumber numberWithInt:key->Book() + key->Testament() * 100];
}

/**
 checks whether the given book number is part of this module
 TODO: create new version which uses SwordBibleBook
 */
- (BOOL)containsBookNumber:(NSNumber *)aBookNum {
    for(SwordBibleBook *bb in [self books]) {
        if([[bb number] intValue] == [aBookNum intValue]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSMutableDictionary *)books {
    if(books == nil) {
        [self getBookData];
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

/*
// returns an array containing all the book names found in this module.
- (NSArray *)bookNames {
    NSArray *ret = [NSArray arrayWithArray:[bookData objectForKey:BOOKNAMES_KEY]];
    if((ret == nil) || ([ret count] == 0)) {
        // not loaded?
        [self getBookNames];
        // try again
        ret = [NSArray arrayWithArray:[bookData objectForKey:BOOKNAMES_KEY]];
    }
	return ret;
}

- (NSArray *)engBookNames {	
    NSArray *ret = [NSArray arrayWithArray:[bookData objectForKey:ENGBOOKNAMES_KEY]];
    if((ret == nil) || ([ret count] == 0)) {
        // not loaded?
        [self getBookNames];
        // try again
        ret = [NSArray arrayWithArray:[bookData objectForKey:ENGBOOKNAMES_KEY]];
    }
	return ret;
}
*/

// just checks whether module contains book atm
- (BOOL)hasReference:(NSString *)ref {
    BOOL ret = NO;    
    
	[moduleLock lock];
	
	sword::VerseKey	*key = (sword::VerseKey *)(swModule->CreateKey());
	(*key) = [ref UTF8String];
    // get bookname
    NSString *bookName = [NSString stringWithUTF8String:key->getBookName()];
    int chapter = key->Chapter();
    int verse = key->Verse();
    
    // get the correct book
    SwordBibleBook *bb = [[self books] objectForKey:bookName];
    if(bb) {
        if(chapter > 0 && chapter < [[bb numberOfChapters] intValue]) {
            if(verse > 0 && verse < [[bb numberOfVersesForChapter:chapter] intValue]) {
                ret = YES;
            }
        }
    }    
    
	[moduleLock unlock];
	
	return ret;
}

- (NSString *)fullRefName:(NSString *)ref { 	
	[moduleLock lock];
    
	sword::ListKey		listkey;
	sword::VerseKey		vk;
	int					lastIndex;
	int					chapter=-1, book=-1, verse=-1, startChapter, startVerse;
	NSMutableString		*reference = [NSMutableString string];
	
	listkey = vk.ParseVerseList(toUTF8(ref), "Gen1", true);
	
	int len = listkey.Count();
	for(int i = 0; i < len; i++) {
		sword::VerseKey *element = My_SWDYNAMIC_CAST(VerseKey, listkey.GetElement(i));
		
		// is it a chapter or book - not atomic
		if(element) {
			// start at lower bound
			swModule->Key(element->LowerBound());
			// find the upper bound
			vk = element->UpperBound();
			vk.Headings();
		} else {
			// set it up
			swModule->Key(*listkey.GetElement(i));
		}
		
		unichar mdashchars[1] = {0x2013};
		NSString *mdash = [NSString stringWithCharacters:mdashchars length:1];
        
		// while not past the upper bound
		do {
			int newBook = ((sword::VerseKey)(swModule->Key())).Book();
			int newChapter = ((sword::VerseKey)(swModule->Key())).Chapter();
			int newVerse = ((sword::VerseKey)(swModule->Key())).Verse();
			
			if(book != newBook) {
				if(book != -1) {
					if(startChapter != chapter) [reference appendString:[NSString stringWithFormat:@"%@%d:%d; ", mdash, chapter, verse]];
					else if(startVerse != verse) [reference appendString:[NSString stringWithFormat:@"%@%d; ", mdash, verse]];
					else [reference appendString:@"; "];
				}
				[reference appendString:[NSString stringWithFormat:@"%@",fromUTF8(swModule->Key().getText())]];
				startChapter = newChapter; startVerse = newVerse;
			} else if(chapter != newChapter && lastIndex != (swModule->Key()).Index()-2) {
				if(book != -1) {
					if(startChapter != chapter) [reference appendString:[NSString stringWithFormat:@"%@%d:%d; ", mdash, chapter, verse]];
					else if(startVerse != verse) [reference appendString:[NSString stringWithFormat:@"%@%d; ", mdash, verse]];
					else [reference appendString:@"; "];
				}
				[reference appendString:[NSString stringWithFormat:@"%d:%d", newChapter, newVerse]];
				startChapter = newChapter; startVerse = newVerse;
			} else if(verse != newVerse-1 && chapter == newChapter) {
				[reference appendString:[NSString stringWithFormat:@",%d",newVerse]];
				startVerse = newVerse;
			}
			
			NSLog(@"reference::%@",reference);
			
			book = newBook;
			chapter = newChapter;
			verse = newVerse;
            
			lastIndex = (swModule->Key()).Index();
			(*swModule)++;
			if(lastIndex == (swModule->Key()).Index())
				break;
		}while (element && swModule->Key() <= vk);
		
		if(startChapter != chapter)
			[reference appendString:[NSString stringWithFormat:@"%@%d:%d", mdash, chapter, verse]];
		else if(startVerse != verse)
			[reference appendString:[NSString stringWithFormat:@"%@%d", mdash, verse]];
	}
	
	[moduleLock unlock];
	
	return reference;
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
        ret = [[bb numberOfVersesForChapter:chapter] intValue];
    }
    
	[moduleLock unlock];
	
	return ret;
}

/**
 calculate all verses for this bible book
 */
- (int)versesForBible {

    int ret = 0;

    for(SwordBibleBook *bb in [self books]) {
        // get chapters for book
        int chapters = [[bb numberOfChapters] intValue];
        // calculate all verses for this book
        int verses = 0;
        for(int j = 1;j <= chapters;j++) {
            verses += [[bb numberOfVersesForChapter:j] intValue];
        }
        ret += verses;
    }
    
    return ret;
}

#pragma mark - SwordModuleAccess

/** 
 numnber of entries
 */
- (long)entryCount {
    
    //*swModule = sword::TOP;
    swModule->setPosition(sword::TOP);
    unsigned long verseLowIndex = swModule->Index();
    //*swModule = sword::BOTTOM;
    swModule->setPosition(sword::BOTTOM);
    unsigned long verseHighIndex = swModule->Index();
    
    return verseHighIndex - verseLowIndex;
}

- (NSArray *)stripedTextForRef:(NSString *)reference {
    NSMutableArray *ret = [NSMutableArray array];
        
    const char *cref = [reference UTF8String];
    sword::VerseKey	vk;
    sword::ListKey listkey = vk.ParseVerseList(cref, vk, true);
    listkey.Persist(true);
    swModule->setKey(listkey);
    // iterate through keys
    for ((*swModule) = sword::TOP; !swModule->Error(); (*swModule)++) {
        const char *keyCStr = swModule->getKeyText();
        const char *txtCStr = swModule->StripText();
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];            
        NSString *key = [NSString stringWithUTF8String:keyCStr];
        NSString *txt = @"";
        txt = [NSString stringWithUTF8String:txtCStr];
        // add to dict
        [dict setObject:txt forKey:SW_OUTPUT_TEXT_KEY];
        [dict setObject:key forKey:SW_OUTPUT_REF_KEY];
        // add to array
        [ret addObject:dict];
    }
    // remove persitent key
    swModule->setKey("gen.1.1");
    
    return ret;
}

/*
 - (NSArray *)renderedTextForRef:(NSString *)reference {
 NSMutableArray *ret = nil;
 
 const char *cref = [reference UTF8String];
 sword::VerseKey	vk;
 sword::ListKey listkey = vk.ParseVerseList(cref, "Gen1", true);
 int lastIndex;
 int listKeyLen = listkey.Count();
 ret = [NSMutableArray arrayWithCapacity:listKeyLen];
 // this is what get s stored in return array
 MSStringMgr *strMgr = new MSStringMgr();
 for(int i = 0; i < listKeyLen; i++) {
 sword::VerseKey *element = My_SWDYNAMIC_CAST(VerseKey, listkey.GetElement(i));
 
 // is it a chapter or book - not atomic
 if(element) {
 // start at lower bound
 element->Headings(1);
 swModule->Key(element->LowerBound());
 // find the upper bound
 vk = element->UpperBound();
 vk.Headings(true);
 } else {
 // set it up
 swModule->setKey(*listkey.GetElement(i));
 }
 
 // while not past the upper bound
 do {
 const char *keyCStr = swModule->Key().getText();
 const char *txtCStr = swModule->RenderText();
 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];            
 NSString *key = [NSString stringWithUTF8String:keyCStr];
 NSString *txt = @"";
 if(strMgr->isUtf8(txtCStr)) {
 txt = [NSString stringWithUTF8String:txtCStr];
 } else {
 txt = [NSString stringWithCString:txtCStr encoding:NSISOLatin1StringEncoding];
 }
 // add to dict
 [dict setObject:txt forKey:SW_OUTPUT_TEXT_KEY];
 [dict setObject:key forKey:SW_OUTPUT_REF_KEY];
 // add to array
 [ret addObject:dict];

 // check for any entry attributes
 AttributeTypeList::iterator i1;
 AttributeList::iterator i2;
 AttributeValue::iterator i3;
 for (i1 = swModule->getEntryAttributes().begin(); i1 != swModule->getEntryAttributes().end(); i1++) {
 MBLOGV(MBLOG_DEBUG, @"%@\n", [NSString stringWithUTF8String:i1->first]);
 for (i2 = i1->second.begin(); i2 != i1->second.end(); i2++) {
 MBLOGV(MBLOG_DEBUG, @"\t%@\n", [NSString stringWithUTF8String:i2->first]);
 for (i3 = i2->second.begin(); i3 != i2->second.end(); i3++) {
 MBLOGV(MBLOG_DEBUG, @"\t\t%@ = %@\n", [NSString stringWithUTF8String:i3->first], [NSString stringWithUTF8String:i3->second]);
 }
 }                    
 }

// get current index
lastIndex = (swModule->Key()).Index();
// increment index
(*swModule)++;
// check for index has not changed afer increment
if(lastIndex == (swModule->Key()).Index()) {
    break;
}
//}while(swModule->Key() <= vk);
}while(element && swModule->Key() <= vk);
}

return ret;
}
*/

- (NSArray *)renderedTextForRef:(NSString *)reference {
    NSMutableArray *ret = [NSMutableArray array];
    
	[moduleLock lock];

    // needed to check for UTF8 string
    //sword::StringMgr *strMgr = sword::StringMgr::getSystemStringMgr();    

    /*
    const char *cref = [reference UTF8String];
    sword::VerseKey	vk;
    sword::ListKey listkey = vk.ParseVerseList(cref, vk, true);
    // for the duration of this query be want the key to persist
    listkey.Persist(true);
    swModule->setKey(listkey);
     */
    /*
    sword::VerseKey key = "par.1.1";
    swModule->setKey(key);
    const char *txt = swModule->RenderText();
     */

    /*
    // iterate through keys
    for ((*swModule) = sword::TOP; !swModule->Error(); (*swModule)++) {
        const char *keyCStr = swModule->getKeyText();
        const char *txtCStr = swModule->RenderText();
        NSString *key = @"";
        NSString *txt = @"";
        txt = [NSString stringWithUTF8String:txtCStr];
        key = [NSString stringWithUTF8String:keyCStr];
        
        // add to dict
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];            
        [dict setObject:txt forKey:SW_OUTPUT_TEXT_KEY];
        [dict setObject:key forKey:SW_OUTPUT_REF_KEY];
        // add to array
        [ret addObject:dict];
    }
    // remove persitent key
    swModule->setKey("gen.1.1");
    */

	sword::VerseKey vk;
    int lastIndex;
	((sword::VerseKey*)(swModule->getKey()))->Headings(1);
	sword::ListKey listkey = vk.ParseVerseList(toUTF8(reference), "Gen1", true);	
	for (int i = 0; i < listkey.Count(); i++) {
		sword::VerseKey *element = My_SWDYNAMIC_CAST(VerseKey, listkey.GetElement(i));
		
		// is it a chapter or book - not atomic
		if(element) {
			swModule->Key(element->LowerBound());            
			// find the upper bound
			vk = element->UpperBound();
			vk.Headings(true);
		} else {
			// set it up
			swModule->Key(*listkey.GetElement(i));
		}
        
		// while not past the upper bound
		do {
			//add verse index to dictionary
            NSString *verse = @"";
            NSString *text = @"";
            const char *keyCStr = swModule->Key().getText();
            const char *txtCStr = swModule->RenderText();
            text = fromUTF8(txtCStr);
            verse = fromUTF8(keyCStr);

            // add to dict
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];            
            [dict setObject:text forKey:SW_OUTPUT_TEXT_KEY];
            [dict setObject:verse forKey:SW_OUTPUT_REF_KEY];
            // add to array
            [ret addObject:dict];

			lastIndex = (swModule->Key()).Index();
			(*swModule)++;
			if(lastIndex == (swModule->Key()).Index())
				break;
		}while (element && swModule->Key() <= vk);
	}

	[moduleLock unlock];

    return ret;
}

- (void)writeEntry:(NSString *)value forRef:(NSString *)reference {
	[moduleLock lock];
	
	sword::ListKey listkey;
	int	i, lastIndex;
	bool havefirst = false;
	sword::VerseKey firstverse;
	sword::VerseKey vk;
	
	listkey = vk.ParseVerseList(toUTF8(reference), "Gen1:1", true);
	
	for (i = 0; i < listkey.Count(); i++) {
		sword::VerseKey *element = My_SWDYNAMIC_CAST(VerseKey, listkey.GetElement(i));
		
		// is it a chapter or book - not atomic
		if(element) {
			// start at lower bound
			swModule->Key(element->LowerBound());
			// find the upper bound
			vk = element->UpperBound();
			vk.Headings();
		} else {
			// set it up
			swModule->Key(*listkey.GetElement(i));
		}
			
		// while not past the upper bound
		do {
			if (!havefirst) {
				havefirst = true;
				firstverse = swModule->Key();
				
				const char	*data;
				int		dLen;
				
				data = toUTF8(value);
				dLen = strlen(data);

				swModule->setEntry(data, dLen);	// save text to module at current position
			} else {
				*(sword::SWModule *)swModule << &firstverse;
			}
			
			lastIndex = (swModule->Key()).Index();
			(*swModule)++;
			if(lastIndex == (swModule->Key()).Index())
				break;
		}while (element && swModule->Key() <= vk);
	}
	
	[moduleLock unlock];
}

@end
