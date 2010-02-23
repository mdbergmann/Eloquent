//
//  ModuleViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ModuleViewController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "SwordManager.h"
#import "AppController.h"
#import "ExtTextViewController.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "BibleCombiViewController.h"
#import "IndexingManager.h"
#import "SwordModuleTextEntry.h"
#import "ReferenceCacheManager.h"
#import "ReferenceCacheObject.h"
#import "NSTextView+LookupAdditions.h"
#import "CacheObject.h"
#import "SwordSearching.h"

@interface ModuleViewController () 

/** notification, called when modules have changed */
- (void)modulesListChanged:(NSNotification *)aNotification;
- (void)updateContentCache;

@end

@implementation ModuleViewController

#pragma mark - getter/setter

@synthesize module;
@synthesize performProgressCalculation;
@synthesize searchContentCache;

#pragma mark - Initializers

- (id)init {
    self = [super init];
    if(self) {
    }
    
    return self;
}

- (void)commonInit {
    [super commonInit];
    performProgressCalculation = YES;
    forceRedisplay = NO;
    searchType = ReferenceSearchType;
    
    self.searchContentCache = [[CacheObject alloc] init];
    contentDisplayController = [[ExtTextViewController alloc] initWithDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(modulesListChanged:)
                                                 name:NotificationModulesChanged object:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // add custom menu Additions
    [textContextMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *mi = [textContextMenu addItemWithTitle:NSLocalizedString(@"ShowModuleAbout", @"") action:@selector(displayModuleAbout:) keyEquivalent:@""];
    [mi setTarget:self];
    [mi setTag:ShowModuleAbout];

    [linkContextMenu addItem:[NSMenuItem separatorItem]];
    mi = [linkContextMenu addItemWithTitle:NSLocalizedString(@"ShowModuleAbout", @"") action:@selector(displayModuleAbout:) keyEquivalent:@""];
    [mi setTarget:self];
    [mi setTag:ShowModuleAbout];

    [imageContextMenu addItem:[NSMenuItem separatorItem]];
    mi = [imageContextMenu addItemWithTitle:NSLocalizedString(@"ShowModuleAbout", @"") action:@selector(displayModuleAbout:) keyEquivalent:@""];
    [mi setTarget:self];
    [mi setTag:ShowModuleAbout];
 }

#pragma mark - Methods

/** notification, called when modules have changed */
- (void)modulesListChanged:(NSNotification *)aNotification {
    [self populateModulesMenu];
}

- (void)populateModulesMenu {
    // subclass will handle
}

- (void)setStatusText:(NSString *)aText {
    // subclass will handle
}

/**
 Generates NSAttributedString from cached search results
 this is an abstract method, should be overriden by subclasses
 @return attributed string
 */
- (NSAttributedString *)displayableHTMLForIndexedSearch {
    return nil;
}

- (NSAttributedString *)displayableHTMLForReferenceLookup {
    return nil;
}

#pragma mark - Indexer delegate method

- (void)searchOperationFinished:(NSArray *)results {
    if(indexer) {
        [[IndexingManager sharedManager] closeIndexer:indexer];
    }
    
    int resultsCount = 0;
    NSAttributedString *text = nil;
    if(results) {
        resultsCount = [results count];
        NSArray *sortDescriptors = [NSArray arrayWithObject:
                                    [[NSSortDescriptor alloc] initWithKey:@"documentName" 
                                                                ascending:YES 
                                                                 selector:@selector(caseInsensitiveCompare:)]];
        [searchContentCache setContent:[results sortedArrayUsingDescriptors:sortDescriptors]];
        text = [self displayableHTMLForIndexedSearch];        
        [self setStatusText:[NSString stringWithFormat:@"Found %i results", resultsCount]];
    }
    
    if(text) {
        [self setAttributedString:text];     
    }
    
    [self endIndicateProgress];    
}

- (void)indexCreationFinished:(SwordModule *)mod {
    [self endIndicateProgress];
    
    // I guess the user actually wanted to search for something
    // let's do this now
    [self displayTextForReference:searchString];
}

#pragma mark - TextContentProviding

- (NSTextView *)textView {
    return (NSTextView *)[(<TextContentProviding>)contentDisplayController textView];    
}

- (NSScrollView *)scrollView {
    return (NSScrollView *)[(<TextContentProviding>)contentDisplayController scrollView];    
}

- (void)setAttributedString:(NSAttributedString *)aString {
    [(<TextContentProviding>)contentDisplayController setAttributedString:aString];
}

- (void)setString:(NSString *)aString {
    [(<TextContentProviding>)contentDisplayController setString:aString];
}

- (void)textChanged:(NSNotification *)aNotification {}

#pragma mark - Printing

- (NSView *)printViewForInfo:(NSPrintInfo *)printInfo {
    // paper size
    NSSize paperSize = [printInfo paperSize];
    
    // set print size
    NSSize printSize = NSMakeSize(paperSize.width - ([printInfo leftMargin] + [printInfo rightMargin]), 
                                  paperSize.height - ([printInfo topMargin] + [printInfo bottomMargin]));
    
    // create print view
    NSTextView *printView = [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, printSize.width, printSize.height)];
    [printView insertText:[[self textView] attributedString]];
    
    return printView;
}

#pragma mark - TextDisplayable

- (void)displayTextForReference:(NSString *)aReference {
    [self displayTextForReference:aReference searchType:searchType];
}

- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType {
    searchType = aType;
    
    if(aReference == nil || module == nil) {
        return;
    }    
    if([aReference length] == 0) {
        [self setStatusText:@""];
        [self setString:@""];
    }
    
    self.searchString = aReference;
    if(![self hasValidCacheObject] || forceRedisplay) {
        if(searchType == ReferenceSearchType) {
            [self setGlobalOptionsFromModOptions];
            [self handleDisplayForReference];
        } else if(searchType == IndexSearchType) {
            [searchContentCache setReference:searchString];
            if(![module hasIndex]) {
                [self handleDisplayIndexedNoHasIndex];
            } else {
                [self handleDisplayIndexedPerformSearch];
            }
        }        
    }
    
    forceRedisplay = NO;
    
    [self handleDisplayCached];
    [self handleDisplayStatusText];
    
    if(aType == ReferenceSearchType) {
        // stop indicating progress
        // Indexing is ended in searchOperationFinished:
        [self endIndicateProgress];
    }
}

- (BOOL)hasValidCacheObject {
    if((searchType == ReferenceSearchType && [[contentCache reference] isEqualToString:searchString]) ||
       (searchType == IndexSearchType && [[searchContentCache reference] isEqualToString:searchString])) {
        return YES;
    }
    return NO;
}

- (void)handleDisplayForReference {
    [self updateContentCache];    
}

- (void)updateContentCache {
    [contentCache setReference:searchString];
    [contentCache setContent:[module renderedTextEntriesForRef:searchString]];    
}

- (void)handleDisplayIndexedNoHasIndex {
    // let the user confirm to create the index now
    NSString *info = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"IndexBeingCreatedForModule", @""), [module name]];
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"IndexNotReady", @"")
                                     defaultButton:NSLocalizedString(@"OK", @"") 
                                   alternateButton:nil 
                                       otherButton:nil 
                         informativeTextWithFormat:info];
    [alert runModal];
    
    // show progress indicator
    // progress indicator is stopped in the delegate methods of either indexing or searching
    [self beginIndicateProgress];
    
    [module createIndexThreadedWithDelegate:self];    
}

- (void)handleDisplayIndexedPerformSearch {
    // show progress indicator
    // progress indicator is stopped in the delegate methods of either indexing or searching
    [self beginIndicateProgress];
    
    long maxResults = 10000;
    indexer = [[IndexingManager sharedManager] indexerForModuleName:[module name] moduleType:[module type]];
    if(indexer == nil) {
        MBLOG(MBLOG_ERR, @"[ModuleViewController -performThreadedSearch::] Could not get indexer for searching!");
    } else {
        [indexer performThreadedSearchOperation:searchString constrains:nil maxResults:maxResults delegate:self];
    }    
}

- (void)handleDisplayCached {
    NSAttributedString *displayText = nil;
    if(searchType == ReferenceSearchType) {
        displayText = [self displayableHTMLForReferenceLookup];
    } else {
        displayText = [self displayableHTMLForIndexedSearch];
    }
    
    if(displayText) {
        [self setAttributedString:displayText];
    }
}

- (void)handleDisplayStatusText {
    int length = 0;
    if(searchType == ReferenceSearchType) {
        length = [(NSArray *)[contentCache content] count];
    } else {
        length = [(NSArray *)[searchContentCache content] count];
    }
    
    [self setStatusText:[NSString stringWithFormat:@"Found %i verses", length]];        
}

#pragma mark - General menu

- (IBAction)displayModuleAbout:(id)sender {
    if(hostingDelegate) {
        if([hostingDelegate respondsToSelector:@selector(displayModuleAboutSheetForModule:)]) {
            [hostingDelegate performSelector:@selector(displayModuleAboutSheetForModule:) withObject:module];
        }
    }
}

#pragma mark - Context Menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if([menuItem menu] == modDisplayOptionsMenu) {
        BOOL ret = NO;

        switch([menuItem tag]) {
            case 1:
                if([module hasFeature:SWMOD_FEATURE_STRONGS]) {
                    ret = YES;
                }
                break;
            case 2:
                if([module hasFeature:SWMOD_FEATURE_MORPH]) {
                    ret = YES;
                }
                break;
            case 3:
                if([module hasFeature:SWMOD_FEATURE_FOOTNOTES]) {
                    ret = YES;
                }
                break;
            case 4:
                if([module hasFeature:SWMOD_FEATURE_SCRIPTREF]) {
                    ret = YES;
                }
                break;
            case 5:
                if([module hasFeature:SWMOD_FEATURE_REDLETTERWORDS]) {
                    ret = YES;
                }
                break;
            case 6:
                if([module hasFeature:SWMOD_FEATURE_HEADINGS]) {
                    ret = YES;
                }
                break;
            case 7:
                if([module hasFeature:SWMOD_FEATURE_HEBREWPOINTS]) {
                    ret = YES;
                }
                break;
            case 8:
                if([module hasFeature:SWMOD_FEATURE_CANTILLATION]) {
                    ret = YES;
                }
                break;
            case 9:
                if([module hasFeature:SWMOD_FEATURE_GREEKACCENTS]) {
                    ret = YES;
                }
                break;
        }
        
        return ret;
    }
    
    return [super validateMenuItem:menuItem];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        NSString *moduleName = [decoder decodeObjectForKey:@"ModuleNameEncoded"];
        self.module = [[SwordManager defaultManager] moduleWithName:moduleName];        
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:[module name] forKey:@"ModuleNameEncoded"];
}

@end
