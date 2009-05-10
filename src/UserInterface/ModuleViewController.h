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

#define TEXT_VERSE_MARKER @"VerseMarkerAttributeName"

@class SwordModule;
@class ExtTextViewController;

@interface ModuleViewController : ModuleCommonsViewController <NSCoding, TextDisplayable, ContextMenuProviding> {

    // placeholder for webview or other views depending on nodule tyoe
    IBOutlet NSBox *placeHolderView;
    
    // context menus
    IBOutlet NSMenu *textContextMenu;
    IBOutlet NSMenu *linkContextMenu;
    IBOutlet NSMenu *imageContextMenu;    

    // the module
    SwordModule *module;
    
    // we need a webview for text display
    ExtTextViewController *textViewController;
    
    // context menu clicked link
    NSURL *contextMenuClickedLink;
    
    // perform progress calculation
    BOOL performProgressCalculation;
    
    // a indexer
    Indexer *indexer;
}

// --------- properties ---------
@property (retain, readwrite) SwordModule *module;
@property (readwrite) BOOL performProgressCalculation;
@property (retain, readwrite) NSURL *contextMenuClickedLink;

// ---------- methods ---------
- (NSAttributedString *)displayableHTMLFromSearchResults:(NSArray *)tempResults searchQuery:(NSString *)searchQuery numberOfResults:(int *)results;

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

// ---------- Hostable delegate methods ---------
- (void)contentViewInitFinished:(HostableViewController *)aView;

// delegate method of ExtTextViewController
- (NSMenu *)menuForEvent:(NSEvent *)event;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

// ContextMenuProviding
- (NSMenu *)textContextMenu;
- (NSMenu *)linkContextMenu;
- (NSMenu *)imageContextMenu;

// context menu actions
- (IBAction)lookUpInIndex:(id)sender;
- (IBAction)lookUpInIndexOfBible:(id)sender;
- (IBAction)lookUpInDictionary:(id)sender;
- (IBAction)lookUpInDictionaryOfModule:(id)sender;
- (IBAction)openLink:(id)sender;
- (IBAction)displayModuleAbout:(id)sender;

@end
