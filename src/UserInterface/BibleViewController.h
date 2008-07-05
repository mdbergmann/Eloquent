//
//  BibleTextViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 14.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <HostableViewController.h>
#import <ModuleViewController.h>
#import <ProtocolHelper.h>

@class SwordBible, ExtTextViewController;

#define BIBLEVIEW_NIBNAME   @"BibleView"

/** the view of this view controller is a ScrollSynchronizableView */
@interface BibleViewController : ModuleViewController <NSCoding, TextDisplayable, SubviewHosting, MouseTracking> {
    // close button
    IBOutlet NSButton *closeBtn;
    // module popup button
    IBOutlet NSPopUpButton *modulePopBtn;
    // status line
    IBOutlet NSTextField *statusLine;
    // progress indicator per BibleView
    IBOutlet NSProgressIndicator *progressIndicator;
    
    // we need a webview for text display
    ExtTextViewController *textViewController;
    
    // search type
    SearchType searchType;
}

// ---------- initializers ---------
- (id)initWithModule:(SwordBible *)aModule;
- (id)initWithModule:(SwordBible *)aModule delegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate;

// ----------- methods -------------

// pass further the scroll and textview
- (NSTextView *)textView;
- (NSScrollView *)scrollView;

// method called by subview
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;
- (void)setStatusText:(NSString *)aText;

// protocol definitions
- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType;

// Mouse tracking protocol implementation
- (void)mouseEntered:(NSView *)theView;
- (void)mouseExited:(NSView *)theView;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

// actions
- (IBAction)closeButton:(id)sender;

@end
