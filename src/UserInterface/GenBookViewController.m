//
//  GenBookViewController.m
//  MacSword
//
//  Created by Manfred Bergmann on 25.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GenBookViewController.h"
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
#import "SwordBook.h"
#import "IndexingManager.h"

@interface GenBookViewController (/* class continuation */)

@property (retain, readwrite) NSMutableArray *selection;

/** generates HTML for display */
- (NSAttributedString *)displayableHTMLForKeys:(NSArray *)keyArray;
@end

@implementation GenBookViewController

@synthesize selection;

- (id)init {
    self = [super init];
    if(self) {
        // some common init
        searchType = ReferenceSearchType;   // genbook does not have this search type but let's pre-set this
        self.module = nil;
        self.delegate = nil;
        self.selection = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithModule:(SwordBook *)aModule {
    return [self initWithModule:aModule delegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
    return [self initWithModule:nil delegate:aDelegate];
}

- (id)initWithModule:(SwordBook *)aModule delegate:(id)aDelegate {
    self = [self init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[GenBookViewController -init]");
        self.module = (SwordBook *)aModule;
        self.delegate = aDelegate;
                
        // load nib
        BOOL stat = [NSBundle loadNibNamed:GENBOOKVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[GenBookViewController -init] unable to load nib!");
        }        
    } else {
        MBLOG(MBLOG_ERR, @"[GenBookViewController -init] unable init!");
    }
    
    return self;    
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[GenBookViewController -awakeFromNib]");

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

    // if we have areference, display it
    if(reference && [reference length] > 0) {
        [self displayTextForReference:reference searchType:searchType];    
    }

    // loading finished
    viewLoaded = YES;
}

#pragma mark - methods

- (NSView *)listContentView {
    return [entriesOutlineView enclosingScrollView];
}

- (void)adaptUIToHost {
}

- (void)populateModulesMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    // generate menu
    [[SwordManager defaultManager] generateModuleMenu:&menu 
                                        forModuletype:genbook
                                       withMenuTarget:self 
                                       withMenuAction:@selector(moduleSelectionChanged:)];
    // add menu
    [modulePopBtn setMenu:menu];
    
    // select module
    if(self.module != nil) {
        // on change, still exists?
        if(![[SwordManager defaultManager] moduleWithName:[module name]]) {
            // select the first one found
            NSArray *modArray = [[SwordManager defaultManager] modulesForType:SWMOD_CATEGORY_GENBOOKS];
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
    NSMutableAttributedString *ret = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    
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
                NSArray *strippedEntries = [module strippedTextEntriesForRef:[entry keyString]];
                if([strippedEntries count] > 0) {
                    // get content
                    contentStr = [[strippedEntries objectAtIndex:0] text];                    
                }
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
    
    return ret;
}

- (void)displayTextForReference:(NSString *)aReference {
    // there is actually only one search type for GenBooks but we use Reference Search Type
    // to (re-)display the selection
    [self displayTextForReference:aReference searchType:ReferenceSearchType];
    searchType = IndexSearchType;
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

                // refresh outlineview
                [entriesOutlineView reloadData];
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
                        MBLOG(MBLOG_ERR, @"[GenBookViewController -displayTextForReference::] Could not get indexer for searching!");
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
            MBLOG(MBLOG_WARN, @"[GenBookViewController -displayTextForReference:] no module set!");
        }
    }
}

- (NSString *)label {
    if(module != nil) {
        return [module name];
    }
    
    return @"GenBookView";
}

#pragma mark - SubviewHosting

- (void)removeSubview:(HostableViewController *)aViewController {
    // does nothing
}

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOG(MBLOG_DEBUG, @"[GenBookViewController -contentViewInitFinished:]");
    
    // check if this view has completed loading
    if(viewLoaded == YES) {
        // set sync scroll view
        [(ScrollSynchronizableView *)[self view] setSyncScrollView:(NSScrollView *)[textViewController scrollView]];
        [(ScrollSynchronizableView *)[self view] setTextView:[textViewController textView]];
        
        // we have some special setting for the textview
        // it should be allowed to edit images
        [[textViewController textView] setAllowsImageEditing:YES];
        
        // add the webview as contentvew to the placeholder    
        [placeHolderView setContentView:[aView view]];
        [self reportLoadingComplete];
    }
    
    [self adaptUIToHost];
}

#pragma mark - Actions

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
        [entriesOutlineView reloadData];
        
        // set selection
        if((self.reference != nil) && ([self.reference length] > 0)) {
            // redisplay text
            [self displayTextForReference:self.reference searchType:searchType];
        }        
    }
}

#pragma mark - NSOutlineView delegate methods

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	MBLOG(MBLOG_DEBUG,@"[GenBookViewController outlineViewSelectionDidChange:]");
	
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {
            
			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			int len = [selectedRows count];
			NSMutableArray *sel = [NSMutableArray arrayWithCapacity:len];
            SwordTreeEntry *item = nil;
			if(len > 0) {
				unsigned int indexes[len];
				[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
				
				for(int i = 0;i < len;i++) {
                    item = [oview itemAtRow:indexes[i]];
                    
                    // add to array
                    [sel addObject:[item key]];
				}
            }
            
            self.selection = sel;
            [self displayTextForReference:reference];
		} else {
			MBLOG(MBLOG_WARN,@"[GenBookViewController outlineViewSelectionDidChange:] have a nil notification object!");
		}
	} else {
		MBLOG(MBLOG_WARN,@"[GenBookViewController outlineViewSelectionDidChange:] have a nil notification!");
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
    int count = 0;
	
	if(item == nil) {
        SwordTreeEntry *root = [(SwordBook *)module treeEntryForKey:nil];
        count = [[root content] count];
	} else {
        SwordTreeEntry *treeEntry = (SwordTreeEntry *)item;
        count = [[treeEntry content] count];
    }
	
	return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    
    SwordTreeEntry *ret = nil;
    if(item == nil) {
        SwordTreeEntry *treeEntry = [(SwordBook *)module treeEntryForKey:nil];
        NSString *key = [[treeEntry content] objectAtIndex:index];
        ret = [(SwordBook *)module treeEntryForKey:key];
	} else {
        SwordTreeEntry *treeEntry = (SwordTreeEntry *)item;
        NSString *key = [[treeEntry content] objectAtIndex:index];
        ret = [(SwordBook *)module treeEntryForKey:key];
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {    
    SwordTreeEntry *treeEntry = (SwordTreeEntry *)item;    
    if(treeEntry != nil) {
        return [[treeEntry key] lastPathComponent];
    }
    
    return @"test";
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {    
    SwordTreeEntry *treeEntry = (SwordTreeEntry *)item;
    return [[treeEntry content] count] > 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        self.selection = [NSMutableArray array];

        BOOL stat = [NSBundle loadNibNamed:GENBOOKVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[GenBookViewController -initWithCoder:] unable to load nib!");
        }
    }
        
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode common things first
    [super encodeWithCoder:encoder];
}

@end
