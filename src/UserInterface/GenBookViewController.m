//
//  GenBookViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 25.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <ObjCSword/ObjCSword.h>
#import "HostableViewController.h"
#import "ContentDisplayingViewController.h"
#import "ModuleCommonsViewController.h"
#import "GenBookViewController.h"
#import "WindowHostController.h"
#import "ScrollSynchronizableView.h"
#import "MBPreferenceController.h"
#import "SearchResultEntry.h"
#import "Highlighter.h"
#import "globals.h"
#import "ModulesUIController.h"
#import "NSUserDefaults+Additions.h"
#import "SearchTextFieldOptions.h"
#import "CacheObject.h"

@interface GenBookViewController (/* class continuation */)

@property (retain, readwrite) NSMutableArray *selection;

- (void)commonInit;

@end

@implementation GenBookViewController

@synthesize selection;

- (id)init {
    self = [super init];
    if(self) {
        self.searchType = IndexSearchType;
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
        self.module = aModule;
        self.delegate = aDelegate;

        [self commonInit];
    } else {
        CocoLog(LEVEL_ERR, @"unable init!");
    }
    
    return self;    
}

- (void)commonInit {
    [super commonInit];
    self.selection = [NSMutableArray array];
    
    BOOL stat = [NSBundle loadNibNamed:GENBOOKVIEW_NIBNAME owner:self];
    if(!stat) {
        CocoLog(LEVEL_ERR, @"unable to load nib!");
    }    
}

- (void)awakeFromNib {
    [super awakeFromNib];
        
    // if our hosted subview also has loaded, report that
    // else, wait until the subview has loaded and report then
    if([(HostableViewController *)contentDisplayController viewLoaded]) {
        [(ScrollSynchronizableView *)[self view] setSyncScrollView:[(id<TextContentProviding>)contentDisplayController scrollView]];
        [(ScrollSynchronizableView *)[self view] setTextView:[(id<TextContentProviding>)contentDisplayController textView]];
        
        [placeHolderView setContentView:[contentDisplayController view]];
        [self reportLoadingComplete];        
    }
    
    if(searchString && [searchString length] > 0) {
        [self displayTextForReference:searchString searchType:searchType];    
    }

    viewLoaded = YES;
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [selection release];

    [super dealloc];
}

#pragma mark - Methods

- (void)populateModulesMenu {
    NSMenu *menu = [[[NSMenu alloc] init] autorelease];
    // generate menu
    [[self modulesUIController] generateModuleMenu:&menu 
                                     forModuletype:Genbook 
                                    withMenuTarget:self 
                                    withMenuAction:@selector(moduleSelectionChanged:)];
    // add menu
    [modulePopBtn setMenu:menu];
    
    // select module
    if(self.module != nil) {
        // on change, still exists?
        if(![[SwordManager defaultManager] moduleWithName:[module name]]) {
            // select the first one found
            NSArray *modArray = [[SwordManager defaultManager] modulesForType:Genbook];
            if([modArray count] > 0) {
                [self setModule:[modArray objectAtIndex:0]];
                // and redisplay if needed
                [self displayTextForReference:searchString searchType:searchType];
            }
        }
        
        [modulePopBtn selectItemWithTitle:[module name]];
    }
}

- (NSAttributedString *)displayableHTMLForIndexedSearchResults:(NSArray *)searchResults {
    NSMutableAttributedString *ret = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    
    if(searchResults) {
        // strip searchQuery
        NSAttributedString *newLine = [[[NSAttributedString alloc] initWithString:@"\n"] autorelease];

        NSFont *normalDisplayFont = [[MBPreferenceController defaultPrefsController] normalDisplayFontForModuleName:[[self module] name]];
        NSFont *boldDisplayFont = [[MBPreferenceController defaultPrefsController] boldDisplayFontForModuleName:[[self module] name]];
        
        NSFont *keyFont = [NSFont fontWithName:[boldDisplayFont familyName]
                                          size:[self customFontSize]];
        NSFont *contentFont = [NSFont fontWithName:[normalDisplayFont familyName] 
                                              size:[self customFontSize]];

        NSDictionary *keyAttributes = [NSDictionary dictionaryWithObject:keyFont forKey:NSFontAttributeName];
        NSMutableDictionary *contentAttributes = [NSMutableDictionary dictionaryWithObject:contentFont forKey:NSFontAttributeName];
        [contentAttributes setObject:[userDefaults colorForKey:DefaultsTextForegroundColor] forKey:NSForegroundColorAttributeName];        
        
        // strip binary search tokens
        NSString *searchQuery = [NSString stringWithString:[Highlighter stripSearchQuery:searchString]];
        
        // build search string
        for(SearchResultEntry *entry in searchResults) {
            NSAttributedString *keyString = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ", [entry keyString]] attributes:keyAttributes] autorelease];
            
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

- (NSAttributedString *)displayableHTMLForReferenceLookup {
    NSMutableString *htmlString = [NSMutableString string];
    NSArray *keyArray = selection;
    [contentCache setCount:[keyArray count]];
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
    WebPreferences *webPrefs = [[MBPreferenceController defaultPrefsController] defaultWebPreferencesForModuleName:[[self module] name]];
    // set custom font size
    [webPrefs setDefaultFontSize:(int)customFontSize];
    [options setObject:webPrefs forKey:NSWebPreferencesDocumentOption];
    
    // set scroll to line height
    NSFont *normalDisplayFont = [[MBPreferenceController defaultPrefsController] normalDisplayFontForModuleName:[[self module] name]];
    NSFont *font = [NSFont fontWithName:[normalDisplayFont familyName] 
                                   size:(int)customFontSize];
    [[(id<TextContentProviding>)contentDisplayController scrollView] setLineScroll:[[[(id<TextContentProviding>)contentDisplayController textView] layoutManager] defaultLineHeightForFont:font]];

    // create text
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    tempDisplayString = [[NSMutableAttributedString alloc] initWithHTML:data 
                                                                options:options
                                                     documentAttributes:nil];
    // set custom fore ground color
    [tempDisplayString addAttribute:NSForegroundColorAttributeName value:[userDefaults colorForKey:DefaultsTextForegroundColor] 
                              range:NSMakeRange(0, [tempDisplayString length])];
    
    // add pointing hand cursor to all links
    CocoLog(LEVEL_DEBUG, @"setting pointing hand cursor...");
    NSRange effectiveRange;
	NSUInteger	i = 0;
	while (i < [tempDisplayString length]) {
        NSDictionary *attrs = [tempDisplayString attributesAtIndex:i effectiveRange:&effectiveRange];
		if([attrs objectForKey:NSLinkAttributeName] != nil) {
            // add pointing hand cursor
            attrs = [[attrs mutableCopy] autorelease];
            [(NSMutableDictionary *)attrs setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
            [tempDisplayString setAttributes:attrs range:effectiveRange];
		}
		i += effectiveRange.length;
	}
    CocoLog(LEVEL_DEBUG, @"setting pointing hand cursor...done");
    
    return tempDisplayString;
}

#pragma mark - TextDisplayable protocol

- (void)displayTextForReference:(NSString *)aReference {
    // there is actually only one search type for GenBooks but we use Reference Search Type
    // to (re-)display the selection
    [self displayTextForReference:aReference searchType:ReferenceSearchType];
    searchType = IndexSearchType;
}

- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType {
    // for index mode the reference must not be an empty string
    // for reference mode we let through everything
    if((aReference && ([aReference length] > 0) && (aType == IndexSearchType)) || 
       aType == ReferenceSearchType) {
        [super displayTextForReference:aReference searchType:aType];
    }
}

- (BOOL)hasValidCacheObject {
    if(searchType == IndexSearchType && [[searchContentCache reference] isEqualToString:searchString]) {
        return YES;
    }
    
    return NO;
}

- (void)handleDisplayForReference {
    [contentCache setReference:searchString];
    [contentCache setContent:[self displayableHTMLForReferenceLookup]];
    
    [entriesOutlineView reloadData];
}

- (void)handleDisplayStatusText {
    [self setStatusText:@""];
}

#pragma mark - HostViewDelegate protocol

- (void)searchStringChanged:(NSString *)aSearchString {    
    self.searchString = aSearchString;
    [self displayTextForReference:searchString searchType:IndexSearchType];
}

- (void)prepareContentForHost:(WindowHostController *)aHostController {
    [super prepareContentForHost:aHostController];
}

- (NSString *)title {
    if(module != nil) {
        return [module name];
    }
    
    return @"GenBookView";
}

- (NSView *)rightAccessoryView {
    return [entriesOutlineView enclosingScrollView];
}

- (BOOL)showsRightSideBar {
    return YES;
}

- (SearchType)preferredSearchType {
    return IndexSearchType;
}

- (SearchTextFieldOptions *)searchFieldOptions {
    SearchTextFieldOptions *options = [[[SearchTextFieldOptions alloc] init] autorelease];
    [options setContinuous:YES];
    [options setSendsSearchStringImmediately:YES];
    [options setSendsWholeSearchString:YES];
    return options;
}

- (BOOL)enableReferenceSearch {
    return NO;
}

- (BOOL)enableIndexedSearch {
    return YES;
}

#pragma mark - SubviewHosting

- (void)removeSubview:(HostableViewController *)aViewController {
    // does nothing
}

- (void)contentViewInitFinished:(HostableViewController *)aView {
    if(viewLoaded == YES) {
        // set sync scroll view
        [(ScrollSynchronizableView *)[self view] setSyncScrollView:[(id<TextContentProviding>)contentDisplayController scrollView]];
        [(ScrollSynchronizableView *)[self view] setTextView:[(id<TextContentProviding>)contentDisplayController textView]];
        
        // we have some special setting for the text view
        // it should be allowed to edit images
        [[(id<TextContentProviding>)contentDisplayController textView] setAllowsImageEditing:YES];
        
        // add the web view as content view to the placeholder
        [placeHolderView setContentView:[aView view]];
        [self reportLoadingComplete];
    }
    
    [self adaptUIToHost];
}

#pragma mark - Actions

- (IBAction)moduleSelectionChanged:(id)sender {
    NSString *name = [(NSMenuItem *)sender title];
    if((self.module == nil) || (![name isEqualToString:[module name]])) {
        self.module = [[SwordManager defaultManager] moduleWithName:name];
        
        [selection removeAllObjects];
        [entriesOutlineView reloadData];
        
        if((self.searchString != nil) && ([self.searchString length] > 0)) {
            forceRedisplay = YES;
            [self displayTextForReference:self.searchString searchType:searchType];
        }        
    }
}

#pragma mark - NSOutlineView delegate methods

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {
            
			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			NSUInteger len = [selectedRows count];
			NSMutableArray *sel = [NSMutableArray arrayWithCapacity:len];
            SwordModuleTreeEntry *item;
			if(len > 0) {
				NSUInteger indexes[len];
				[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
				
				for(int i = 0;i < len;i++) {
                    item = [oview itemAtRow:indexes[i]];
                    [sel addObject:[item key]];
				}
            }
            
            self.selection = sel;
            [self displayTextForReference:searchString];
		} else {
			CocoLog(LEVEL_WARN,@"have a nil notification object!");
		}
	} else {
		CocoLog(LEVEL_WARN,@"have a nil notification!");
	}
}

- (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {    
	// display call with std font
	NSFont *font = FontStd;    
	[cell setFont:font];
	//float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
	CGFloat pointSize = [font pointSize];
	[aOutlineView setRowHeight:pointSize+4];
}


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    int count;
	
	if(item == nil) {
        SwordModuleTreeEntry *root = [(SwordBook *)module treeEntryForKey:nil];
        count = [[root content] count];
	} else {
        SwordModuleTreeEntry *treeEntry = (SwordModuleTreeEntry *)item;
        count = [[treeEntry content] count];
    }
	
	return count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    
    SwordModuleTreeEntry *ret;
    if(item == nil) {
        SwordModuleTreeEntry *treeEntry = [(SwordBook *)module treeEntryForKey:nil];
        NSString *key = [[treeEntry content] objectAtIndex:(NSUInteger)index];
        ret = [(SwordBook *)module treeEntryForKey:key];
	} else {
        SwordModuleTreeEntry *treeEntry = (SwordModuleTreeEntry *)item;
        NSString *key = [[treeEntry content] objectAtIndex:(NSUInteger)index];
        ret = [(SwordBook *)module treeEntryForKey:key];
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {    
    SwordModuleTreeEntry *treeEntry = (SwordModuleTreeEntry *)item;    
    if(treeEntry != nil) {
        return [[treeEntry key] lastPathComponent];
    }
    
    return @"test";
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {    
    SwordModuleTreeEntry *treeEntry = (SwordModuleTreeEntry *)item;
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
        [self commonInit];
    }
        
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
}

@end
