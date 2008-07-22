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

/**
 Delivers the range of the first visible line in the textview.
 @param[out] lineRect the rect of that first line
 @return the range of first line
 */
- (NSRange)rangeOfFirstLineWithLineRect:(NSRect *)lineRect {    
    if([textView enclosingScrollView]) {
        NSLayoutManager *layoutManager = [textView layoutManager];
        NSRect visibleRect = [textView visibleRect];
        
        NSPoint containerOrigin = [textView textContainerOrigin];
        visibleRect.origin.x -= containerOrigin.x;
        visibleRect.origin.y -= containerOrigin.y;
        
        NSRange glyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:[textView textContainer]];
        //NSRange glyphRange = [layoutManager glyphRangeForBoundingRectWithoutAdditionalLayout:visibleRect inTextContainer:[theTextView textContainer]];
        //MBLOGV(MBLOG_DEBUG, @"glyphRange loc:%i len:%i", glyphRange.location, glyphRange.length);
        
        // get line rect
        *lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:nil];
        //MBLOGV(MBLOG_DEBUG, @"lineRect x:%f y:%f w:%f h:%f", lineRect->origin.x, lineRect->origin.y, lineRect->size.width, lineRect->size.height);
        
        // get range
        NSRange lineRange = [layoutManager glyphRangeForBoundingRect:*lineRect inTextContainer:[textView textContainer]];
        //MBLOGV(MBLOG_DEBUG, @"lineRange loc:%i len:%i", lineRange.location, lineRange.length);        
        
        return lineRange;
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (NSRect)rectOfFirstLine {
    NSLayoutManager *layoutManager = [textView layoutManager];
    NSRect visibleRect = [textView visibleRect];
    NSPoint containerOrigin = [textView textContainerOrigin];
    visibleRect.origin.x -= containerOrigin.x;
    visibleRect.origin.y -= containerOrigin.y;
    
    return NSMakeRect(0.0, visibleRect.origin.y, visibleRect.size.width, 15.0);
}

- (NSRect)rectOfLastLine {
    NSLayoutManager *layoutManager = [textView layoutManager];
    NSRect visibleRect = [textView visibleRect];
    NSPoint containerOrigin = [textView textContainerOrigin];
    visibleRect.origin.x -= containerOrigin.x;
    visibleRect.origin.y -= containerOrigin.y;
    
    return NSMakeRect(0.0, visibleRect.size.height, visibleRect.size.width, 15.0);    
}

/**
 Delivers the range of the visible text in textview.
 @return the range of visible text
 */
- (NSRange)rangeOfVisibleText {
    if([textView enclosingScrollView]) {
        NSLayoutManager *layoutManager = [textView layoutManager];
        NSRect visibleRect = [textView visibleRect];
        
        NSPoint containerOrigin = [textView textContainerOrigin];
        visibleRect.origin.x -= containerOrigin.x;
        visibleRect.origin.y -= containerOrigin.y;
        
        NSRange glyphRange = [layoutManager glyphRangeForBoundingRectWithoutAdditionalLayout:visibleRect inTextContainer:[textView textContainer]];
        //MBLOGV(MBLOG_DEBUG, @"glyphRange loc:%i len:%i", glyphRange.location, glyphRange.length);
        return glyphRange;
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (NSRange)rangeOfTextToken:(NSString *)token lastFound:(NSRange)lastFoundRange directionRight:(BOOL)right {
    NSRange ret;
    
    // get text
    NSString *text = [[textView textStorage] string];
    int startIndex = 0;
    int stopIndex = 0;
    int mask = 0;

    if(lastFoundRange.location == NSNotFound) {
        startIndex = 0;
        stopIndex = [text length] - 1;
    } else {
        if(right) {
            startIndex = lastFoundRange.location + lastFoundRange.length;
            stopIndex = [text length] - startIndex;        
        } else {
            startIndex = 0;
            stopIndex = lastFoundRange.location;
            mask = NSBackwardsSearch;
        }        
    }
    ret = [text rangeOfString:token options:mask range:NSMakeRange(startIndex, stopIndex)];
    
    return ret;
}

- (NSRect)rectForTextRange:(NSRange)range {
    NSLayoutManager *layoutManager = [textView layoutManager];
    NSRect rect = [layoutManager lineFragmentRectForGlyphAtIndex:range.location effectiveRange:nil];
    return rect;
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
