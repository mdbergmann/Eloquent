//
//  ExtTextViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ExtTextViewController.h"
#import "MouseTrackingScrollView.h"
#import "MBPreferenceController.h"

@implementation ExtTextViewController

- (id)init {
    self = [self initWithDelegate:nil];
    
    return self;
}

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -init] loading nib");
        
        // init values
        viewLoaded = NO;
        self.delegate = aDelegate;

        // load nib
        BOOL stat = [NSBundle loadNibNamed:EXTTEXTVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[ExtTextViewController -init] unable to load nib!");
        }
    }
    
    return self;    
}

- (void)awakeFromNib {
    
    MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -awakeFromNib]");
    // call delegate method when this view has loaded
    viewLoaded = YES;
    
    // set delegate for mouse tracking
    scrollView.delegate = self;
    // register for frame changed notifications of mouse tracking scrollview
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewFrameDidChange:)
                                                 name:NSViewFrameDidChangeNotification
                                               object:scrollView];    
    // tell scrollview to post bounds notifications
    [scrollView setPostsFrameChangedNotifications:YES];    
    // enable mouse tracking
    [scrollView updateMouseTracking];
    
    // report view loading completed
    [self reportLoadingComplete];
}


#pragma mark - getter/setter

- (NSTextView *)textView {
    return textView;
}

- (MouseTrackingScrollView *)scrollView {
    return scrollView;
}

#pragma mark - methods

- (void)setAttributedString:(NSAttributedString *)aString {
    [[textView textStorage] setAttributedString:aString];    
}

#pragma mark - mouse tracking protocol

- (void)mouseEntered:(NSView *)theView {
    MBLOG(MBLOG_DEBUG, @"[ExtTextViewController - mouseEntered]");
    if(delegate && [delegate respondsToSelector:@selector(mouseEntered:)]) {
        [delegate performSelector:@selector(mouseEntered:) withObject:[self view]];
    }
}

- (void)mouseExited:(NSView *)theView {
    MBLOG(MBLOG_DEBUG, @"[MouseTrackingScrollView - mouseExited]");
    if(delegate && [delegate respondsToSelector:@selector(mouseExited:)]) {
        [delegate performSelector:@selector(mouseExited:) withObject:[self view]];
    }
}

- (void)scrollViewFrameDidChange:(NSNotification *)n {
    MBLOG(MBLOG_DEBUG, @"[ExtTextViewController - scrollViewFrameDidChange]");
    
    // update tracking rect
    [scrollView updateMouseTracking];
}

@end
