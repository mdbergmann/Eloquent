//
//  ModuleCommonsViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 16.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <HostableViewController.h>
#import <ProtocolHelper.h>

enum BibleViewTextContextMenuItems {
    LookUpInIndexDefault = 100,
    LookUpInIndexList,
    LookUpInDictionaryDefault = 300,
    LookUpInDictionaryList
};

enum BibleViewLinkContextMenuItems {
    OpenLink = 10,
};

@interface ModuleCommonsViewController : HostableViewController <NSCoding, TextDisplayable, MouseTracking> {
    /** options */
    IBOutlet NSMenu *displayOptionsMenu;
    IBOutlet NSPopUpButton *displayOptionsPopUpButton;
    IBOutlet NSMenu *modDisplayOptionsMenu;
    IBOutlet NSPopUpButton *modDisplayOptionsPopUpButton;
    IBOutlet NSView *referenceOptionsView;
    IBOutlet NSPopUpButton *fontSizePopUpButton;
    
    NSMutableDictionary *modDisplayOptions;
    NSMutableDictionary *displayOptions;
        
    // current reference
    NSString *reference;
    
    // custom font size
    int customFontSize;

    // force redisplay
    BOOL forceRedisplay;
}

@property (retain, readwrite) NSString *reference;
@property (readwrite) BOOL forceRedisplay;
@property (readwrite) int customFontSize;
@property (retain, readwrite) NSMutableDictionary *modDisplayOptions;
@property (retain, readwrite) NSMutableDictionary *displayOptions;

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

// Actions to be overriden by subclasses
- (IBAction)fontSizeChange:(id)sender;
- (IBAction)displayOptionShowStrongs:(id)sender;
- (IBAction)displayOptionShowMorphs:(id)sender;
- (IBAction)displayOptionShowFootnotes:(id)sender;
- (IBAction)displayOptionShowCrossRefs:(id)sender;
- (IBAction)displayOptionShowRedLetterWords:(id)sender;
- (IBAction)displayOptionShowHeadings:(id)sender;
- (IBAction)displayOptionShowHebrewPoints:(id)sender;
- (IBAction)displayOptionShowHebrewCantillation:(id)sender;
- (IBAction)displayOptionShowGreekAccents:(id)sender;
- (IBAction)displayOptionVersesOnOneLine:(id)sender;

// TextDisplayable
- (void)displayTextForReference:(NSString *)aReference;
- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType;
- (NSView *)referenceOptionsView;

// MouseTracking
- (void)mouseEntered:(NSView *)theView;
- (void)mouseExited:(NSView *)theView;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
