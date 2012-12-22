//
//  ModuleViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HostableViewController.h"
#import "ContentDisplayingViewController.h"
#import "ModuleCommonsViewController.h"
#import "ModuleViewController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "ObjCSword/SwordManager.h"
#import "ExtTextViewController.h"
#import "WindowHostController.h"
#import "IndexingManager.h"
#import "ObjCSword/Notifications.h"
#import "CacheObject.h"
#import "NSDictionary+ModuleDisplaySettings.h"
#import "SwordModule+SearchKitIndex.h"

@interface ModuleViewController () 

/** notification, called when modules have changed */
- (void)modulesListChanged:(NSNotification *)aNotification;

@end

@implementation ModuleViewController

#pragma mark - getter/setter

@dynamic module;
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
    tempDisplayString = nil;
    performProgressCalculation = YES;
    forceRedisplay = NO;
    searchType = ReferenceSearchType;
    
    self.searchContentCache = [[[CacheObject alloc] init] autorelease];
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

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [contentDisplayController release];
    [tempDisplayString release];
    [searchContentCache release];
    [module release];

    [super dealloc];
}

#pragma mark - Methods

- (SwordModule *)module {
    return module;
}

- (void)setModule:(SwordModule *)aModule {
    if(module != aModule) {
        [aModule retain];
        [module release];
        module = aModule;

        if(module != nil) {
            // override customFontSize if there is a specific one for module
            if(customFontSize == -1) {
                NSDictionary *settings = [[userDefaults objectForKey:DefaultsModuleDisplaySettingsKey] objectForKey:[module name]];
                if(settings) {
                    customFontSize = [settings displayFontSize];                    
                } else {
                    customFontSize = [[userDefaults objectForKey:DefaultsBibleTextDisplayFontSizeKey] intValue];
                }
            }
        }
    }
}

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
- (NSAttributedString *)displayableHTMLForIndexedSearchResults:(NSArray *)results {
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
    
    if(results) {
        [searchContentCache setCount:[results count]];
        NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"documentName" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];
        NSArray *sortedResults = [results sortedArrayUsingDescriptors:sortDescriptors];
        [searchContentCache setContent:[self displayableHTMLForIndexedSearchResults:sortedResults]];
        
        [self handleDisplayStatusText];
        [self handleDisplayCached];
    }

    [self endIndicateProgress];    
}

- (void)indexCreationFinished:(SwordModule *)mod {
    [self endIndicateProgress];
    
    // I guess the user actually wanted to search for something
    // let's do this now
    forceRedisplay = YES;
    [self displayTextForReference:searchString];
}

#pragma mark - TextContentProviding

- (NSTextView *)textView {
    return [(id<TextContentProviding>)contentDisplayController textView];
}

- (NSScrollView *)scrollView {
    return [(id<TextContentProviding>)contentDisplayController scrollView];
}

- (void)setAttributedString:(NSAttributedString *)aString {
    [(id<TextContentProviding>)contentDisplayController setAttributedString:aString];
}

- (void)setString:(NSString *)aString {
    [(id<TextContentProviding>)contentDisplayController setString:aString];
}

- (void)textChanged:(NSNotification *)aNotification {}

#pragma mark - Printing

- (NSView *)printViewForInfo:(NSPrintInfo *)printInfo {
    NSSize paperSize = [printInfo paperSize];
    NSSize printSize = NSMakeSize(paperSize.width - ([printInfo leftMargin] + [printInfo rightMargin]), 
                                  paperSize.height - ([printInfo topMargin] + [printInfo bottomMargin]));
    
    NSTextView *printView = [[[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, printSize.width, printSize.height)] autorelease];
    [printView insertText:[[self textView] attributedString]];
    
    return printView;
}

#pragma mark - HostViewDelegate

- (void)prepareContentForHost:(WindowHostController *)aHostController {
    [super prepareContentForHost:aHostController];
    [self populateModulesMenu];
    
    [self adaptUIToHost];
}

#pragma mark - TextDisplayable

- (void)displayText {
    [self displayTextForReference:searchString];
}

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
            [self setProgressActionType:ReferenceLookupAction];
            [self setGlobalOptionsFromModOptions];
            [self handleDisplayForReference];
        } else if(searchType == IndexSearchType) {
            [searchContentCache setReference:searchString];
            if(![module hasSKSearchIndex]) {
                [self setProgressActionType:IndexCreateAction];
                [self handleDisplayIndexedNoHasIndex];
            } else {
                [self setProgressActionType:IndexSearchAction];
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
    if((searchType == IndexSearchType && [[searchContentCache reference] isEqualToString:searchString]) ||
       (searchType == ReferenceSearchType && [[contentCache reference] isEqualToString:searchString])) {
        return YES;
    }
    return NO;
}

- (void)handleDisplayForReference {
    [contentCache setReference:searchString];
    if([searchString length] > 0) {
        [contentCache setContent:[self displayableHTMLForReferenceLookup]];        
    } else {
        [contentCache setContent:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
    }
}

- (void)handleDisplayIndexedNoHasIndex {
    // only start creating the index if there actually is a something we are searching for
    if([searchString length] > 0) {
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
        
        [module createSKSearchIndexThreadedWithDelegate:self progressIndicator:[self progressIndicator]];
    }
}

- (void)handleDisplayIndexedPerformSearch {
    if([searchString length] > 0) {
        // show progress indicator
        // progress indicator is stopped in the delegate methods of either indexing or searching
        [self beginIndicateProgress];
        
        long maxResults = 10000;
        indexer = [[IndexingManager sharedManager] indexerForModuleName:[module name] moduleType:[module type]];
        if(indexer == nil) {
            CocoLog(LEVEL_ERR, @"Could not get indexer for searching!");
        } else {
            [indexer performThreadedSearchOperation:searchString constrains:nil maxResults:maxResults delegate:self];
        }
    }
}

- (void)handleDisplayCached {
    NSAttributedString *displayText;
    if(searchType == ReferenceSearchType) {
        displayText = [contentCache content];
    } else {
        displayText = [searchContentCache content];
    }
    
    if(displayText) {
        [self setAttributedString:displayText];
    }
}

- (void)handleDisplayStatusText {
    int length;
    if(searchType == ReferenceSearchType) {
        length = [contentCache count];
        [self setStatusText:[NSString stringWithFormat:@"Found %i verses", length]];        
    } else {
        length = [searchContentCache count];
        [self setStatusText:[NSString stringWithFormat:@"Found %i results", length]];
    }    
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
        [self setModule:[[SwordManager defaultManager] moduleWithName:moduleName]];
        [self setSearchString:[decoder decodeObjectForKey:@"SearchStringEncoded"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:[module name] forKey:@"ModuleNameEncoded"];
    [encoder encodeObject:searchString forKey:@"SearchStringEncoded"];
}

@end
