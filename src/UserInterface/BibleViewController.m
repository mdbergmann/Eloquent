//
//  BibleTextViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 14.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BibleViewController.h"
#import "AppController.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "BibleCombiViewController.h"
#import "ExtTextViewController.h"
#import "ScrollSynchronizableView.h"
#import "MBPreferenceController.h"
#import "ReferenceCacheManager.h"
#import "ReferenceCacheObject.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SwordSearching.h"
#import "SearchResultEntry.h"
#import "Highlighter.h"
#import "globals.h"
#import "SwordBibleBook.h"
#import "SwordBibleChapter.h"
#import "GradientCell.h"
#import "SearchBookSetEditorController.h"
#import "SearchBookSet.h"
#import "Bookmark.h"
#import "BookmarkManager.h"
#import "SwordVerseKey.h"
#import "IndexingManager.h"

@interface BibleViewController ()

/** selector called by menuitems */
- (void)moduleSelectionChanged:(id)sender;

- (NSAttributedString *)displayableHTMLFromVerseData:(NSArray *)verseData;
- (NSString *)createHTMLStringWithMarkersFromVerseData:(NSArray *)verseData;
- (void)applyBookmarkHighlightingOnTextEntry:(SwordModuleTextEntry *)anEntry;
- (int)appendHTMLFromTextEntry:(SwordModuleTextEntry *)anEntry atHTMLString:(NSMutableString *)aString forChapter:(int)lastChapter;
- (NSMutableAttributedString *)convertToAttributedStringFromString:(NSString *)aString;
- (void)applyLinkCursorToLinksInAttributedString:(NSMutableAttributedString *)anString;
- (void)replaceVerseMarkersInAttributedString:(NSMutableAttributedString *)aAttrString;
- (void)applyWritingDirectionOnText:(NSMutableAttributedString *)anAttrString;

@end

@implementation BibleViewController

#pragma mark - getter/setter

@synthesize nibName;
@synthesize bookSelection;
@synthesize textContext;

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        // some common init
        self.module = nil;
        self.delegate = nil;
        self.bookSelection = [NSMutableArray array];
        self.textContext = 0;
        
        // init SearchBookSetController
        searchBookSetsController = [[SearchBookSetEditorController alloc] init];
        [searchBookSetsController setDelegate:self];
    }
    
    return self;
}

- (id)initWithModule:(SwordBible *)aModule {
    return [self initWithModule:aModule delegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
    return [self initWithModule:nil delegate:aDelegate];
}

- (id)initWithModule:(SwordBible *)aModule delegate:(id)aDelegate {
    self = [self init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[BibleViewController -init]");
        
        // if given module is nil, choose the first found in SwordManager
        if(aModule == nil) {
            NSArray *modArray = [[SwordManager defaultManager] modulesForType:SWMOD_CATEGORY_BIBLES];
            if([modArray count] > 0) {
                aModule = [modArray objectAtIndex:0];
            }
        }
        self.module = (SwordModule *)aModule;
        self.delegate = aDelegate;
                
        self.nibName = BIBLEVIEW_NIBNAME;
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:nibName owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BibleViewController -init] unable to load nib!");            
        }        
    } else {
        MBLOG(MBLOG_ERR, @"[BibleViewController -init] unable init!");
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -awakeFromNib]");
    
    [super awakeFromNib];
        
    // prepare for our custom cell
    gradientCell = [[GradientCell alloc] init];
    NSTableColumn *tableColumn = [entriesOutlineView tableColumnWithIdentifier:@"common"];
    [tableColumn setDataCell:gradientCell];    
    
    // set menu states of display options
    [[displayOptionsMenu itemWithTag:1] setState:[[displayOptions objectForKey:DefaultsBibleTextVersesOnOneLineKey] intValue]];
    
    // if our hosted subview also has loaded, report that
    // else, wait until the subview has loaded and report then
    if(textViewController.viewLoaded == YES) {
        // set sync scroll view
        [(ScrollSynchronizableView *)[self view] setSyncScrollView:(NSScrollView *)[textViewController scrollView]];
        [(ScrollSynchronizableView *)[self view] setTextView:[textViewController textView]];
        
        // add the webview as contentvew to the placeholder    
        [placeHolderView setContentView:[textViewController view]];
        [self reportLoadingComplete];
    }
    
    // create popup button menu
    [self populateModulesMenu];
    [self populateAddPopupMenu];
    
    // populate menu items with modules
    NSMenu *bibleModules = [[NSMenu alloc] init];
    [[SwordManager defaultManager] generateModuleMenu:&bibleModules forModuletype:bible withMenuTarget:self withMenuAction:@selector(lookUpInIndexOfBible:)];
    NSMenuItem *item = [textContextMenu itemWithTag:LookUpInIndexList];
    [item setSubmenu:bibleModules];
    NSMenu *dictModules = [[NSMenu alloc] init];
    [[SwordManager defaultManager] generateModuleMenu:&dictModules forModuletype:dictionary withMenuTarget:self withMenuAction:@selector(lookUpInDictionaryOfModule:)];
    item = [textContextMenu itemWithTag:LookUpInDictionaryList];
    [item setSubmenu:dictModules];

    [self adaptUIToHost];
    
    // if we have areference, display it
    if(reference && [reference length] > 0) {
        [self displayTextForReference:reference searchType:searchType];    
    }

    // loading finished
    viewLoaded = YES;
}

#pragma mark - methods

- (NSView *)listContentView {
    if(searchType == ReferenceSearchType) {
        return [entriesOutlineView enclosingScrollView];    
    } else {
        return [searchBookSetsController view];
    }
}

- (SearchBookSetEditorController *)searchBookSetsController {
    return searchBookSetsController;
}

- (void)adaptUIToHost {
    if(delegate) {
        if([delegate respondsToSelector:@selector(bibleViewCount)]) {
            NSNumber *countTemp = [delegate performSelector:@selector(bibleViewCount)];
            int count = [countTemp intValue];
            if(count == 1) {
                [closeBtn setEnabled:NO];
            } else {
                [closeBtn setEnabled:YES];
            }
        }
    }
}

- (void)populateModulesMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    // generate menu
    [[SwordManager defaultManager] generateModuleMenu:&menu 
                                        forModuletype:bible 
                                       withMenuTarget:self 
                                       withMenuAction:@selector(moduleSelectionChanged:)];
    // add menu
    [modulePopBtn setMenu:menu];
    
    // select module
    if(self.module != nil) {
        // on change, still exists?
        if(![[SwordManager defaultManager] moduleWithName:[module name]]) {
            // select the first one found
            NSArray *modArray = [[SwordManager defaultManager] modulesForType:SWMOD_CATEGORY_BIBLES];
            if([modArray count] > 0) {
                [self setModule:[modArray objectAtIndex:0]];
                // and redisplay if needed
                [self displayTextForReference:[self reference] searchType:searchType];
            }
        }
        
        [modulePopBtn selectItemWithTitle:[module name]];
    }
}

/**
 overriding from super class
 */
- (void)modulesListChanged:(NSNotification *)aNotification {
    [self populateModulesMenu];
    [self populateAddPopupMenu];
}

- (void)populateAddPopupMenu {
    // generate bibles menu
    biblesMenu = [[NSMenu alloc] init];    
    [[SwordManager defaultManager] generateModuleMenu:&biblesMenu 
                                        forModuletype:bible 
                                       withMenuTarget:self 
                                       withMenuAction:@selector(addModule:)];
    
    // generate commentary menu
    commentariesMenu = [[NSMenu alloc] init];    
    [[SwordManager defaultManager] generateModuleMenu:&commentariesMenu 
                                        forModuletype:commentary 
                                       withMenuTarget:self 
                                       withMenuAction:@selector(addModule:)];    
    
    // overall menu
    NSMenu *allMenu = [[NSMenu alloc] init];
    [allMenu addItemWithTitle:@"+" action:nil keyEquivalent:@""];
    NSMenuItem *mi = [allMenu addItemWithTitle:NSLocalizedString(@"Bible", @"") action:nil keyEquivalent:@""];
    [mi setSubmenu:biblesMenu];
    mi = [allMenu addItemWithTitle:NSLocalizedString(@"Commentary", @"") action:nil keyEquivalent:@""];
    [mi setSubmenu:commentariesMenu];
    
    // add menu
    [addPopBtn setMenu:allMenu];
}

- (void)moduleSelectionChanged:(id)sender {
    // get selected modulename
    NSString *name = [(NSMenuItem *)sender title];
    // if different module, then change
    if((self.module == nil) || (![name isEqualToString:[module name]])) {
        // get new module
        self.module = [[SwordManager defaultManager] moduleWithName:name];
        if((self.reference != nil) && ([self.reference length] > 0)) {
            // redisplay text
            [self displayTextForReference:self.reference searchType:searchType];
        }
    }
    
    // reload book entries
    [entriesOutlineView reloadData];
}

- (NSScrollView *)scrollView {
    return (NSScrollView *)[textViewController scrollView];
}

- (void)setStatusText:(NSString *)aText {
    [statusLine setStringValue:aText];
}

- (NSString *)label {
    if(module != nil) {
        return [module name];
    }
    
    return @"BibleView";
}

#pragma mark - HTML generation from search result

- (NSAttributedString *)displayableHTMLFromSearchResults:(NSArray *)tempResults searchQuery:(NSString *)searchQuery numberOfResults:(int *)results {
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:@""];
    
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -searchResultStringForQuery::] prepare search results...");
    // create out own SortDescriptors according to whome we sort
    NSArray *sortDescriptors = [NSArray arrayWithObject:
                                [[NSSortDescriptor alloc] initWithKey:@"documentName" 
                                                            ascending:YES 
                                                             selector:@selector(caseInsensitiveCompare:)]];
    NSArray *sortedSearchResults = [tempResults sortedArrayUsingDescriptors:sortDescriptors];
    NSMutableDictionary *contentAttributes = [NSMutableDictionary dictionary];
    // set number of search results for output
    *results = [sortedSearchResults count];
    if(sortedSearchResults) {
        // strip searchQuery
        NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];
        // key attributes
        NSFont *keyFont = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayBoldFontFamilyKey] 
                                          size:(int)customFontSize];
        NSMutableDictionary *keyAttributes = [NSMutableDictionary dictionaryWithObject:keyFont forKey:NSFontAttributeName];
        // content attributes
        NSFont *contentFont = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                          size:(int)customFontSize];
        [contentAttributes setObject:contentFont forKey:NSFontAttributeName];

        // strip binary search tokens
        searchQuery = [NSString stringWithString:[Highlighter stripSearchQuery:searchQuery]];
        // build search string
        for(SearchResultEntry *entry in sortedSearchResults) {            
            if([entry keyString] != nil) {
                NSArray *content = [(SwordBible *)module strippedTextEntriesForRef:[entry keyString] context:textContext];
                for(SwordModuleTextEntry *entry in content) {
                    // get data
                    NSString *keyStr = [entry key];
                    NSString *contentStr = [entry text];                    

                    // prepare verse URL link
                    NSString *keyLink = [NSString stringWithFormat:@"sword://%@/%@", [module name], keyStr];
                    NSURL *keyURL = [NSURL URLWithString:[keyLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    
                    // add attributes
                    [keyAttributes setObject:keyURL forKey:NSLinkAttributeName];
                    [keyAttributes setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];                
                    [keyAttributes setObject:keyStr forKey:TEXT_VERSE_MARKER];
                    
                    // prepare output
                    NSAttributedString *keyString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", keyStr] attributes:keyAttributes];
                    NSAttributedString *contentString = nil;
                    if([keyStr isEqualToString:[entry keyString]]) {
                        contentString = [Highlighter highlightText:contentStr 
                                                         forTokens:searchQuery 
                                                        attributes:contentAttributes];                        
                    } else {
                        contentString = [[NSAttributedString alloc] initWithString:contentStr];
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

- (NSAttributedString *)displayableHTMLFromVerseData:(NSArray *)verseData {
    NSMutableAttributedString *ret = nil;
        
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start creating HTML string...");
    NSString *htmlString = [self createHTMLStringWithMarkersFromVerseData:verseData];
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

- (NSString *)createHTMLStringWithMarkersFromVerseData:(NSArray *)verseData {
    NSMutableString *htmlString = [NSMutableString string];
    int lastChapter = -1;
    for(SwordModuleTextEntry *entry in verseData) {
        [self applyBookmarkHighlightingOnTextEntry:entry];
        lastChapter = [self appendHTMLFromTextEntry:entry atHTMLString:htmlString forChapter:lastChapter];
    }
    return htmlString;
}

- (void)applyBookmarkHighlightingOnTextEntry:(SwordModuleTextEntry *)anEntry {
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

- (int)appendHTMLFromTextEntry:(SwordModuleTextEntry *)anEntry atHTMLString:(NSMutableString *)aString forChapter:(int)lastChapter {
    NSString *bookName = @"";
    int book = -1;
    int chapter = -1;
    int verse = -1;
    [SwordBible decodeRef:[anEntry key] intoBook:&bookName book:&book chapter:&chapter verse:&verse];
    
    NSString *verseMarkerInfo = [NSString stringWithFormat:@"%@|%i|%i", bookName, chapter, verse];
    
    BOOL isVersesOnOneLine = [[displayOptions objectForKey:DefaultsBibleTextVersesOnOneLineKey] boolValue];
    BOOL isShowVerseNumbersOnly = [[displayOptions objectForKey:DefaultsBibleTextShowVerseNumberOnlyKey] boolValue];
    // text get marked with ";;;<verseMarkerInfo>;;;" which is replaced later on with a marker
    if(!isVersesOnOneLine) {
        // mark new chapter
        if(chapter != lastChapter) {
            [aString appendFormat:@"<br /><b>%@ %i:</b><br />\n", bookName, chapter];
        }
        [aString appendFormat:@";;;%@;;; %@\n", verseMarkerInfo, [anEntry text]];   // verse marker
    } else {
        if(isShowVerseNumbersOnly) {
            if(chapter != lastChapter) {
                [aString appendFormat:@"<br /><b>%@ %i:</b><br />\n", bookName, chapter];
            }                
        }
        [aString appendFormat:@";;;%@;;;", verseMarkerInfo];    // verse marker
        [aString appendFormat:@"%@<br />\n", [anEntry text]];
    }
    
    return chapter;
}

- (NSMutableAttributedString *)convertToAttributedStringFromString:(NSString *)aString {
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentOption];
    WebPreferences *webPrefs = [[MBPreferenceController defaultPrefsController] defaultWebPreferences];
    [webPrefs setDefaultFontSize:(int)customFontSize];
    [options setObject:webPrefs forKey:NSWebPreferencesDocumentOption];
    NSFont *font = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                   size:(int)customFontSize];
    [[textViewController scrollView] setLineScroll:[[[textViewController textView] layoutManager] defaultLineHeightForFont:font]];
    NSData *data = [aString dataUsingEncoding:NSUTF8StringEncoding];

    return [[NSMutableAttributedString alloc] initWithHTML:data 
                                                   options:options
                                        documentAttributes:nil];    
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
    NSFont *fontBold = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayBoldFontFamilyKey] 
                                       size:(int)customFontSize];
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
                
                NSMutableDictionary *markerOpts = [NSMutableDictionary dictionaryWithCapacity:2];
                [markerOpts setObject:verseMarker forKey:TEXT_VERSE_MARKER];
                if(fontBold) {
                    [markerOpts setObject:fontBold forKey:NSFontAttributeName];                
                }
                
                [anAttrString replaceCharactersInRange:replaceRange withString:visible];
                [anAttrString addAttributes:markerOpts range:linkRange];
                
                replaceRange.location += [visible length];
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

#pragma mark - TextDisplayable

- (void)displayTextForReference:(NSString *)aReference {
    [self displayTextForReference:aReference searchType:searchType];
}

- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType {
    
    searchType = aType;
    
    // in case the this method is called with nil reference, try taking the old one first
    if(aReference == nil) {
        aReference = self.reference;
    }
    
    if(aReference != nil && [aReference length] > 0) {
        self.reference = aReference;
        MBLOGV(MBLOG_DEBUG, @"[BibleViewController -displayTextForReference::] searching reference: %@, for module: %@", aReference, [module name]);
        
        if(self.module != nil) {
            NSAttributedString *text = [[NSAttributedString alloc] init];
            NSString *statusText = @"";
            int verses = 0;
            
            // check cache first
            ReferenceCacheManager *rm = [ReferenceCacheManager defaultCacheManager];
            ReferenceCacheObject *o = [rm cacheObjectForReference:aReference forModuleName:[module name] andSearchType:aType];
            if(forceRedisplay) {
                o = nil;
            }
            
            if(o != nil) {
                // use cache object
                text = o.displayText;
                verses = o.numberOfFinds;
            } else {
                if(searchType == ReferenceSearchType) {
                    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayTextForReference::] searchtype: Reference");
                    
                    if(performProgressCalculation) {
                        // in order to show a progress indicator for if the searching takes too long
                        // we need to find out how long it will approximately take
                        MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayTextForReference::] numberOfVerseKeys...");
                        int len = [(SwordBible *)module numberOfVerseKeysForReference:aReference];
                        // let's say that for more then 30 verses we show a progress indicator
                        if(len >= 30) {
                            [self beginIndicateProgress];
                        }
                        performProgressCalculation = YES;   // next time we do
                        MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayTextForReference::] numberOfVerseKeys...done");
                    }
                    
                    // set global display options
                    for(NSString *key in modDisplayOptions) {
                        NSString *val = [modDisplayOptions objectForKey:key];
                        [[SwordManager defaultManager] setGlobalOption:key value:val];
                    }

                    NSArray *verseData = [module renderedTextEntriesForRef:reference];
                    if(verseData == nil) {
                        MBLOG(MBLOG_ERR, @"[BibleViewController -displayTextForReference:] got nil verseData, cannot proceed!");
                        statusText = @"Error on getting verse data!";
                    } else {
                        verses = [verseData count];
                    }

                    // we need html
                    text = [self displayableHTMLFromVerseData:verseData];                        

                } else if(searchType == IndexSearchType) {
                    // search in index
                    if(![module hasIndex]) {
                        // let the user know that we're creating the index now
                        NSString *info = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"IndexBeingCreatedForModule", @""), [module name]];
                        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"IndexNotReady", @"")
                                                         defaultButton:NSLocalizedString(@"OK", @"") alternateButton:nil otherButton:nil 
                                             informativeTextWithFormat:info];
                        [alert runModal];                
                        
                        // show progress indicator
                        // progress indicator is stopped in the delegate methods of either indexing or searching
                        [self beginIndicateProgress];

                        // create index first if not exists
                        [module createIndexThreadedWithDelegate:self];
                    } else {
                        // show progress indicator
                        // progress indicator is stopped in the delegate methods of either indexing or searching
                        [self beginIndicateProgress];

                        // now search
                        SearchBookSet *bookSet = [searchBookSetsController selectedBookSet];
                        long maxResults = 10000;
                        // get new search results
                        indexer = [[IndexingManager sharedManager] indexerForModuleName:[module name] moduleType:[module type]];
                        if(indexer == nil) {
                            MBLOG(MBLOG_ERR, @"[BibleViewController -displayTextForReference::] Could not get indexer for searching!");
                        } else {
                            [indexer performThreadedSearchOperation:aReference constrains:bookSet maxResults:maxResults delegate:self];
                        }                        
                    }
                }
            }
            
            if(forceRedisplay) {
                forceRedisplay = NO;
            } else {
                // add to cache
                if([text length] > 0) {
                    ReferenceCacheObject *o = [ReferenceCacheObject referenceCacheObjectForModuleName:[module name] 
                                                                                      withDisplayText:text
                                                                                        numberOfFinds:verses
                                                                                         andReference:aReference];
                    [rm addCacheObject:o searchType:aType];                    
                }
            }

            // set status
            statusText = [NSString stringWithFormat:@"Found %i verses", verses];                        
            [self setStatusText:statusText];

            // display
            [textViewController setAttributedString:text];                        
            
            if(aType == ReferenceSearchType) {
                // stop indicating progress
                // Indexing is ended in searchOperationFinished:
                [self endIndicateProgress];            
            }
        } else {
            MBLOG(MBLOG_WARN, @"[BibleViewController -displayTextForReference:] no module set!");
        }
    }
}

#pragma mark - actions

- (IBAction)textContextChange:(id)sender {
    [super textContextChange:sender];
    
    // get selected context
    int tag = [(NSPopUpButton *)sender selectedTag];
        
    self.textContext = tag;
    
    // force redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

- (IBAction)addModule:(id)sender {
    NSMenuItem *item = sender;
    
    SwordManager *sm = [SwordManager defaultManager];
    SwordModule *mod = [sm moduleWithName:[item title]];
    if(mod) {
        SEL selector = @selector(addNewCommentViewWithModule:);
        if([item menu] == biblesMenu) {
            selector = @selector(addNewBibleViewWithModule:);
        }

        if(delegate) {
            if([delegate respondsToSelector:selector]) {
                [delegate performSelector:selector withObject:mod];
            }
        }        
    }
}

- (IBAction)closeButton:(id)sender {
    // send close view to super view
    [self removeFromSuperview];
}

- (IBAction)addButton:(id)sender {
    // call delegate and tell to add a new bible view
    if(delegate) {
        if([delegate respondsToSelector:@selector(addNewBibleViewWithModule:)]) {
            [delegate performSelector:@selector(addNewBibleViewWithModule:) withObject:nil];
        }
    }
}

#pragma mark - SubviewHosting

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -contentViewInitFinished:]");
    
    // check if this view has completed loading
    if(viewLoaded == YES) {
        // set sync scroll view
        [(ScrollSynchronizableView *)[self view] setSyncScrollView:(NSScrollView *)[textViewController scrollView]];
        [(ScrollSynchronizableView *)[self view] setTextView:[textViewController textView]];
        
        // add the webview as contentvew to the placeholder    
        [placeHolderView setContentView:[aView view]];
        [self reportLoadingComplete];
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    // does nothing
}

#pragma mark - SearchBookSetEditorController delegate methods

- (void)indexBookSetChanged:(id)sender {
    // if delegate is BibleCombiView, notify about the bookSet change
    if([delegate isKindOfClass:[BibleCombiViewController class]]) {
        [delegate performSelector:@selector(indexBookSetChanged:) withObject:self];
    }
}

#pragma mark - NSOutlineView delegate methods

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	MBLOG(MBLOG_DEBUG,@"[BibleViewController outlineViewSelectionDidChange:]");
	
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {
            
			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			int len = [selectedRows count];
			NSMutableArray *sel = [NSMutableArray arrayWithCapacity:len];
            id item = nil;
			if(len > 0) {
				unsigned int indexes[len];
				[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
				
				for(int i = 0;i < len;i++) {
                    item = [oview itemAtRow:indexes[i]];
                    
                    // add to array
                    [sel addObject:item];
				}
            }
            
            self.bookSelection = sel;
            
            // loop over selection and build reference to display
            BOOL haveBook = NO;
            NSMutableString *selRef = [NSMutableString string];
            for(item in sel) {
                if([item isKindOfClass:[SwordBibleBook class]]) {
                    haveBook = YES;
                    [selRef appendFormat:@"%@ ;", [(SwordBibleBook *)item localizedName]];
                } else if([item isKindOfClass:[SwordBibleChapter class]]) {
                    if(haveBook) {
                        [selRef appendFormat:@"%i; ", [(SwordBibleChapter *)item number]];
                    } else {
                        [selRef appendFormat:@"%@ %i; ", [[(SwordBibleChapter *)item book] localizedName], [(SwordBibleChapter *)item number]];
                    }
                }
            } 
            
            // send the reference to delegate
            if(hostingDelegate) {
                [(WindowHostController *)hostingDelegate setSearchUIType:ReferenceSearchType searchString:selRef];
            }
		} else {
			MBLOG(MBLOG_WARN,@"[BibleViewController outlineViewSelectionDidChange:] have a nil notification object!");
		}
	} else {
		MBLOG(MBLOG_WARN,@"[BibleViewController outlineViewSelectionDidChange:] have a nil notification!");
	}
}

- (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {    
	// display call with std font
	NSFont *font = FontStd;    
	[cell setFont:font];
	//float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
	float pointSize = [font pointSize];
	[aOutlineView setRowHeight:pointSize+4];
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    int ret = 0;
    
    if(item == nil) {
        ret = [[(SwordBible *)module books] count];
    } else {
        if([item isKindOfClass:[SwordBibleBook class]]) {
            SwordBibleBook *bb = item;
            ret = [bb numberOfChapters];
        }
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    id ret = nil;
    
    if(item == nil) {
        ret = [[(SwordBible *)module bookList] objectAtIndex:index];
    } else if([item isKindOfClass:[SwordBibleBook class]]) {
        ret = [[(SwordBibleBook *)item chapters] objectAtIndex:index];
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    NSString *ret = @"";
    
    if([item isKindOfClass:[SwordBibleBook class]]) {
        ret = [(SwordBibleBook *)item localizedName];
    } else if([item isKindOfClass:[SwordBibleChapter class]]) {
        ret = [[NSNumber numberWithInt:[(SwordBibleChapter*)item number]] stringValue];
    }
    
    return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    
    if([item isKindOfClass:[SwordBibleBook class]]) {
        SwordBibleBook *bb = item;
        if([bb numberOfChapters] > 0) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

#pragma mark - MouseTracking protocol

- (void)mouseEntered:(NSView *)theView {
    //MBLOG(MBLOG_DEBUG, @"[BibleViewController - mouseEntered]");
    if(delegate && [delegate respondsToSelector:@selector(mouseEntered:)]) {
        [delegate performSelector:@selector(mouseEntered:) withObject:[self view]];
    }
}

- (void)mouseExited:(NSView *)theView {
    //MBLOG(MBLOG_DEBUG, @"[BibleViewController - mouseExited]");
    if(delegate && [delegate respondsToSelector:@selector(mouseExited:)]) {
        [delegate performSelector:@selector(mouseExited:) withObject:[self view]];
    }
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {        
        self.nibName = [decoder decodeObjectForKey:@"NibNameKey"];        
        self.textContext = [decoder decodeIntegerForKey:@"TextContextKey"];
        
        // init SearchBookSetController
        searchBookSetsController = [[SearchBookSetEditorController alloc] init];
        [searchBookSetsController setDelegate:self];

        // load nib
        BOOL stat = [NSBundle loadNibNamed:nibName owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BibleViewController -initWithCoder:] unable to load nib!");
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode common things first
    [super encodeWithCoder:encoder];
    
    // text display context
    [encoder encodeInteger:textContext forKey:@"TextContextKey"];
    
    // encode nib name
    [encoder encodeObject:nibName forKey:@"NibNameKey"];
}

@end
