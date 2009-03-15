//
//  ModuleViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <HostableViewController.h>
#import <ProtocolHelper.h>
#import <Indexer.h>

#define TEXT_VERSE_MARKER @"VerseMarkerAttributeName"

enum BibleViewTextContextMenuItems {
    LookUpInIndexDefault = 100,
    LookUpInIndexList,
    LookUpInDictionaryDefault = 300,
    LookUpInDictionaryList
};

enum BibleViewLinkContextMenuItems {
    OpenLink = 10,
};

@class SwordModule;
@class ExtTextViewController;

@interface ModuleViewController : HostableViewController <NSCoding, TextDisplayable, MouseTracking, ContextMenuProviding> {

    // placeholder for webview or other views depending on nodule tyoe
    IBOutlet NSBox *placeHolderView;
    
    // the module
    SwordModule *module;
    // current reference
    NSString *reference;
    
    // we need a webview for text display
    ExtTextViewController *textViewController;

    /** options */
    IBOutlet NSMenu *displayOptionsMenu;
    IBOutlet NSMenu *modDisplayOptionsMenu;
    IBOutlet NSView *referenceOptionsView;
    NSMutableDictionary *modDisplayOptions;
    NSMutableDictionary *displayOptions;
    
    // context menus
    IBOutlet NSMenu *textContextMenu;
    IBOutlet NSMenu *linkContextMenu;
    IBOutlet NSMenu *imageContextMenu;    
    
    // context menu clicked link
    NSURL *contextMenuClickedLink;
    
    // force redisplay
    BOOL forceRedisplay;    
}

// --------- properties ---------
@property (retain, readwrite) SwordModule *module;
@property (retain, readwrite) NSString *reference;
@property (readwrite) BOOL forceRedisplay;
@property (retain, readwrite) NSMutableDictionary *modDisplayOptions;
@property (retain, readwrite) NSMutableDictionary *displayOptions;
@property (retain, readwrite) NSURL *contextMenuClickedLink;

// ---------- methods ---------
- (NSAttributedString *)searchResultStringForQuery:(NSString *)searchQuery numberOfResults:(int *)results;
/** 
 default module display options dictionary 
 can be overriden by subclasses
 */
- (void)initDefaultModDisplayOptions;
/** 
 default display options dictionary 
 can be overriden by subclasses
 */
- (void)initDefaultDisplayOptions;

/**
 populates the modules menu
 to be overriden by subclasses
 */
- (void)populateModulesMenu;

// ---------- Hostable delegate methods ---------
- (void)contentViewInitFinished:(HostableViewController *)aView;

// --------- getter / setter ----------
- (NSString *)reference;
- (void)setReference:(NSString *)aReference;

// delegate method of ExtTextViewController
- (NSMenu *)menuForEvent:(NSEvent *)event;

// TextDisplayable
- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType;
- (NSView *)referenceOptionsView;

// MouseTracking
- (void)mouseEntered:(NSView *)theView;
- (void)mouseExited:(NSView *)theView;

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

@end
