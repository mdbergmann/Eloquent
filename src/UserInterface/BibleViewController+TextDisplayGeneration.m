//
//  BibleViewController+TextDisplayGeneration.m
//  MacSword2
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "BibleViewController+TextDisplayGeneration.h"
#import "MBPreferenceController.h"
#import "globals.h"
#import "SwordModuleTextEntry.h"
#import "SwordBibleTextEntry.h"
#import "NSUserDefaults+Additions.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SwordBible.h"
#import "SwordSearching.h"
#import "SearchResultEntry.h"
#import "Highlighter.h"
#import "Bookmark.h"
#import "BookmarkManager.h"
#import "SwordVerseKey.h"


@implementation BibleViewController (TextDisplayGeneration)

#pragma mark - HTML generation from search result

- (NSAttributedString *)displayableHTMLForIndexedSearch {
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:@""];
    
    NSArray *searchResults = (NSArray *)[searchContentCache content];
    if(searchResults) {
        NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];
        
        NSFont *normalDisplayFont = [[MBPreferenceController defaultPrefsController] normalDisplayFontForModuleName:[[self module] name]];
        NSFont *boldDisplayFont = [[MBPreferenceController defaultPrefsController] boldDisplayFontForModuleName:[[self module] name]];
        
        NSFont *keyFont = [NSFont fontWithName:[boldDisplayFont familyName]
                                          size:(int)customFontSize];
        NSFont *contentFont = [NSFont fontWithName:[normalDisplayFont familyName] 
                                              size:(int)customFontSize];
        
        NSMutableDictionary *keyAttributes = [NSMutableDictionary dictionaryWithObject:keyFont forKey:NSFontAttributeName];
        NSMutableDictionary *contentAttributes = [NSMutableDictionary dictionaryWithObject:contentFont forKey:NSFontAttributeName];
        [contentAttributes setObject:[userDefaults colorForKey:DefaultsTextForegroundColor] forKey:NSForegroundColorAttributeName];
        
        // strip search tokens
        NSString *searchQuery = [NSString stringWithString:[Highlighter stripSearchQuery:reference]];
        
        for(SearchResultEntry *searchResultEntry in searchResults) {            
            if([searchResultEntry keyString] != nil) {
                NSArray *content = [(SwordBible *)module strippedTextEntriesForRef:[searchResultEntry keyString] context:textContext];
                for(SwordModuleTextEntry *textEntry in content) {
                    // get data
                    NSString *keyStr = [textEntry key];
                    NSString *contentStr = [textEntry text];                    
                    
                    // prepare verse URL link
                    NSString *keyLink = [NSString stringWithFormat:@"sword://%@/%@", [module name], keyStr];
                    NSURL *keyURL = [NSURL URLWithString:[keyLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    // add attributes
                    [keyAttributes setObject:keyURL forKey:NSLinkAttributeName];
                    [keyAttributes setObject:keyStr forKey:TEXT_VERSE_MARKER];
                    
                    // prepare output
                    NSAttributedString *keyString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", keyStr] 
                                                                                    attributes:keyAttributes];
                    NSAttributedString *contentString = nil;
                    if([keyStr isEqualToString:[searchResultEntry keyString]]) {
                        contentString = [Highlighter highlightText:contentStr 
                                                         forTokens:searchQuery 
                                                        attributes:contentAttributes];                        
                    } else {
                        contentString = [[NSAttributedString alloc] initWithString:contentStr attributes:contentAttributes];
                    }
                    [ret appendAttributedString:keyString];
                    [ret appendAttributedString:contentString];
                    [ret appendAttributedString:newLine];
                }
            }                
        }
    }
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -searchResultStringForQuery::] prepare search results...done");
    
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] apply writing direction...");
    [self applyWritingDirectionOnText:ret];
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] apply writing direction...done");
    
    return ret;
}

#pragma mark - HTML generation from verse data

- (NSAttributedString *)displayableHTMLForReferenceLookup {
    NSMutableAttributedString *ret = nil;
    
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start creating HTML string...");
    NSString *htmlString = [self createHTMLStringWithMarkers];
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start creating HTML string...done");
    
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start generating attr string...");
    ret = [self convertToAttributedStringFromString:htmlString];
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start generating attr string...done");
    
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] setting pointing hand cursor...");
    [self applyLinkCursorToLinksInAttributedString:ret];
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] setting pointing hand cursor...done");
    
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start replacing markers...");
    [self replaceVerseMarkersInAttributedString:ret];
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start replacing markers...done");
    
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] apply writing direction...");
    [self applyWritingDirectionOnText:ret];
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] apply writing direction...done");
    
    return ret;
}

- (NSString *)createHTMLStringWithMarkers {
    NSMutableString *htmlString = [NSMutableString string];
    lastChapter = -1;
    lastBook = -1;
    for(SwordBibleTextEntry *entry in (NSArray *)[contentCache content]) {
        [self applyBookmarkHighlightingOnTextEntry:entry];
        [self appendHTMLFromTextEntry:entry atHTMLString:htmlString];
    }
    return htmlString;
}

- (void)applyBookmarkHighlightingOnTextEntry:(SwordBibleTextEntry *)anEntry {
    BOOL isHighlightBookmarks = [[displayOptions objectForKey:DefaultsBibleTextHighlightBookmarksKey] boolValue];
    if(isHighlightBookmarks) {
        Bookmark *bm = [[BookmarkManager defaultManager] bookmarkForReference:[SwordVerseKey verseKeyWithRef:[anEntry key] versification:[module versification]]];
        if(bm && [bm highlight]) {
            float br = 1.0, bg = 1.0, bb = 1.0;
            float fr, fg, fb = 0.0;
            NSColor *bCol = [[bm backgroundColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
            NSColor *fCol = [[bm foregroundColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
            [bCol getRed:&br green:&bg blue:&bb alpha:NULL];
            [fCol getRed:&fr green:&fg blue:&fb alpha:NULL];
            
            // apply colors
            [anEntry setText:
             [NSString stringWithFormat:@"<span style=\"color:rgb(%i%%, %i%%, %i%%); background-color:rgb(%i%%, %i%%, %i%%);\">%@</span>",
              (int)(fr * 100.0), (int)(fg * 100.0), (int)(fb * 100.0),
              (int)(br * 100.0), (int)(bg * 100.0), (int)(bb * 100.0),
              [anEntry text]]];
        }
    }
}

- (void)appendHTMLFromTextEntry:(SwordBibleTextEntry *)anEntry atHTMLString:(NSMutableString *)aString {
    NSString *bookName = @"";
    int book = -1;
    int chapter = -1;
    int verse = -1;
    
    SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[anEntry key] versification:[module versification]];
    bookName = [verseKey bookName];
    book = [verseKey book];
    chapter = [verseKey chapter];
    verse = [verseKey verse];
    
    NSString *verseMarkerInfo = [NSString stringWithFormat:@"%@|%i|%i", bookName, chapter, verse];
    
    BOOL isVersesOnOneLine = [[displayOptions objectForKey:DefaultsBibleTextVersesOnOneLineKey] boolValue];
    BOOL isShowVerseNumbersOnly = [[displayOptions objectForKey:DefaultsBibleTextShowVerseNumberOnlyKey] boolValue];
    
    // book introductions
    SwordBibleBook *bibleBook = (SwordBibleBook *)[(SwordBible *)module bookForLocalizedName:bookName];
    if(book != lastBook) {
        if([[modDisplayOptions objectForKey:SW_OPTION_HEADINGS] isEqualToString:SW_ON]) {
            NSString *bookIntro = [(SwordBible *)module bookIntroductionFor:bibleBook];
            if(bookIntro && [bookIntro length] > 0) {
                [aString appendFormat:@"<p><i><span style=\"color:darkGray\">%@</span></i></p>", bookIntro];
            }
        }        
    }
    
    // pre-verse heading ?
    if([anEntry preverseHeading]) {
        [aString appendFormat:@"<br /><p><i><span style=\"color:darkGray\">%@</span></i></p>", [anEntry preverseHeading]];
    }
    
    // text get marked with ";;;<verseMarkerInfo>;;;" which is replaced later on with a marker
    if(!isVersesOnOneLine) {
        // mark new chapter
        if(chapter != lastChapter) {
            if([[modDisplayOptions objectForKey:SW_OPTION_HEADINGS] isEqualToString:SW_ON]) {
                NSString *chapIntro = [(SwordBible *)module chapterIntroductionFor:bibleBook 
                                                                           chapter:chapter];
                if(chapIntro && [chapIntro length] > 0) {
                    [aString appendFormat:@"<p><i><span style=\"color:darkGray\">%@</span></i></p>", chapIntro];                    
                }
            }
            [aString appendFormat:@"<br /><b>%@ %i:</b><br />\n", bookName, chapter];
        }
        [aString appendFormat:@";;;%@;;; %@\n", verseMarkerInfo, [anEntry text]];   // verse marker
    } else {
        if(chapter != lastChapter) {
            if([[modDisplayOptions objectForKey:SW_OPTION_HEADINGS] isEqualToString:SW_ON]) {
                NSString *chapIntro = [(SwordBible *)module chapterIntroductionFor:bibleBook 
                                                                           chapter:chapter];
                if(chapIntro && [chapIntro length] > 0) {
                    [aString appendFormat:@"<p><i><span style=\"color:darkGray\">%@</span></i></p>", chapIntro];                    
                }
            }
            if(isShowVerseNumbersOnly) {
                ///[aString appendFormat:@"<b>%@ %i:</b><br />\n", bookName, chapter];
            }
        }
        if(verse == 1 && isShowVerseNumbersOnly) {
            if(chapter == 1) {
                [aString appendFormat:@"<b>;;;%@|%i;;;:</b><br />\n<b>;;;%@;;;</b>", bookName, chapter, verseMarkerInfo];    // verse marker
            } else {
                [aString appendFormat:@"<br /><b>;;;%@|%i;;;:</b><br />\n<b>;;;%@;;;</b>", bookName, chapter, verseMarkerInfo];    // verse marker
            }
        } else {
            [aString appendFormat:@"<b>;;;%@;;;</b>", verseMarkerInfo];    // verse marker
        }
        [aString appendFormat:@"%@<br />\n", [anEntry text]];
    }
    
    lastChapter = chapter;
    lastBook = book;
}

- (NSMutableAttributedString *)convertToAttributedStringFromString:(NSString *)aString {
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentOption];
    WebPreferences *webPrefs = [[MBPreferenceController defaultPrefsController] defaultWebPreferencesForModuleName:[[self module] name]];
    [webPrefs setDefaultFontSize:(int)customFontSize];
    [options setObject:webPrefs forKey:NSWebPreferencesDocumentOption];
    
    NSFont *normalDisplayFont = [[MBPreferenceController defaultPrefsController] normalDisplayFontForModuleName:[[self module] name]];
    NSFont *font = [NSFont fontWithName:[normalDisplayFont familyName] 
                                   size:(int)customFontSize];
    [[self scrollView] setLineScroll:[[[self textView] layoutManager] defaultLineHeightForFont:font]];
    NSData *data = [aString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithHTML:data 
                                                                                    options:options
                                                                         documentAttributes:nil];
    [attrString addAttribute:NSForegroundColorAttributeName value:[userDefaults colorForKey:DefaultsTextForegroundColor] 
                       range:NSMakeRange(0, [attrString length])];
    return attrString;
}

- (void)applyLinkCursorToLinksInAttributedString:(NSMutableAttributedString *)anString {
    NSRange effectiveRange;
	int	i = 0;
	while (i < [anString length]) {
        NSDictionary *attrs = [anString attributesAtIndex:i effectiveRange:&effectiveRange];
		if([attrs objectForKey:NSLinkAttributeName] != nil) {
            attrs = [attrs mutableCopy];
            [(NSMutableDictionary *)attrs setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
            [anString setAttributes:attrs range:effectiveRange];
		}
		i += effectiveRange.length;
	}
}

- (void)replaceVerseMarkersInAttributedString:(NSMutableAttributedString *)anAttrString {
    BOOL showBookNames = [userDefaults boolForKey:DefaultsBibleTextShowBookNameKey];
    BOOL showBookAbbr = [userDefaults boolForKey:DefaultsBibleTextShowBookAbbrKey];
    BOOL isVersesOnOneLine = [[displayOptions objectForKey:DefaultsBibleTextVersesOnOneLineKey] boolValue];
    BOOL isShowVerseNumbersOnly = [[displayOptions objectForKey:DefaultsBibleTextShowVerseNumberOnlyKey] boolValue];
    NSRange replaceRange = NSMakeRange(0,0);
    BOOL found = YES;
    NSString *text = [anAttrString string];
    while(found) {
        int tLen = [text length];
        NSRange start = [text rangeOfString:@";;;" options:0 range:NSMakeRange(replaceRange.location, tLen-replaceRange.location)];
        if(start.location != NSNotFound) {
            NSRange stop = [text rangeOfString:@";;;" options:0 range:NSMakeRange(start.location+3, tLen-(start.location+3))];
            if(stop.location != NSNotFound) {
                replaceRange.location = start.location;
                replaceRange.length = stop.location + 3 - start.location;
                
                // create marker
                NSString *marker = [text substringWithRange:NSMakeRange(replaceRange.location + 3, replaceRange.length - 6)];
                
                NSArray *comps = [marker componentsSeparatedByString:@"|"];
                if([comps count] == 2) {         
                    NSString *verseMarker = [NSString stringWithFormat:@"%@ %@", [comps objectAtIndex:0], [comps objectAtIndex:1]];
                    
                    NSRange linkRange;
                    linkRange.length = 9;
                    linkRange.location = replaceRange.location;
                    
                    NSMutableDictionary *markerOpts = [NSMutableDictionary dictionaryWithCapacity:3];
                    [markerOpts setObject:verseMarker forKey:TEXT_VERSE_MARKER];
                    
                    [anAttrString replaceCharactersInRange:replaceRange withString: verseMarker];
                    [anAttrString addAttributes:markerOpts range:linkRange];   
                } else {
                    NSString *verseMarker = [NSString stringWithFormat:@"%@ %@:%@", [comps objectAtIndex:0], [comps objectAtIndex:1], [comps objectAtIndex:2]];
                    
                    NSString *visible = @"";
                    NSRange linkRange;
                    linkRange.length = 0;
                    linkRange.location = NSNotFound;
                    if(showBookNames) {
                        if(isVersesOnOneLine && !isShowVerseNumbersOnly) {
                            visible = [NSString stringWithFormat:@"%@ %@:%@: ", [comps objectAtIndex:0], [comps objectAtIndex:1], [comps objectAtIndex:2]];
                            linkRange.location = replaceRange.location;
                            linkRange.length = [visible length] - 2;                            
                        } else {
                            visible = [NSString stringWithFormat:@"%@ ", [comps objectAtIndex:2]];
                            linkRange.location = replaceRange.location;
                            linkRange.length = [visible length] - 1;
                        }
                    } else if(showBookAbbr) {
                        // TODO: show abbrevation
                    }
                    NSString *verseLink = [NSString stringWithFormat:@"sword://%@/%@", [module name], verseMarker];
                    NSURL *verseURL = [NSURL URLWithString:[verseLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    NSMutableDictionary *markerOpts = [NSMutableDictionary dictionaryWithCapacity:3];
                    [markerOpts setObject:verseMarker forKey:TEXT_VERSE_MARKER];
                    [markerOpts setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
                    [markerOpts setObject:verseURL forKey:NSLinkAttributeName];
                    
                    [anAttrString replaceCharactersInRange:replaceRange withString:visible];
                    [anAttrString addAttributes:markerOpts range:linkRange];
                    
                    replaceRange.location += [visible length];
                }
            }
        } else {
            found = NO;
        }
    }    
}

- (void)applyWritingDirectionOnText:(NSMutableAttributedString *)anAttrString {
    if([module isRTL]) {
        [anAttrString setBaseWritingDirection:NSWritingDirectionRightToLeft range:NSMakeRange(0, [anAttrString length])];
    } else {
        [anAttrString setBaseWritingDirection:NSWritingDirectionNatural range:NSMakeRange(0, [anAttrString length])];
    }    
}

@end
