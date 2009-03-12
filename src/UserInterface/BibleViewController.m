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

@interface BibleViewController (/* class continuation */)

/** selector called by menuitems */
- (void)moduleSelectionChanged:(id)sender;

/** generates HTML for display */
- (NSAttributedString *)displayableHTMLFromVerseData:(NSArray *)verseData;

@end

@implementation BibleViewController

#pragma mark - getter/setter

@synthesize nibName;
@synthesize bookSelection;

- (void)setReference:(NSString *)aReference {
    [super setReference:aReference];
    
    // do additional stuff here
}

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        // some common init
        searchType = ReferenceSearchType;
        self.module = nil;
        self.delegate = nil;
        self.bookSelection = [NSMutableArray array];
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

        // create textview controller
        textViewController = [[ExtTextViewController alloc] initWithDelegate:self];
        
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
    // loading finished
    viewLoaded = YES;
    
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
    
    // set the context menu
    [textViewController setContextMenu:contextMenu];
    
    // create popup button menu
    [self populateModulesMenu];
        
    // populate menu items with modules
    NSMenu *bibleModules = [[NSMenu alloc] init];
    [[SwordManager defaultManager] generateModuleMenu:&bibleModules forModuletype:bible withMenuTarget:self withMenuAction:@selector(lookUpInIndexOfBible:)];
    NSMenuItem *item = [contextMenu itemWithTag:2];
    [item setSubmenu:bibleModules];
    NSMenu *dictModules = [[NSMenu alloc] init];
    [[SwordManager defaultManager] generateModuleMenu:&dictModules forModuletype:dictionary withMenuTarget:self withMenuAction:@selector(lookUpInDictionaryOfModule:)];
    item = [contextMenu itemWithTag:4];
    [item setSubmenu:dictModules];
    
    [self adaptUIToHost];
}

#pragma mark - methods

- (NSView *)listContentView {
    return [entriesOutlineView enclosingScrollView];
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

- (NSTextView *)textView {
    return [textViewController textView];
}

- (NSScrollView *)scrollView {
    return (NSScrollView *)[textViewController scrollView];
}

- (void)setStatusText:(NSString *)aText {
    [statusLine setStringValue:aText];
}

/**
 Searches in index for the given searchQuery.
 Generates NSAttributedString to be displayed in NSTextView
 @param[in] searchQuery
 @param[out] number of verses found
 @return attributed string
 */
- (NSAttributedString *)searchResultStringForQuery:(NSString *)searchQuery numberOfResults:(int *)results {
    NSMutableAttributedString *ret = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    
    NSRange searchRange = NSMakeRange(0, 0);
    long maxResults = 10000;
    
    // get new search results
    Indexer *indexer = [Indexer indexerWithModuleName:[module name] moduleType:[module type]];
    if(indexer == nil) {
        MBLOG(MBLOG_ERR, @"[SwordSearching -searchFor:] Could not get indexer for searching!");
    } else {
        NSArray *tempResults = [indexer performSearchOperation:searchQuery range:searchRange maxResults:maxResults];        
        // close indexer
        [indexer close];
        
        // create out own SortDescriptors according to whome we sort
        NSArray *sortDescriptors = [NSArray arrayWithObject:
                                    [[NSSortDescriptor alloc] initWithKey:@"documentName" 
                                                                ascending:YES 
                                                                 selector:@selector(caseInsensitiveCompare:)]];
        NSArray *sortedSearchResults = [tempResults sortedArrayUsingDescriptors:sortDescriptors];
        // set number of search results for output
        *results = [sortedSearchResults count];
        if(sortedSearchResults) {
            // strip searchQuery
            NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];
            // key attributes
            NSFont *keyFont = [NSFont fontWithName:[NSString stringWithFormat:@"%@ Bold", [userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey]] 
                                              size:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];
            NSMutableDictionary *keyAttributes = [NSMutableDictionary dictionaryWithObject:keyFont forKey:NSFontAttributeName];
            // content font
            NSFont *contentFont = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                                  size:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];            
            NSDictionary *contentAttributes = [NSDictionary dictionaryWithObject:contentFont forKey:NSFontAttributeName];
            // strip binary search tokens
            searchQuery = [NSString stringWithString:[Highlighter stripSearchQuery:searchQuery]];
            // build search string
            for(SearchResultEntry *entry in sortedSearchResults) {                
                // prepare verse URL link
                NSString *keyLink = [NSString stringWithFormat:@"sword://%@/%@", [module name], [entry keyString]];
                NSURL *keyURL = [NSURL URLWithString:[keyLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

                // add attributes
                [keyAttributes setObject:keyURL forKey:NSLinkAttributeName];
                [keyAttributes setObject:[entry keyString] forKey:TEXT_VERSE_MARKER];
                
                // prepare output
                NSAttributedString *keyString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", [entry keyString]] attributes:keyAttributes];
                NSAttributedString *contentString = [Highlighter highlightText:[entry keyContent] forTokens:searchQuery attributes:contentAttributes];
                [ret appendAttributedString:keyString];
                [ret appendAttributedString:contentString];
                [ret appendAttributedString:newLine];
            }
        }
    }
    
    return ret;
}

- (NSAttributedString *)displayableHTMLFromVerseData:(NSArray *)verseData {
    NSMutableAttributedString *ret = nil;

    // some defaults
    // get user defaults
    BOOL showBookNames = [userDefaults boolForKey:DefaultsBibleTextShowBookNameKey];
    BOOL showBookAbbr = [userDefaults boolForKey:DefaultsBibleTextShowBookAbbrKey];
    BOOL vool = [[displayOptions objectForKey:DefaultsBibleTextVersesOnOneLineKey] boolValue];
    
    // generate html string for verses
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start creating HTML string...\n");
    NSMutableString *htmlString = [NSMutableString string];
    int lastChapter = -1;
    for(NSDictionary *dict in verseData) {
        NSString *verseText = [dict objectForKey:SW_OUTPUT_TEXT_KEY];
        NSString *key = [dict objectForKey:SW_OUTPUT_REF_KEY];
                
        NSString *bookName = @"";
        int book = -1;
        int chapter = -1;
        int verse = -1;
        // decode ref
        [SwordBible decodeRef:key intoBook:&bookName book:&book chapter:&chapter verse:&verse];
        
        // the verse link, later we have to add percent escapes
        NSString *verseInfo = [NSString stringWithFormat:@"%@|%i|%i", bookName, chapter, verse];

        // generate text according to userdefaults
        if(!vool) {
            // not verses on one line
            // then mark new chapters
            if(chapter != lastChapter) {
                [htmlString appendFormat:@"<br /><b>%@ - %i:</b><br />\n", bookName, chapter];
            }
            // normal text with verse and text
            [htmlString appendFormat:@";;;%@;;; %@\n", verseInfo, verseText];
        } else {
            [htmlString appendFormat:@";;;%@;;;", verseInfo];
            [htmlString appendFormat:@"%@<br />\n", verseText];
        }
        lastChapter = chapter;
    }
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start creating HTML string...done\n");
    
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start generating attr string...\n");
    // create attributed string
    // setup options
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    // set string encoding
    [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentOption];
    // set web preferences
    [options setObject:[[MBPreferenceController defaultPrefsController] webPreferences] forKey:NSWebPreferencesDocumentOption];
    // set scroll to line height
    NSFont *font = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                   size:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];
    NSFont *fontBold = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayBoldFontFamilyKey] 
                                       size:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];
    [[textViewController scrollView] setLineScroll:[[[textViewController textView] layoutManager] defaultLineHeightForFont:font]];
    // set text
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    ret = [[NSMutableAttributedString alloc] initWithHTML:data 
                                                  options:options
                                       documentAttributes:nil];
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start generating attr string...done\n");
    
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start replacing markers...\n");
    // go through the attributed string and set attributes
    NSRange replaceRange = NSMakeRange(0,0);
    BOOL found = YES;
    NSString *text = [ret string];
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
                
                // prepare verse URL link
                //NSString *verseLink = [NSString stringWithFormat:@"sword://%@/%@", [module name], verseMarker];
                //NSURL *verseURL = [NSURL URLWithString:[verseLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

                // prepare various link usages
                NSString *visible = @"";
                NSRange linkRange;
                linkRange.length = 0;
                linkRange.location = NSNotFound;
                if(showBookNames) {
                    if(vool) {
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
                
                // options
                NSMutableDictionary *markerOpts = [NSMutableDictionary dictionaryWithCapacity:2];
                //[markerOpts setObject:verseURL forKey:NSLinkAttributeName];
                [markerOpts setObject:verseMarker forKey:TEXT_VERSE_MARKER];
                if(fontBold) {
                    [markerOpts setObject:fontBold forKey:NSFontAttributeName];                
                }
                
                // replace string
                [ret replaceCharactersInRange:replaceRange withString:visible];
                // set attributes
                [ret addAttributes:markerOpts range:linkRange];
                
                // adjust replaceRange
                replaceRange.location += [visible length];
            }
        } else {
            found = NO;
        }
    }
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] start replacing markers...done\n");
    
    return ret;
}

- (NSString *)label {
    if(module != nil) {
        return [module name];
    }
    
    return @"BibleView";
}

#pragma mark - protocol implementations

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
            NSString *statusText = @"";
            int verses = 0;
            
            // check cache first
            ReferenceCacheManager *rm = [ReferenceCacheManager defaultCacheManager];
            ReferenceCacheObject *o = [rm cacheObjectForReference:aReference andModuleName:[module name]];
            if(forceRedisplay) {
                o = nil;
            }
            
            if(o != nil) {
                // use cache object
                [textViewController setAttributedString:o.displayText];
                statusText = [NSString stringWithFormat:@"Found %i verses", o.numberOfFinds];
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
                        MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayTextForReference::] numberOfVerseKeys...done");
                    }
                    performProgressCalculation = YES;   // next time we do
                    
                    NSArray *verseData = [module renderedTextForRef:reference];
                    if(verseData == nil) {
                        MBLOG(MBLOG_ERR, @"[BibleViewController -displayTextForReference:] got nil verseData, cannot proceed!");
                        statusText = @"Error on getting verse data!";
                    } else {
                        verses = [verseData count];
                        statusText = [NSString stringWithFormat:@"Found %i verses", verses];

                        // we need html
                        NSAttributedString *attrString = [self displayableHTMLFromVerseData:verseData];
                        
                        // display
                        [textViewController setAttributedString:attrString];
                        
                        // add to cache
                        ReferenceCacheObject *o = [ReferenceCacheObject referenceCacheObjectForModuleName:[module name] 
                                                                                          withDisplayText:attrString
                                                                                            numberOfFinds:verses
                                                                                             andReference:aReference];
                        [rm addCacheObject:o];
                        
                        if(forceRedisplay) {
                            forceRedisplay = NO;
                        }
                    }
                } else if(searchType == IndexSearchType) {
                    MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayTextForReference::] searchtype: Index");

                    // search in index
                    if(![module hasIndex]) {
                        // show progress indicator
                        [self beginIndicateProgress];
                        
                        // create index first if not exists
                        [module createIndex];
                    }
                    
                    // now search
                    int results = 0;
                    NSAttributedString *text = [self searchResultStringForQuery:aReference numberOfResults:&results];
                    statusText = [NSString stringWithFormat:@"Found %i verses", results];
                    // display
                    [textViewController setAttributedString:text];
                    
                    // add to cache
                    ReferenceCacheObject *o = [ReferenceCacheObject referenceCacheObjectForModuleName:[module name] 
                                                                                      withDisplayText:text
                                                                                        numberOfFinds:results
                                                                                         andReference:aReference];
                    [rm addCacheObject:o];
                } else if(searchType == ViewSearchType) {
                    // store found range
                    //NSRange temp = [textViewController rangeOfTextToken:aReference lastFound:viewSearchLastFound directionRight:viewSearchDirectionRight];
                    //if(temp.location != NSNotFound) {
                        // if not visible, scroll to visible
                        /*
                        NSRect rect;
                        if(viewSearchDirectionRight) {
                            rect = [textViewController rectOfLastLine];
                        } else {
                            rect = [textViewController rectOfFirstLine];                        
                        }
                        NSScrollView *scrollView = (NSScrollView *)[textViewController scrollView];
                        [[scrollView contentView] scrollToPoint:rect.origin];
                        // we have to tell the NSScrollView to update its
                        // scrollers
                        [scrollView reflectScrolledClipView:[scrollView contentView]];
                         */
                        // show find indicator
                        //[[textViewController textView] showFindIndicatorForRange:temp];
                    //}
                    //viewSearchLastFound = temp;
                }
            }

            // set status
            [self setStatusText:statusText];

            // stop indicating progress
            [self endIndicateProgress];
        } else {
            MBLOG(MBLOG_WARN, @"[BibleViewController -displayTextForReference:] no module set!");
        }
    }
}

#pragma mark - actions

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

- (IBAction)displayOptionShowStrongs:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_STRONGS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_STRONGS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference searchType:searchType];
}

- (IBAction)displayOptionShowMorphs:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_MORPHS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_MORPHS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference searchType:searchType];
}

- (IBAction)displayOptionShowFootnotes:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_FOOTNOTES];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_FOOTNOTES];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference searchType:searchType];
}

- (IBAction)displayOptionShowCrossRefs:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_SCRIPTREFS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_SCRIPTREFS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference searchType:searchType];
}

- (IBAction)displayOptionShowRedLetterWords:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [modDisplayOptions setObject:SW_OFF forKey:SW_OPTION_REDLETTERWORDS];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [modDisplayOptions setObject:SW_ON forKey:SW_OPTION_REDLETTERWORDS];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference searchType:searchType];
}

- (IBAction)displayOptionVersesOnOneLine:(id)sender {
    if([(NSMenuItem *)sender state] == NSOnState) {
        [displayOptions setObject:[NSNumber numberWithBool:NO] forKey:DefaultsBibleTextVersesOnOneLineKey];
        [(NSMenuItem *)sender setState:NSOffState];
    } else {
        [displayOptions setObject:[NSNumber numberWithBool:YES] forKey:DefaultsBibleTextVersesOnOneLineKey];
        [(NSMenuItem *)sender setState:NSOnState];
    }
    
    // redisplay
    forceRedisplay = YES;
    [self displayTextForReference:reference searchType:searchType];
}

- (IBAction)lookUpInIndex:(id)sender {
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -loopUpInIndex:]");
    
    // get selection
    NSString *sel = [textViewController selectedString];
    if(sel != nil) {
        // if the host is a single view, switch to index and search for the given word
        if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            [(SingleViewHostController *)hostingDelegate setSearchUIType:IndexSearchType searchString:sel];
        } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [(WorkspaceViewHostController *)hostingDelegate setSearchUIType:IndexSearchType searchString:sel];
        }
    }
}

- (IBAction)lookUpInIndexOfBible:(id)sender {
    // sender is the menuitem
    NSMenuItem *item = (NSMenuItem *)sender;
    NSString *modName = [item title];
    SwordModule *mod = [[SwordManager defaultManager] moduleWithName:modName];
    
    // get selection
    NSString *sel = [textViewController selectedString];
    if(sel != nil) {
        if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            // create new single host
            SingleViewHostController *host = [[AppController defaultAppController] openSingleHostWindowForModule:mod];
            [host setSearchUIType:IndexSearchType searchString:sel];
        } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [(WorkspaceViewHostController *)hostingDelegate addTabContentForModule:mod];
            [(WorkspaceViewHostController *)hostingDelegate setSearchUIType:IndexSearchType searchString:sel];
        }
    }
}

- (IBAction)lookUpInDictionary:(id)sender {
    MBLOG(MBLOG_DEBUG, @"[BibleViewController -loopUpInDictionary:]");

    NSString *sel = [textViewController selectedString];
    if(sel != nil) {
        // get default dictionary module
        NSString *defDictName = [userDefaults stringForKey:DefaultsDictionaryModule];
        if(defDictName == nil) {
            // requester to set default dictionary module
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"") 
                                             defaultButton:NSLocalizedString(@"OK" , @"")
                                           alternateButton:nil 
                                               otherButton:nil
                                 informativeTextWithFormat:NSLocalizedString(@"NoDefaultDictionarySelected", @"")];
            [alert runModal];
        } else {
            SwordModule *dict = [[SwordManager defaultManager] moduleWithName:defDictName];
            if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
                SingleViewHostController *host = [[AppController defaultAppController] openSingleHostWindowForModule:dict];
                [host setSearchText:sel];
            } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
                [(WorkspaceViewHostController *)hostingDelegate addTabContentForModule:dict];
                [(WorkspaceViewHostController *)hostingDelegate setSearchText:sel];        
            }            
        }        
    }
}

- (IBAction)lookUpInDictionaryOfModule:(id)sender {
    // sender is the menuitem
    NSMenuItem *item = (NSMenuItem *)sender;
    NSString *modName = [item title];
    SwordModule *mod = [[SwordManager defaultManager] moduleWithName:modName];
    
    // get selection
    NSString *sel = [textViewController selectedString];
    if(sel != nil) {
        if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            SingleViewHostController *host = [[AppController defaultAppController] openSingleHostWindowForModule:mod];
            [host setSearchText:sel];
        } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [(WorkspaceViewHostController *)hostingDelegate addTabContentForModule:mod];
            [(WorkspaceViewHostController *)hostingDelegate setSearchText:sel];        
        }            
    }    
}

#pragma mark - Context Menu validation

/*
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if([menuItem menu] == contextMenu) {
        
    } 
}
 */

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
                        [selRef appendFormat:@"%i; ", [[(SwordBibleChapter *)item number] intValue]];
                    } else {
                        [selRef appendFormat:@"%@ %i; ", [[(SwordBibleChapter *)item book] localizedName], [[(SwordBibleChapter *)item number] intValue]];
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
            ret = [[bb numberOfChapters] intValue];
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
        ret = [[(SwordBibleChapter*)item number] stringValue];
    }
    
    return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    
    if([item isKindOfClass:[SwordBibleBook class]]) {
        SwordBibleBook *bb = item;
        if([[bb numberOfChapters] intValue] > 0) {
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

#pragma mark - mouse tracking protocol

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
        // create textview controller
        textViewController = [[ExtTextViewController alloc] initWithDelegate:self];
        
        self.nibName = [decoder decodeObjectForKey:@"NibNameKey"];
        
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
    
    // encode nib name
    [encoder encodeObject:nibName forKey:@"NibNameKey"];
}

@end
