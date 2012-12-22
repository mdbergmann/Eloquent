//
//  WebViewController.m
//  Eloquent
//
//  Created by Bergmann Manfred on 18.09.11.
//  Copyright 2011 Crosswire. All rights reserved.
//

#import "WebViewController.h"
#import "MouseTrackingScrollView.h"
#import "MBTextView.h"

@implementation WebViewController

- (id)init {
    self = [self initWithDelegate:nil];
    
    return self;
}

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if(self) {
        CocoLog(LEVEL_DEBUG, @"loading nib");
        
        // init values
        viewLoaded = NO;
        self.delegate = aDelegate;
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:WEBVIEW_NIBNAME owner:self];
        if(!stat) {
            CocoLog(LEVEL_ERR, @"unable to load nib!");
        }
    }
    
    return self;    
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    return nil;
}


- (void)awakeFromNib {
    viewLoaded = YES;
    [self reportLoadingComplete];
}

#pragma mark - TextContentProviding

- (NSTextView *)textView {
    return (NSTextView *)webView;
}

- (MouseTrackingScrollView *)scrollView {
    NSScrollView* sv = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];

    return (MouseTrackingScrollView *)sv;
}

- (void)setAttributedString:(NSAttributedString *)aString {
    [self setString:[aString string]];
}

- (void)setString:(NSString *)aString {
    [[webView mainFrame] loadHTMLString:aString baseURL:[[[NSURL alloc] init] autorelease]];
}

- (void)textChanged:(NSNotification *)aNotification {
    if(delegate && [delegate respondsToSelector:@selector(textChanged:)]) {
        [delegate performSelector:@selector(textChanged:) withObject:aNotification];
    }
}

#pragma mark - mouse tracking protocol

- (void)mouseEnteredView:(NSView *)theView {
    //CocoLog(LEVEL_DEBUG, @"[ExtTextViewController - mouseEntered]");
    if(delegate && [delegate respondsToSelector:@selector(mouseEnteredView:)]) {
        [delegate performSelector:@selector(mouseEnteredView:) withObject:[self view]];
    }
}

- (void)mouseExitedView:(NSView *)theView {
    //CocoLog(LEVEL_DEBUG, @"[ExtTextViewController - mouseExited]");
    if(delegate && [delegate respondsToSelector:@selector(mouseExitedView:)]) {
        [delegate performSelector:@selector(mouseExitedView:) withObject:[self view]];
    }
}

- (void)scrollViewFrameDidChange:(NSNotification *)n {
    //CocoLog(LEVEL_DEBUG, @"[ExtTextViewController - scrollViewFrameDidChange]");
    
    [scrollView updateMouseTracking];
}

@end
