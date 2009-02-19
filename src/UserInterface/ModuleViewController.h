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

@class SwordModule;

@interface ModuleViewController : HostableViewController <NSCoding, TextDisplayable, MouseTracking> {

    // placeholder for webview or other views depending on nodule tyoe
    IBOutlet NSBox *placeHolderView;
    
    // the module
    SwordModule *module;
    // current reference
    NSString *reference;
    
    /** options */
    IBOutlet NSMenu *displayOptionsMenu;
    IBOutlet NSMenu *modDisplayOptionsMenu;
    IBOutlet NSView *referenceOptionsView;
    NSMutableDictionary *modDisplayOptions;
    NSMutableDictionary *displayOptions;
    
    // force redisplay
    BOOL forceRedisplay;
}

// --------- properties ---------
@property (retain, readwrite) SwordModule *module;
@property (retain, readwrite) NSString *reference;
@property (readwrite) BOOL forceRedisplay;
@property (retain, readwrite) NSMutableDictionary *modDisplayOptions;
@property (retain, readwrite) NSMutableDictionary *displayOptions;

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

// ---------- Hostable delegate methods ---------
- (void)contentViewInitFinished:(HostableViewController *)aView;

// --------- getter / setter ----------
- (NSString *)reference;
- (void)setReference:(NSString *)aReference;

// TextDisplayable protocol
- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType;
- (NSView *)referenceOptionsView;

// Mouse tracking protocol implementation
- (void)mouseEntered:(NSView *)theView;
- (void)mouseExited:(NSView *)theView;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
