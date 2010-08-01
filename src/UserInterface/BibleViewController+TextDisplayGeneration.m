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
#import "ObjCSword/SwordModuleTextEntry.h"
#import "ObjCSword/SwordBibleTextEntry.h"
#import "NSUserDefaults+Additions.h"
#import "ObjCSword/SwordManager.h"
#import "ObjCSword/SwordModule.h"
#import "ObjCSword/SwordBible.h"
#import "SearchResultEntry.h"
#import "Highlighter.h"
#import "Bookmark.h"
#import "BookmarkManager.h"
#import "ObjCSword/SwordVerseKey.h"
#import "ObjCSword/SwordListKey.h"

@implementation BibleViewController (TextDisplayGeneration)

#pragma mark - HTML generation from search result

- (NSAttributedString *)displayableHTMLForIndexedSearchResults:(NSArray *)searchResults {
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:@""];
    
    if(searchResults && [searchResults count] > 0) {
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
        NSString *searchQuery = [NSString stringWithString:[Highlighter stripSearchQuery:searchString]];
        
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

        CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForIndexedSearch:] apply writing direction...");
        [self applyWritingDirection];
        CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForIndexedSearch:] apply writing direction...done");
    }
    CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForIndexedSearch::] prepare search results...done");
        
    return ret;
}

#pragma mark - HTML generation from verse data

- (NSAttributedString *)displayableHTMLForReferenceLookup {

    CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForReferenceLookup:] start creating HTML string...");
    NSString *htmlString = [self createHTMLStringWithMarkers];
    CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForReferenceLookup:] start creating HTML string...done");
    
    CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForReferenceLookup:] start generating attr string...");
    [self applyString:htmlString];
    CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForReferenceLookup:] start generating attr string...done");
    
    CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForReferenceLookup:] setting pointing hand cursor...");
    [self applyLinkCursorToLinks];
    CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForReferenceLookup:] setting pointing hand cursor...done");
    
    CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForReferenceLookup:] start replacing markers...");
    [self replaceVerseMarkers];
    CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForReferenceLookup:] start replacing markers...done");
    
    CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForReferenceLookup:] apply writing direction...");
    [self applyWritingDirection];
    CocoLog(LEVEL_DEBUG, @"[BibleViewController -displayableHTMLForReferenceLookup:] apply writing direction...done");        
    
    return tempDisplayString;
}

- (NSString *)createHTMLStringWithMarkers {
    
    NSMutableString *htmlString = [NSMutableString string];
    // background color cannot be set this way
    CGFloat fr, fg, fb = 0.0;
    NSColor *fCol = [userDefaults colorForKey:DefaultsTextForegroundColor];
    [fCol getRed:&fr green:&fg blue:&fb alpha:NULL];
    [htmlString appendFormat:@"\
     <style>\
     body {\
        color:rgb(%i%%, %i%%, %i%%);\
     }\
     </style>\n", 
     (int)(fr * 100.0), (int)(fg * 100.0), (int)(fb * 100.0)];
         

    lastChapter = -1;
    lastBook = -1;
        
    [module lockModuleAccess];
    SwordManager *swManager = [SwordManager defaultManager];
    BOOL collectPreverseHeading = ([swManager globalOption:SW_OPTION_HEADINGS] && [module hasFeature:SWMOD_FEATURE_HEADINGS]);
    
    SwordListKey *lk = [SwordListKey listKeyWithRef:searchString v11n:[module versification]];    
    [lk setPersist:NO];
    [lk setPosition:SWPOS_TOP];
    NSString *ref = nil;
    NSString *rendered = nil;
    SwordBibleTextEntry *entry = nil;
    int numberOfVerses = 0;
    while(![lk error]) {
        ref = [lk keyText];
        [module setKey:lk];
        rendered = [module renderedText];
        entry = [SwordBibleTextEntry textEntryForKey:ref andText:rendered];

        if(collectPreverseHeading) {
            NSString *preverseHeading = [module entryAttributeValuePreverse];
            if(preverseHeading && [preverseHeading length] > 0) {
                [entry setPreverseHeading:preverseHeading];
            }
        }        
        
        [self applyBookmarkHighlightingOnTextEntry:entry];
        [self appendHTMLFromTextEntry:entry atHTMLString:htmlString];
        
        [lk increment];
        numberOfVerses++;
    }
    [module unlockModuleAccess];
    [contentCache setCount:numberOfVerses];
    
    return htmlString;
}

- (void)applyBookmarkHighlightingOnTextEntry:(SwordBibleTextEntry *)anEntry {
    BOOL isHighlightBookmarks = [[displayOptions objectForKey:DefaultsBibleTextHighlightBookmarksKey] boolValue];
    if(isHighlightBookmarks) {
        Bookmark *bm = [[BookmarkManager defaultManager] bookmarkForReference:[SwordVerseKey verseKeyWithRef:[anEntry key]]];
        if(bm && [bm highlight]) {
            CGFloat br = 1.0, bg = 1.0, bb = 1.0;
            CGFloat fr, fg, fb = 0.0;
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
    
    SwordVerseKey *verseKey = [SwordVerseKey verseKeyWithRef:[anEntry key] v11n:[module versification]];
    bookName = [verseKey bookName];
    book = [verseKey book];
    chapter = [verseKey chapter];
    verse = [verseKey verse];
    
    NSString *verseMarkerInfo = [NSString stringWithFormat:@"%@|%i|%i", bookName, chapter, verse];
    
    BOOL isVersesOnOneLine = [[displayOptions objectForKey:DefaultsBibleTextVersesOnOneLineKey] boolValue];
    VerseNumberingType verseNumbering = [[displayOptions objectForKey:DefaultsBibleTextVerseNumberingTypeKey] intValue];
    BOOL isShowVerseNumbersOnly = (verseNumbering == VerseNumbersOnly);
    BOOL isShowFullVerseNumbering = (verseNumbering == FullVerseNumbering);
    BOOL isShowVerseNumbering = (verseNumbering == NoVerseNumbering);
    
    // headings fg color
    CGFloat hr, hg, hb = 0.0;
    NSColor *hfCol = [userDefaults colorForKey:DefaultsHeadingsForegroundColor];
    [hfCol getRed:&hr green:&hg blue:&hb alpha:NULL];    
    NSString *headingsFGColorStyle = [NSString stringWithFormat:@"color:rgb(%i%%, %i%%, %i%%);",
      (int)(hr * 100.0), (int)(hg * 100.0), (int)(hb * 100.0)];
    
    // book introductions
    SwordBibleBook *bibleBook = (SwordBibleBook *)[(SwordBible *)module bookForLocalizedName:bookName];
    if(book != lastBook) {
        if([[modDisplayOptions objectForKey:SW_OPTION_HEADINGS] isEqualToString:SW_ON]) {
            NSString *bookIntro = [(SwordBible *)module bookIntroductionFor:bibleBook];
            if(bookIntro && [bookIntro length] > 0) {
                [aString appendFormat:@"<p><i><span style=\"%@\">%@</span></i></p>", headingsFGColorStyle, bookIntro];
            }
        }        
    }
    
    // pre-verse heading ?
    if([anEntry preverseHeading]) {
        [aString appendFormat:@"<br /><p><i><span style=\"%@\">%@</span></i></p>", headingsFGColorStyle, [anEntry preverseHeading]];
    }
    
    // text get marked with ";;;<verseMarkerInfo>;;;" which is replaced later on with a marker
    if(!isVersesOnOneLine) {
        // new chapter or same chapter in another book
        if((chapter != lastChapter) || (book != lastBook)) {
            if([[modDisplayOptions objectForKey:SW_OPTION_HEADINGS] isEqualToString:SW_ON]) {
                NSString *chapIntro = [(SwordBible *)module chapterIntroductionFor:bibleBook 
                                                                           chapter:chapter];
                if(chapIntro && [chapIntro length] > 0) {
                    [aString appendFormat:@"<p><i><span style=\"%@\">%@</span></i></p>", headingsFGColorStyle, chapIntro];                    
                }
            }
            [aString appendFormat:@"<br /><b>%@ %i:</b><br />\n", bookName, chapter];
        }
        [aString appendFormat:@";;;%@;;; %@\n", verseMarkerInfo, [anEntry text]];   // verse marker
    } else {
        // new chapter or same chapter in another book
        if((chapter != lastChapter) || (book != lastBook)) {
            if([[modDisplayOptions objectForKey:SW_OPTION_HEADINGS] isEqualToString:SW_ON]) {
                NSString *chapIntro = [(SwordBible *)module chapterIntroductionFor:bibleBook 
                                                                           chapter:chapter];
                if(chapIntro && [chapIntro length] > 0) {
                    [aString appendFormat:@"<p><i><span style=\"%@\">%@</span></i></p>", headingsFGColorStyle, chapIntro];                    
                }
            }
            if(isShowVerseNumbersOnly) {
                if(chapter == 1) {
                    [aString appendFormat:@"<b>%@ %i:</b><br />\n", bookName, chapter];
                } else {
                    [aString appendFormat:@"<br /><b>%@ %i:</b><br />\n", bookName, chapter];
                }
            }
        }
        [aString appendFormat:@"<b>;;;%@;;;</b>", verseMarkerInfo];    // verse marker
        // the actual verse text
        [aString appendFormat:@"%@<br />\n", [anEntry text]];
    }
    
    lastChapter = chapter;
    lastBook = book;
}

- (void)applyString:(NSString *)aString {
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentOption];
    WebPreferences *webPrefs = [[MBPreferenceController defaultPrefsController] defaultWebPreferencesForModuleName:[[self module] name]];
    [webPrefs setDefaultFontSize:(int)customFontSize];
    [options setObject:webPrefs forKey:NSWebPreferencesDocumentOption];
    
    NSFont *normalDisplayFont = [[MBPreferenceController defaultPrefsController] normalDisplayFontForModuleName:[[self module] name]];
    NSFont *font = [NSFont fontWithName:[normalDisplayFont familyName] 
                                   size:(int)customFontSize];

    NSData *data = [aString dataUsingEncoding:NSUTF8StringEncoding];
    tempDisplayString = [[NSMutableAttributedString alloc] initWithHTML:data 
                                                                options:options
                                                     documentAttributes:nil];

    [[self scrollView] setLineScroll:[[[self textView] layoutManager] defaultLineHeightForFont:font]];
}

- (void)applyLinkCursorToLinks {    
    NSRange effectiveRange;
	int	i = 0;
	while (i < [tempDisplayString length]) {
        NSDictionary *attrs = [tempDisplayString attributesAtIndex:i effectiveRange:&effectiveRange];
		if([attrs objectForKey:NSLinkAttributeName] != nil) {
            attrs = [attrs mutableCopy];
            [(NSMutableDictionary *)attrs setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
            [tempDisplayString setAttributes:attrs range:effectiveRange];
		}
		i += effectiveRange.length;
	}
}

- (void)replaceVerseMarkers {    
    BOOL showBookNames = [userDefaults boolForKey:DefaultsBibleTextShowBookNameKey];
    BOOL showBookAbbr = [userDefaults boolForKey:DefaultsBibleTextShowBookAbbrKey];
    BOOL isVersesOnOneLine = [[displayOptions objectForKey:DefaultsBibleTextVersesOnOneLineKey] boolValue];
    VerseNumberingType verseNumbering = [[displayOptions objectForKey:DefaultsBibleTextVerseNumberingTypeKey] intValue];
    BOOL isShowVerseNumbersOnly = (verseNumbering == VerseNumbersOnly);
    BOOL isShowFullVerseNumbering = (verseNumbering == FullVerseNumbering);
    BOOL isShowVerseNumbering = (verseNumbering == NoVerseNumbering);
    
    NSRange replaceRange = NSMakeRange(0,0);
    BOOL found = YES;
    NSString *text = [tempDisplayString string];
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
                    
                    [tempDisplayString replaceCharactersInRange:replaceRange withString:verseMarker];
                    [tempDisplayString addAttributes:markerOpts range:linkRange];   
                } else {
                    NSString *verseMarker = [NSString stringWithFormat:@"%@ %@:%@", [comps objectAtIndex:0], [comps objectAtIndex:1], [comps objectAtIndex:2]];
                    
                    NSString *visible = @"";
                    NSRange linkRange;
                    linkRange.length = 0;
                    linkRange.location = NSNotFound;
                    if(showBookNames) {
                        if(isVersesOnOneLine && isShowFullVerseNumbering) {
                            visible = [NSString stringWithFormat:@"%@ %@:%@: ", [comps objectAtIndex:0], [comps objectAtIndex:1], [comps objectAtIndex:2]];
                            linkRange.location = replaceRange.location;
                            linkRange.length = [visible length] - 2;                            
                        } else if((isVersesOnOneLine && isShowVerseNumbersOnly) || isShowVerseNumbersOnly) {
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
                    
                    [tempDisplayString replaceCharactersInRange:replaceRange withString:visible];
                    [tempDisplayString addAttributes:markerOpts range:linkRange];
                    
                    replaceRange.location += [visible length];
                }
            }
        } else {
            found = NO;
        }
    }    
}

- (void)applyWritingDirection {
    if([module isRTL]) {
        [tempDisplayString setBaseWritingDirection:NSWritingDirectionRightToLeft range:NSMakeRange(0, [tempDisplayString length])];
    } else {
        [tempDisplayString setBaseWritingDirection:NSWritingDirectionNatural range:NSMakeRange(0, [tempDisplayString length])];
    }    
}

@end
