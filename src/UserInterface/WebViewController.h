//
//  WebViewController.h
//  Eloquent
//
//  Created by Bergmann Manfred on 18.09.11.
//  Copyright 2011 Crosswire. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <CocoLogger/CocoLogger.h>
#import "HostableViewController.h"

#define WEBVIEW_NIBNAME   @"WebView"

@class MouseTrackingScrollView;
@class MBTextView;

@interface WebViewController : HostableViewController <MouseTracking, TextContentProviding> {
    IBOutlet WebView *webView;
    IBOutlet MouseTrackingScrollView *scrollView;
}

- (id)initWithDelegate:(id)aDelegate;
- (NSMenu *)menuForEvent:(NSEvent *)event;

// TextContentProviding
- (NSTextView *)textView;
- (MouseTrackingScrollView *)scrollView;
- (void)setAttributedString:(NSAttributedString *)aString;
- (void)setString:(NSString *)aString;

// MouseTracking
- (void)mouseEnteredView:(NSView *)theView;
- (void)mouseExitedView:(NSView *)theView;

@end
