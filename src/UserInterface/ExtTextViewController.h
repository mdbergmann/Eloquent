//
//  WebViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

/*
 This class is the one webview controller class.
 It can be instanciated where ever needed and put in as subview.
 Delegate can be set to forward any WebView actions.
 A protocol is defined for these delegation methods.
 */

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <HostableViewController.h>
#import <MBTextView.h>
#import <ProtocolHelper.h>

#define EXTTEXTVIEW_NIBNAME   @"ExtTextView"

@class MouseTrackingScrollView;

@interface ExtTextViewController : HostableViewController <MouseTracking, TextContentProviding> {
    IBOutlet MBTextView *textView;
    IBOutlet MouseTrackingScrollView *scrollView;
}

- (id)initWithDelegate:(id)aDelegate;

- (MBTextView *)textView;
- (MouseTrackingScrollView *)scrollView;

// delegate methods called from MBTextView
- (NSMenu *)menuForEvent:(NSEvent *)event;

- (void)setAttributedString:(NSAttributedString *)aString;
- (void)setString:(NSString *)aString;

// MouseTrackingScrollView delegate methods
- (void)mouseEntered:(NSView *)theView;
- (void)mouseExited:(NSView *)theView;

@end
