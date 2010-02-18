//
//  ModuleViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <ModuleCommonsViewController.h>
#import <ProtocolHelper.h>
#import <Indexer.h>

#define TEXT_VERSE_MARKER   @"VerseMarkerAttributeName"
#define CHAPTER_BEGINNING_MARKER @"ChapterBeginningMarker"

@class SwordModule, CacheObject;

@interface ModuleViewController : ModuleCommonsViewController <NSCoding, TextContentProviding, TextDisplayable, TextDisplayableExt> {
    IBOutlet NSBox *placeHolderView;
    
    CacheObject *searchContentCache;

    SwordModule *module;
    BOOL performProgressCalculation;
    Indexer *indexer;
}

// --------- properties ---------
@property (retain, readwrite) SwordModule *module;
@property (readwrite) BOOL performProgressCalculation;
@property (retain, readwrite) CacheObject *searchContentCache;

// ---------- methods ---------
- (NSAttributedString *)displayableHTMLForIndexedSearch;
- (NSAttributedString *)displayableHTMLForReferenceLookup;

// helper methods for text display/index creation/search result display
// methods maybe overriden to customize handling for subclasses
- (BOOL)hasValidCacheObject;
- (void)handleDisplayForReference;
- (void)handleDisplayIndexedNoHasIndex;
- (void)handleDisplayIndexedPerformSearch;
- (void)handleDisplayCached;
- (void)handleDisplayStatusText;

/**
 populates the modules menu
 to be overriden by subclasses
 */
- (void)populateModulesMenu;

/** abstract method to be overriden by subclasses */
- (void)setStatusText:(NSString *)aText;

// Indexer delegate method
- (void)searchOperationFinished:(NSArray *)results;
// Index creation delegate
- (void)indexCreationFinished:(SwordModule *)mod;

// the text view
- (NSTextView *)textView;

// context menu actions
- (IBAction)displayModuleAbout:(id)sender;

@end
