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

@interface DictionaryViewController (/* class continuation */)

@property (retain, readwrite) NSMutableArray *selection;

/** modules menu */
- (void)populateModulesMenu;

/** generates HTML for display */
- (NSAttributedString *)displayableHTMLForKeys:(NSArray *)keyArray;
@end

@implementation DictionaryViewController

@synthesize selection;

- (id)init {
    self = [super init];
    if(self) {
        // some common init
        searchType = ReferenceSearchType;
        self.module = nil;
        self.delegate = nil;
        self.selection = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithModule:(SwordDictionary *)aModule {
    return [self initWithModule:aModule delegate:nil];
}

- (id)initWithModule:(SwordDictionary *)aModule delegate:(id)aDelegate {
    self = [self init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[DictionaryViewController -init]");
        self.module = (SwordDictionary *)aModule;
        self.delegate = aDelegate;
        
        // create textview controller
        textViewController = [[ExtTextViewController alloc] initWithDelegate:self];
        
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
    
    // check which delegate we have and en/disable the close button
    [self adaptUIToHost];
}

#pragma mark - methods

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

- (NSAttributedString *)displayableHTMLForKeys:(NSArray *)keyArray {
    NSAttributedString *ret = nil;
    
    // generate html string for verses
    NSMutableString *htmlString = [NSMutableString string];
    for(NSString *key in keyArray) {
        NSArray *result = [self.module renderedTextForRef:key];
        NSString *text = @"";
        if([result count] > 0) {
            text = [[result objectAtIndex:0] objectForKey:SW_OUTPUT_TEXT_KEY];
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
    [options setObject:[[MBPreferenceController defaultPrefsController] webPreferences] forKey:NSWebPreferencesDocumentOption];
    // set scroll to line height
    NSFont *font = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                   size:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];
    [[textViewController scrollView] setLineScroll:[[[textViewController textView] layoutManager] defaultLineHeightForFont:font]];
    // set text
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    ret = [[NSAttributedString alloc] initWithHTML:data 
                                           options:options
                                documentAttributes:nil];
    
    return ret;
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
                NSMutableArray *sel = [NSMutableArray array];
                if([aReference length] > 0) {
                    // collect keys that begin with the entered text
                    for(NSString *key in [(SwordDictionary *)self.module allKeys]) {
                        NSString *subString = [[key substringToIndex:[aReference length]] uppercaseString];
                        if([subString isEqualToString:[aReference uppercaseString]]) {
                            [sel addObject:key];
                        }
                    }                    
                }
                // display
                NSAttributedString *string = [self displayableHTMLForKeys:sel];
                [textViewController setAttributedString:string];
                statusText = [NSString stringWithFormat:@"Displaying %i entries", [sel count]];
            } else if(searchType == IndexSearchType) {
                // search in index
                if(![module hasIndex]) {
                    // create index first if not exists
                    [module createIndex];
                }
                
                // now search
                int results = 0;
                NSAttributedString *text = [self searchResultStringForQuery:aReference numberOfResults:&results];
                statusText = [NSString stringWithFormat:@"Found %i entries", results];
                // display
                [textViewController setAttributedString:text];
            }
            
            // set status
            [self setStatusText:statusText];
        } else {
            MBLOG(MBLOG_WARN, @"[DictionaryViewController -displayTextForReference:] no module set!");
        }
    }
}

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

- (void)moduleSelectionChanged:(id)sender {
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
        if((self.reference != nil) && ([self.reference length] > 0)) {
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
                    item = [[(SwordDictionary *)module allKeys] objectAtIndex:indexes[i]];
                    
                    // add to array
                    [sel addObject:item];
				}
            }
            
            // sert selection
            self.selection = sel;
            
            // re-display
            NSAttributedString *string = [self displayableHTMLForKeys:sel];
            [textViewController setAttributedString:string];
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
        ret = [(SwordDictionary *)self.module entryCount];
    }
    
    return ret;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSString *ret = @"";
    
    if(self.module != nil) {
        ret = [[(SwordDictionary *)self.module allKeys] objectAtIndex:rowIndex];
    }
    
    return ret;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	// display call with std font
	NSFont *font = FontLarge;
	[aCell setFont:font];
	// set row height according to used font
	// get font height
	//float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
	float pointSize = [font pointSize];
	[aTableView setRowHeight:pointSize+6];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        // create textview controller
        textViewController = [[ExtTextViewController alloc] initWithDelegate:self];
        
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
