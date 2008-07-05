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

#define BOOKNAMES_KEY       @"BookNames"
#define ENGBOOKNAMES_KEY    @"EngBookNames"
#define BOOKNUMBERS_KEY     @"BookNumbers"

@interface SwordBible (/* Private, class continuation */)
/** private property */
@property(readwrite, retain) NSMutableDictionary *bookData;
- (void)getBookNames;
- (NSNumber *)bookNumberForSWKey:(sword::VerseKey *)key;
@end

@implementation SwordBible

@synthesize bookData;

#pragma mark - class methods
NSLock *bibleLock = nil;

// changes an abbreviated reference into a full
// eg. Dan4:5-7 => Daniel4:5
+ (void)decodeRef:(NSString *)ref intoBook:(NSString **)book chapter:(int *)chapter verse:(int *)verse {
    
	if(!bibleLock) bibleLock = [[NSLock alloc] init];
	[bibleLock lock];
	
	sword::VerseKey vk([ref UTF8String]);
	
	*book = [NSString stringWithUTF8String:vk.getBookName()];
	*chapter = vk.Chapter();
	*verse = vk.Verse();
    
	[bibleLock unlock];
}

+ (NSString *)firstRefName:(NSString *)abbr {
    
	if(!bibleLock) bibleLock = [[NSLock alloc] init];
	[bibleLock lock];
	
	sword::VerseKey vk(toUTF8(abbr));
	NSString *result = fromUTF8(vk);
    
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
        [self setBookData:[NSMutableDictionary dictionary]];
	}
    
	return self;
}

- (void)finalize {
	[super finalize];
}

- (void)getBookNames {
    
	[moduleLock lock];
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
	
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSMutableArray *bookNames = [NSMutableArray array];
	NSMutableArray *engBookNames = [NSMutableArray array];
	NSMutableArray *bookNumbers = [NSMutableArray array];
	currentKey = (sword::VerseKey)swModule->Key();	
	while (!swModule->Key().Error() && currentKey < bottom) {
		currentKey = (sword::VerseKey)swModule->Key();
        const char *cbookn = currentKey.getBookName();
        // bookname and number
        NSString *bookName = @"";
        bookName = [NSString stringWithCString:cbookn encoding:NSUTF8StringEncoding];
        [bookNames addObject:bookName];
        [bookNumbers addObject:[self bookNumberForSWKey:&currentKey]];
        
        // get english bookname
        sword::VerseKey engKey = currentKey;
        engKey.setLocale("en");
        cbookn = engKey.getBookName();
        NSString *engBookName = [NSString stringWithCString:cbookn encoding:NSUTF8StringEncoding];
        [engBookNames addObject:engBookName];            
        
		lastBook = currentKey.Book();
		currentKey.Book(currentKey.Book() + 1 );
		swModule->setKey(currentKey);
	}
	
    // add arrays
    [dict setObject:bookNames forKey:BOOKNAMES_KEY];
    [dict setObject:engBookNames forKey:ENGBOOKNAMES_KEY];
    [dict setObject:bookNumbers forKey:BOOKNUMBERS_KEY];
    self.bookData = dict;
    
    // set back
	swModule->setSkipConsecutiveLinks(skipsLinks);
	
	[moduleLock unlock];    
}

- (NSNumber *)bookNumberForSWKey:(sword::VerseKey *)key {
    return [NSNumber numberWithInt:key->Book() + key->Testament() * 100];
}

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

// just checks whether module contains book atm
- (BOOL)hasReference:(NSString *)ref {
	[moduleLock lock];
	
	sword::VerseKey	*key = (sword::VerseKey *)(swModule->CreateKey());
	(*key) = toUTF8(ref);
	BOOL result = !key->Error() && [[bookData objectForKey:BOOKNUMBERS_KEY] containsObject:[self bookNumberForSWKey:key]];
	
	[moduleLock unlock];
	
	return result;
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
	(*key) = toUTF8(bookName);
	(*key) = sword::MAXCHAPTER;
	maxChapters = key->Chapter();
	delete key;
	
	[moduleLock unlock];
	
	return maxChapters;
}


- (int)versesForChapter:(int)chapter bookName:(NSString *)bookName {

	[moduleLock lock];
	
	int maxVerses = 0;
	sword::VerseKey *key;

	if( chapter < 1 || chapter > [self chaptersForBookName:bookName] ) {
        maxVerses = 0; 
    } else {
        key = (sword::VerseKey *)swModule->CreateKey();
        (*key) = toUTF8(bookName);
        key->Chapter(chapter);
        (*key) = sword::MAXVERSE;
        maxVerses = key->Verse();
        delete key;
	}
	[moduleLock unlock];
	
	return maxVerses;
}

/**
 calculate all verses for this bible book
 */
- (int)versesForBible {

    int ret = 0;
    
    NSArray *books = [bookData objectForKey:BOOKNAMES_KEY];
    int len = [books count];
    for(int i = 0;i < len;i++) {
        // get book name
        NSString *bookName = [books objectAtIndex:i];
        
        // get chapters for book
        int chapters = [self chaptersForBookName:bookName];
        // calculate all verses for this book
        int verses = 0;
        for(int j = 1;j <= chapters;j++) {
            verses += [self versesForChapter:j bookName:bookName];
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
    
    *swModule = sword::TOP;
    unsigned long verseLowIndex = swModule->Index();
    *swModule = sword::BOTTOM;
    unsigned long verseHighIndex = swModule->Index();
    
    return verseHighIndex - verseLowIndex;
}


- (int)htmlForRef:(NSString *)reference html:(NSString **)htmlString {
    int ret = 0;
    
    // result string
    NSMutableString *html = [NSMutableString string];
    
    // get user defaults
    BOOL vool = [userDefaults boolForKey:DefaultsBibleTextVersesOnOneLineKey];
    BOOL showBookNames = [userDefaults boolForKey:DefaultsBibleTextShowBookNameKey];
    BOOL showBookAbbr = [userDefaults boolForKey:DefaultsBibleTextShowBookAbbrKey];

    sword::VerseKey	vk;
    const char *cref = [reference UTF8String];
    sword::ListKey listkey = vk.ParseVerseList(cref , "Gen1", true);
    int lastIndex;
    int lastChapter = -1;
    int lastBook = -1;
    for(int i = 0; i < listkey.Count(); i++) {
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
            swModule->Key(*listkey.GetElement(i));
        }
        
        // while not past the upper bound
        do {
            char *ctxt = (char *)swModule->RenderText();
            int clen = strlen(ctxt);
            
            int book = ((sword::VerseKey)(swModule->Key())).Book();
            int chapter = ((sword::VerseKey)(swModule->Key())).Chapter();
            int verse = ((sword::VerseKey)(swModule->Key())).Verse();
            
            NSString *bookName = @"";
            NSString *bookAbbr = @"";
            NSString *txt = @"";
            if([self isUnicode]) {
                bookName = [NSString stringWithUTF8String:((sword::VerseKey)(swModule->Key())).getBookName()];
                bookAbbr = [NSString stringWithUTF8String:((sword::VerseKey)(swModule->Key())).getBookAbbrev()];
                //NSString *verse = [NSString stringWithUTF8String:swModule->Key().getText()];
                txt = [NSString stringWithUTF8String:ctxt];
            } else {
                bookName = [NSString stringWithCString:((sword::VerseKey)(swModule->Key())).getBookName() encoding:NSISOLatin1StringEncoding];
                bookAbbr = [NSString stringWithCString:((sword::VerseKey)(swModule->Key())).getBookAbbrev() encoding:NSISOLatin1StringEncoding];            
                txt = [NSString stringWithCString:ctxt encoding:NSISOLatin1StringEncoding];
            }

            // generate text according to userdefaults
            if(!vool) {
                // not verses on one line
                // then mark new chapters
                if(chapter != lastChapter) {
                    [html appendFormat:@"<br /><b>%@ - %i:</b><br />\n", bookName, chapter];
                }
                // normal text with verse and text
                [html appendFormat:@"<b>%i<b/> %@ \n", chapter, txt];
            } else {
                if(showBookNames) {
                    [html appendFormat:@"<b>%@ %i:%i:</b> %@<br />\n", bookName, chapter, verse, txt];
                } else if(showBookAbbr) {
                    [html appendFormat:@"<b>%@ %i:%i:</b> %@<br />\n", bookAbbr, chapter, verse, txt];                    
                }
            }
            //[ret appendString:@"<a href=\"strongs://helloStrong\">Strongs</a>\n"];            
            ret++;
            
            // get current index
            lastIndex = (swModule->Key()).Index();
            // increment index
            (*swModule)++;
            // check for index has not changed afer increment
            if(lastIndex == (swModule->Key()).Index()) {
                break;
            }
        }while(element && swModule->Key() <= vk);
    }
    
    // set output
    *htmlString = [NSString stringWithString:html];
    
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
