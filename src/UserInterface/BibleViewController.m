//
//  BibleTextViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 14.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BibleViewController.h"
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

@interface BibleViewController (/* class continuation */)
- (void)populateModulesMenu;

// selector called by menuitems
- (void)moduleSelectionChanged:(id)sender;
@end

@implementation BibleViewController

#pragma mark - getter/setter

- (void)setReference:(NSString *)aReference {
    [super setReference:aReference];
    
    // do additional stuff here
}

#pragma mark - initializers

- (id)init {
    return [self initWithModule:nil delegate:nil];
}

- (id)initWithModule:(SwordBible *)aModule {
    return [self initWithModule:aModule delegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
    return [self initWithModule:nil delegate:aDelegate];
}

- (id)initWithModule:(SwordBible *)aModule delegate:(id)aDelegate {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[BibleViewController -init]");
        self.module = (SwordModule *)aModule;
        self.delegate = aDelegate;
        searchType = ReferenceSearchType;

        // create textview controller
        textViewController = [[ExtTextViewController alloc] initWithDelegate:self];

        // load nib
        BOOL stat = [NSBundle loadNibNamed:BIBLEVIEW_NIBNAME owner:self];
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
    
    // select module
    if(self.module != nil) {
        [modulePopBtn selectItemWithTitle:[module name]];
    }
}

#pragma mark - methods

- (void)populateModulesMenu {
    
    NSMenu *menu = [[NSMenu alloc] init];
    // generate menu
    [[SwordManager defaultManager] generateModuleMenu:&menu 
                                        forModuletype:bible 
                                       withMenuTarget:self 
                                       withMenuAction:@selector(moduleSelectionChanged:)];
    // add menu
    [modulePopBtn setMenu:menu];
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
    long maxResults = [module entryCount];
    
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
            NSDictionary *keyAttributes = [NSDictionary dictionaryWithObject:keyFont forKey:NSFontAttributeName];
            // content font
            NSFont *contentFont = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                              size:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];            
            NSDictionary *contentAttributes = [NSDictionary dictionaryWithObject:contentFont forKey:NSFontAttributeName];
            // strip binary search tokens
            searchQuery = [NSString stringWithString:[Highlighter stripSearchQuery:searchQuery]];
            // build search string
            for(SearchResultEntry *entry in sortedSearchResults) {
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

#pragma mark - protocol implementations

- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType {
    
    searchType = aType;
    
    // in case the this method is called with nil reference, try taking the old one first
    // this is esspecially needed for view search
    if(aReference == nil) {
        aReference = self.reference;
    }
    
    if(aReference != nil) {
        self.reference = aReference;
        
        if(self.module != nil) {
            // start progress indicator
            [progressIndicator startAnimation:self];
            
            NSString *statusText = @"";
            int verses = 0;
            
            // check cache first
            ReferenceCacheManager *rm = [ReferenceCacheManager defaultCacheManager];
            ReferenceCacheObject *o = [rm cacheObjectForReference:aReference andModuleName:[module name]];
            if(o != nil) {
                // use cache object
                [textViewController setAttributedString:o.displayText];
                statusText = [NSString stringWithFormat:@"Found %i verses", o.numberOfFinds];
            } else {
                if(searchType == ReferenceSearchType) {
                    NSString *text = @"";
                    verses = [module htmlForRef:aReference html:&text];
                    statusText = [NSString stringWithFormat:@"Found %i verses", verses];
                    
                    // for debuggin purpose, write html string to somewhere
                    //[text writeToFile:@"/Users/mbergmann/Desktop/module.html" atomically:NO];
                    
                    // create attributed string
                    // setup options
                    NSMutableDictionary *options = [NSMutableDictionary dictionary];
                    // set string encoding
                    [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] 
                                forKey:NSCharacterEncodingDocumentOption];
                    // set web preferences
                    [options setObject:[[MBPreferenceController defaultPrefsController] webPreferences] forKey:NSWebPreferencesDocumentOption];
                    // set scroll to line height
                    NSFont *font = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                                   size:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];
                    [[textViewController scrollView] setLineScroll:[[[textViewController textView] layoutManager] defaultLineHeightForFont:font]];
                    // set text
                    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
                    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTML:data 
                                                                                      options:options
                                                                           documentAttributes:nil];
                    // display
                    [textViewController setAttributedString:attrString];
                    
                    // add to cache
                    ReferenceCacheObject *o = [ReferenceCacheObject referenceCacheObjectForModuleName:[module name] 
                                                                                      withDisplayText:attrString
                                                                                        numberOfFinds:verses
                                                                                         andReference:aReference];
                    [rm addCacheObject:o];
                } else if(searchType == IndexSearchType) {
                    // search in index
                    if(![module hasIndex]) {
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
                    NSRange temp = [textViewController rangeOfTextToken:aReference lastFound:viewSearchLastFound directionRight:viewSearchDirectionRight];
                    if(temp.location != NSNotFound) {
                        // if not visible, scroll to visible
                        //NSScrollView *scrollView = (NSScrollView *)[textViewController scrollView];
                        //NSRect rect = [textViewController rectForTextRange:temp];
                        //[[scrollView contentView] scrollToPoint:rect.origin];
                        // we have to tell the NSScrollView to update its
                        // scrollers
                        //[scrollView reflectScrolledClipView:[scrollView contentView]];
                        // show find indicator
                        [[textViewController textView] showFindIndicatorForRange:temp];
                    }
                    viewSearchLastFound = temp;
                }
            }

            // set status
            [self setStatusText:statusText];
            
            // stop progress indicator
            [progressIndicator stopAnimation:self];        
        } else {
            MBLOG(MBLOG_WARN, @"[BibleViewController -displayTextForReference:] no module set!");
        }
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    // does nothing
}

#pragma mark - actions

- (IBAction)closeButton:(id)sender {
    // send close view to super view
    [self removeFromSuperview];
}

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

#pragma mark - mouse tracking protocol

- (void)mouseEntered:(NSView *)theView {
    MBLOG(MBLOG_DEBUG, @"[BibleViewController - mouseEntered]");
    if(delegate && [delegate respondsToSelector:@selector(mouseEntered:)]) {
        [delegate performSelector:@selector(mouseEntered:) withObject:[self view]];
    }
}

- (void)mouseExited:(NSView *)theView {
    MBLOG(MBLOG_DEBUG, @"[BibleViewController - mouseExited]");
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
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:BIBLEVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BibleViewController -initWithCoder:] unable to load nib!");
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode common things first
    [super encodeWithCoder:encoder];
}

@end
