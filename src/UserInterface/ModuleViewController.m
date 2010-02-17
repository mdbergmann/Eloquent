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

@interface ModuleViewController () 

/** notification, called when modules have changed */
- (void)modulesListChanged:(NSNotification *)aNotification;

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
        performProgressCalculation = YES;
        searchType = ReferenceSearchType;
        contentDisplayController = [[ExtTextViewController alloc] initWithDelegate:self];
        [self setSearchContentCache:[[CacheObject alloc] init]];

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(modulesListChanged:)
                                                     name:NotificationModulesChanged object:nil];            
    }
    
    return self;
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
        [self setStatusText:[NSString stringWithFormat:@"Found %i verses", resultsCount]];
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
    [self displayTextForReference:reference];
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

#pragma mark - Hostable delegate methods

- (void)contentViewInitFinished:(HostableViewController *)aView {
}

- (NSString *)label {
    if(module != nil) {
        return [module name];
    }
    
    return @"ModuleView";
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
        performProgressCalculation = YES;
        searchType = ReferenceSearchType;
        NSString *moduleName = [decoder decodeObjectForKey:@"ModuleNameEncoded"];
        self.module = [[SwordManager defaultManager] moduleWithName:moduleName];
        
        contentDisplayController = [[ExtTextViewController alloc] initWithDelegate:self];

        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(modulesListChanged:)
                                                     name:NotificationModulesChanged object:nil];            

        forceRedisplay = NO;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:[module name] forKey:@"ModuleNameEncoded"];
}

@end
