//
//  DictionaryViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 25.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DictionaryViewController.h"
#import "SingleViewHostController.h"
#import "ExtTextViewController.h"
#import "ScrollSynchronizableView.h"
#import "MBPreferenceController.h"
#import "SearchResultEntry.h"
#import "Highlighter.h"
#import "globals.h"
#import "SwordManager.h"
#import "SwordSearching.h"
#import "SwordModule.h"
#import "SwordDictionary.h"
#import "IndexingManager.h"

@interface DictionaryViewController (/* class continuation */)

@property (retain, readwrite) NSMutableArray *selection;
@property (retain, readwrite) NSArray *dictKeys;

/** generates HTML for display */
- (NSAttributedString *)displayableHTMLForKeys:(NSArray *)keyArray;
@end

@implementation DictionaryViewController

@synthesize selection;
@synthesize dictKeys;

- (id)init {
    self = [super init];
    if(self) {
        // some common init
        self.module = nil;
        self.delegate = nil;
        self.selection = [NSMutableArray array];
        self.dictKeys = [NSArray array];
    }
    
    return self;
}

- (id)initWithModule:(SwordDictionary *)aModule {
    return [self initWithModule:aModule delegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
    return [self initWithModule:nil delegate:aDelegate];
}

- (id)initWithModule:(SwordDictionary *)aModule delegate:(id)aDelegate {
    self = [self init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[DictionaryViewController -init]");
        self.module = (SwordDictionary *)aModule;
        self.delegate = aDelegate;
        
        if(aModule != nil) {
            // set keys
            self.dictKeys = [aModule allKeys];
        }
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:DICTIONARYVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[DictionaryViewController -init] unable to load nib!");
        }        
    } else {
        MBLOG(MBLOG_ERR, @"[DictionaryViewController -init] unable init!");
    }
    
    return self;    
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[DictionaryViewController -awakeFromNib]");
    
    [super awakeFromNib];
    
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
    
    // check which delegate we have and en/disable the close button
    [self adaptUIToHost];
    
    // loading finished
    viewLoaded = YES;
}

#pragma mark - methods

- (NSView *)listContentView {
    return [entriesTableView enclosingScrollView];
}

- (void)adaptUIToHost {
}

- (void)populateModulesMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    // generate menu
    [[SwordManager defaultManager] generateModuleMenu:&menu 
                                        forModuletype:dictionary
                                       withMenuTarget:self 
                                       withMenuAction:@selector(moduleSelectionChanged:)];
    // add menu
    [modulePopBtn setMenu:menu];
    
    // select module
    if(self.module != nil) {
        // on change, still exists?
        if(![[SwordManager defaultManager] moduleWithName:[module name]]) {
            // select the first one found
            NSArray *modArray = [[SwordManager defaultManager] modulesForType:SWMOD_CATEGORY_DICTIONARIES];
            if([modArray count] > 0) {
                [self setModule:[modArray objectAtIndex:0]];
                // and redisplay if needed
                [self displayTextForReference:[self reference] searchType:searchType];
            }
        }
        
        [modulePopBtn selectItemWithTitle:[module name]];
    }
}

- (void)setStatusText:(NSString *)aText {
    [statusLine setStringValue:aText];
}

- (NSAttributedString *)displayableHTMLFromSearchResults:(NSArray *)tempResults searchQuery:(NSString *)searchQuery numberOfResults:(int *)results {
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:@""];
    
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
        NSFont *keyFont = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayBoldFontFamilyKey] 
                                          size:(int)customFontSize];
        NSDictionary *keyAttributes = [NSDictionary dictionaryWithObject:keyFont forKey:NSFontAttributeName];
        // content font
        NSFont *contentFont = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                              size:(int)customFontSize];            
        NSDictionary *contentAttributes = [NSDictionary dictionaryWithObject:contentFont forKey:NSFontAttributeName];
        // strip binary search tokens
        searchQuery = [NSString stringWithString:[Highlighter stripSearchQuery:searchQuery]];
        // build search string
        for(SearchResultEntry *entry in sortedSearchResults) {
            NSAttributedString *keyString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", [entry keyString]] attributes:keyAttributes];
            
            NSString *contentStr = @"";
            if([entry keyString] != nil) {
                contentStr = [(SwordDictionary *)module entryForKey:[entry keyString]];
            }
            
            NSAttributedString *contentString = [Highlighter highlightText:contentStr forTokens:searchQuery attributes:contentAttributes];
            [ret appendAttributedString:keyString];
            [ret appendAttributedString:newLine];
            [ret appendAttributedString:contentString];
            [ret appendAttributedString:newLine];
            [ret appendAttributedString:newLine];
        }
    }
    
    return ret;
}

- (NSAttributedString *)displayableHTMLForKeys:(NSArray *)keyArray {
    NSMutableAttributedString *ret = nil;
    
    if([keyArray count] > 0) {
        // set global display options
        for(NSString *key in modDisplayOptions) {
            NSString *val = [modDisplayOptions objectForKey:key];
            [[SwordManager defaultManager] setGlobalOption:key value:val];
        }
        
        // generate html string for verses
        NSMutableString *htmlString = [NSMutableString string];
        for(NSString *key in keyArray) {
            NSArray *result = [self.module renderedTextEntriesForRef:key];
            NSString *text = @"";
            if([result count] > 0) {
                text = [[result objectAtIndex:0] text];
            }
            [htmlString appendFormat:@"<b>%@:</b><br />", key];
            [htmlString appendFormat:@"%@<br /><br />\n", text];
        }
        
        // create attributed string
        // setup options
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        // set string encoding
        [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] 
                    forKey:NSCharacterEncodingDocumentOption];
        // set web preferences
        WebPreferences *webPrefs = [[MBPreferenceController defaultPrefsController] defaultWebPreferences];
        // set custom font size
        [webPrefs setDefaultFontSize:(int)customFontSize];
        [options setObject:webPrefs forKey:NSWebPreferencesDocumentOption];
        // set scroll to line height
        NSFont *font = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                       size:(int)customFontSize];
        [[textViewController scrollView] setLineScroll:[[[textViewController textView] layoutManager] defaultLineHeightForFont:font]];
        // set text
        NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
        ret = [[NSMutableAttributedString alloc] initWithHTML:data 
                                                      options:options
                                           documentAttributes:nil];
        
        // add pointing hand cursor to all links
        MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] setting pointing hand cursor...");
        NSRange effectiveRange;
        int	i = 0;
        while (i < [ret length]) {
            NSDictionary *attrs = [ret attributesAtIndex:i effectiveRange:&effectiveRange];
            if([attrs objectForKey:NSLinkAttributeName] != nil) {
                // add pointing hand cursor
                attrs = [attrs mutableCopy];
                [(NSMutableDictionary *)attrs setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
                [ret setAttributes:attrs range:effectiveRange];
            }
            i += effectiveRange.length;
        }
        MBLOG(MBLOG_DEBUG, @"[BibleViewController -displayableHTMLFromVerseData:] setting pointing hand cursor...done");        
    } else {
        ret = [[NSMutableAttributedString alloc] init];
    }
    
    return ret;
}

- (void)displayTextForReference:(NSString *)aReference {
    [self displayTextForReference:aReference searchType:searchType];
}

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
            NSString *statusText = @"";
            
            if(searchType == ReferenceSearchType) {

                // re-display
                NSAttributedString *string = [self displayableHTMLForKeys:self.selection];
                [textViewController setAttributedString:string];                
                
                if([aReference length] > 0) {
                    NSMutableArray *sel = [NSMutableArray array];
                    // init Reg ex
                    MBRegex *regex = [MBRegex regexWithPattern:aReference];
                    
                    for(NSString *key in [(SwordDictionary *)module allKeys]) {
                        // try to match
                        [regex setCaseSensitive:NO];
                        if([regex matchIn:key matchResult:nil] == MBRegexMatch) {
                            // add
                            [sel addObject:key];
                        }
                    }
                    self.dictKeys = sel;
                } else {
                    self.dictKeys = [(SwordDictionary *)module allKeys];
                }

                // refresh tableview
                [entriesTableView reloadData];
                
                statusText = [NSString stringWithFormat:@"Showing %i entries out of %i", [dictKeys count], [[(SwordDictionary *)module allKeys] count]];
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
                    indexer = [[IndexingManager sharedManager] indexerForModuleName:[module name] moduleType:[module type]];
                    if(indexer == nil) {
                        MBLOG(MBLOG_ERR, @"[DictionaryViewController -displayTextForReference::] Could not get indexer for searching!");
                    } else {
                        [indexer performThreadedSearchOperation:aReference constrains:nil maxResults:10000 delegate:self];
                    }                    
                }                
            }
            
            // set status
            [self setStatusText:statusText];

            if(aType == ReferenceSearchType) {
                // stop indicating progress
                [self endIndicateProgress];            
            }
        } else {
            MBLOG(MBLOG_WARN, @"[DictionaryViewController -displayTextForReference:] no module set!");
        }
    }
}

- (NSString *)label {
    if(module != nil) {
        return [module name];
    }
    
    return @"DictView";
}

#pragma mark - SubviewHosting

- (void)removeSubview:(HostableViewController *)aViewController {
    // does nothing
}

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOG(MBLOG_DEBUG, @"[DictionaryViewController -contentViewInitFinished:]");
    
    // check if this view has completed loading
    if(viewLoaded == YES) {
        // set sync scroll view
        [(ScrollSynchronizableView *)[self view] setSyncScrollView:(NSScrollView *)[textViewController scrollView]];
        [(ScrollSynchronizableView *)[self view] setTextView:[textViewController textView]];
        
        // add the webview as contentvew to the placeholder    
        [placeHolderView setContentView:[aView view]];
        [self reportLoadingComplete];
    }
    
    [self adaptUIToHost];
}

#pragma mark - actions

- (IBAction)moduleSelectionChanged:(id)sender {
    // get selected modulename
    NSString *name = [(NSMenuItem *)sender title];
    // if different module, then change
    if((self.module == nil) || (![name isEqualToString:[module name]])) {
        // get new module
        self.module = [[SwordManager defaultManager] moduleWithName:name];
        
        // clear selection
        [selection removeAllObjects];
        // reload tableview
        [entriesTableView reloadData];
        
        // set selection
        if(self.reference != nil) {
            // redisplay text
            [self displayTextForReference:self.reference searchType:searchType];
        }        
    }
}

#pragma mark - NSTableView delegate methods

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	MBLOG(MBLOG_DEBUG,@"[DictionaryViewController outlineViewSelectionDidChange:]");
	
	if(aNotification != nil) {
		NSTableView *oview = [aNotification object];
		if(oview != nil) {
            
			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			int len = [selectedRows count];
			NSMutableArray *sel = [NSMutableArray arrayWithCapacity:len];
            NSString *item = nil;
			if(len > 0) {
				unsigned int indexes[len];
				[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
				
				for(int i = 0;i < len;i++) {
                    item = [dictKeys objectAtIndex:indexes[i]];
                    
                    // add to array
                    [sel addObject:item];
				}
            }
            
            // sert selection
            self.selection = sel;
            [self displayTextForReference:reference];
		} else {
			MBLOG(MBLOG_WARN,@"[DictionaryViewController outlineViewSelectionDidChange:] have a nil notification object!");
		}
	} else {
		MBLOG(MBLOG_WARN,@"[DictionaryViewController outlineViewSelectionDidChange:] have a nil notification!");
	}
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    int ret = 0;
    
    if(self.module != nil) {
        ret = [dictKeys count];
    }
    
    return ret;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSString *ret = @"";
    
    if(self.module != nil) {
        ret = [dictKeys objectAtIndex:rowIndex];
    }
    
    return ret;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	// display call with std font
	NSFont *font = FontStd;
	[aCell setFont:font];
	// set row height according to used font
	// get font height
	//float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
	float pointSize = [font pointSize];
	[aTableView setRowHeight:pointSize+4];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        self.selection = [NSMutableArray array];        
        self.dictKeys = [(SwordDictionary *)module allKeys];

        // load nib
        BOOL stat = [NSBundle loadNibNamed:DICTIONARYVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[DictionaryViewController -initWithCoder:] unable to load nib!");
        }
    }
        
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode common things first
    [super encodeWithCoder:encoder];
}

@end
