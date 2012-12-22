//
//  ModuleCommonsViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 16.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import "ContentDisplayingViewController.h"

enum GeneralMenuItemAdditions {
    ShowModuleAbout = 100000
};

@class ModulesUIController;
@class BookmarksUIController;

@interface ModuleCommonsViewController : ContentDisplayingViewController <NSCoding, NSTextViewDelegate> {
    IBOutlet NSView *referenceOptionsView;

    IBOutlet NSPopUpButton *fontSizePopUpButton;
    IBOutlet NSPopUpButton *textContextPopUpButton;
    
    IBOutlet NSMenu *displayOptionsMenu;
    IBOutlet NSPopUpButton *displayOptionsPopUpButton;

    IBOutlet NSMenu *modDisplayOptionsMenu;
    IBOutlet NSPopUpButton *modDisplayOptionsPopUpButton;

    IBOutlet NSSegmentedControl *bookPager;
    IBOutlet NSSegmentedControl *chapterPager;

    NSMutableDictionary *modDisplayOptions;
    NSMutableDictionary *displayOptions;
    
    NSMenu *verseNumberingMenu;
    
    NSInteger customFontSize;
    NSInteger textContext;
}

@property (readwrite) NSInteger customFontSize;
@property (readwrite) NSInteger textContext;
@property (retain, readwrite) NSMutableDictionary *modDisplayOptions;
@property (retain, readwrite) NSMutableDictionary *displayOptions;
@property (readonly) NSPopUpButton *fontSizePopUpButton;
@property (readonly) NSPopUpButton *textContextPopUpButton;
@property (readonly) NSPopUpButton *displayOptionsPopUpButton;
@property (readonly) NSPopUpButton *modDisplayOptionsPopUpButton;

- (void)setGlobalOptionsFromModOptions;

- (BookmarksUIController *)bookmarksUIController;

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
 default text context options
 */
- (void)initTextContextOptions;

/**
 font size options
 */
- (void)initFontSizeOptions;

/** add menu item for custom font size */
- (void)checkAndAddFontSizeMenuItemIfNotExists;
/** enable/disable popup buttons depending on search type */
- (void)setupPopupButtonsForSearchType;

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
- (IBAction)displayOptionShowFullVerseNumbering:(id)sender;
- (IBAction)displayOptionShowVerseNumberOnly:(id)sender;
- (IBAction)displayOptionHideVerseNumbering:(id)sender;
- (IBAction)displayOptionHighlightBookmarks:(id)sender;

- (IBAction)textContextChange:(id)sender;

- (IBAction)bookPagerAction:(id)sender;
- (IBAction)chapterPagerAction:(id)sender;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
