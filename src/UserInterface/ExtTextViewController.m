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
#import "HUDPreviewController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "globals.h"
#import "ProtocolHelper.h"

@interface ExtTextViewController ()

@end

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
    
    //[[self view] setWantsLayer:YES];
    
    // delete any content in textview
    [textView setString:@""];
    
    // set delegate for mouse tracking
    scrollView.delegate = self;
    
    [textView setHorizontallyResizable:YES];
    //[[textView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[textView textContainer] setWidthTracksTextView:YES];
    //[[textView textContainer] setHeightTracksTextView:YES];
    NSSize margins = NSMakeSize([[userDefaults objectForKey:DefaultsTextContainerVerticalMargins] floatValue], 
                                [[userDefaults objectForKey:DefaultsTextContainerHorizontalMargins] floatValue]);
    [textView setTextContainerInset:margins];
    // we also observe changing of this value
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:DefaultsTextContainerVerticalMargins
                                               options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:DefaultsTextContainerHorizontalMargins
                                               options:NSKeyValueObservingOptionNew context:nil];
    
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

/** pass though to delegate */
- (IBAction)saveDocument:(id)sender {
    [delegate saveDocument:sender];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// check for keyPath
	if([keyPath isEqualToString:DefaultsTextContainerVerticalMargins]) {
        NSSize margins = NSMakeSize([[userDefaults objectForKey:DefaultsTextContainerVerticalMargins] floatValue], 
                                    [[userDefaults objectForKey:DefaultsTextContainerHorizontalMargins] floatValue]);
        [textView setTextContainerInset:margins];
	} else if([keyPath isEqualToString:DefaultsTextContainerHorizontalMargins]) {
        NSSize margins = NSMakeSize([[userDefaults objectForKey:DefaultsTextContainerVerticalMargins] floatValue], 
                                    [[userDefaults objectForKey:DefaultsTextContainerHorizontalMargins] floatValue]);
        [textView setTextContainerInset:margins];
	}
}

#pragma mark - getter/setter

- (MBTextView *)textView {
    return textView;
}

- (MouseTrackingScrollView *)scrollView {
    return scrollView;
}

- (void)setAttributedString:(NSAttributedString *)aString {
    [[textView textStorage] setAttributedString:aString];    
}

#pragma mark - MBTextView delegates

- (NSMenu *)menuForEvent:(NSEvent *)event {
    if(delegate) {
        return [delegate performSelector:@selector(menuForEvent:) withObject:event];
    }
    
    return nil;
}

#pragma mark - methods

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

/**
 Delivers the range of the line at the given character index location
 @param[in] index location
 @return the range of line
 */
- (NSRange)rangeOfLineAtIndex:(long)index {
    if([textView enclosingScrollView]) {
        NSLayoutManager *layoutManager = [textView layoutManager];
        // get line rect
        NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:nil];
        
        // get range
        NSRange lineRange = [layoutManager glyphRangeForBoundingRect:lineRect inTextContainer:[textView textContainer]];
        
        return lineRange;
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (NSRect)rectOfFirstLine {
    NSRect visibleRect = [textView visibleRect];
    NSPoint containerOrigin = [textView textContainerOrigin];
    visibleRect.origin.x -= containerOrigin.x;
    visibleRect.origin.y -= containerOrigin.y;
    
    return NSMakeRect(0.0, visibleRect.origin.y, visibleRect.size.width, 15.0);
}

- (NSRect)rectOfLastLine {
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

/**
 tries to find the given attribute value
 if not found, ret.origin.x == NSNotFound
 */
- (NSRect)rectForAttributeName:(NSString *)attrName attributeValue:(id)attrValue {
    NSRect ret;
    ret.origin.x = NSNotFound;
    
    NSAttributedString *text = [textView attributedString];
    long len = [[textView string] length];
    NSRange foundRange;
    foundRange.location = NSNotFound;
    for(int i = 0;i < len;i++) {
        id val = [text attribute:attrName atIndex:i effectiveRange:&foundRange];
        if(val != nil) {
            if([val isKindOfClass:[NSString class]] && [(NSString *)val isEqualToString:(NSString *)attrValue]) {
                MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -rectForAttributeName::] found attribute");
                break;
            } else {
                i += foundRange.location + foundRange.length;
                foundRange.location = NSNotFound;
            }
        }
    }
    
    if(foundRange.location != NSNotFound) {
        ret = [self rectForTextRange:foundRange];
    }
    
    return ret;
}

- (NSDictionary *)dataForLink:(NSURL *)aURL {
    // there are two types of links
    // our generated sword:// links and study data beginning with applewebdata://
    
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    NSString *scheme = [aURL scheme];
    if([scheme isEqualToString:@"sword"]) {
        // in this case host is the module and path the reference
        [ret setObject:[aURL host] forKey:ATTRTYPE_MODULE];
        [ret setObject:[[[aURL path] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"/" withString:@""]
                forKey:ATTRTYPE_VALUE];
        [ret setObject:@"scriptRef" forKey:ATTRTYPE_TYPE];
        [ret setObject:@"showRef" forKey:ATTRTYPE_ACTION];
    } else if([scheme isEqualToString:@"applewebdata"]) {
        // in this case
        NSString *path = [aURL path];
        NSString *query = [aURL query];
        if([[path lastPathComponent] isEqualToString:@"passagestudy.jsp"]) {
            NSArray *data = [query componentsSeparatedByString:@"&"];
            NSString *type = @"x";
            NSString *module = @"";
            NSString *passage = @"";
            NSString *value = @"1";
            NSString *action = @"";
            for(NSString *entry in data) {
                if([entry hasPrefix:@"type="]) {
                    type = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];
                } else if([entry hasPrefix:@"module="]) {
                    module = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];
                } else if([entry hasPrefix:@"passage="]) {
                    passage = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];
                } else if([entry hasPrefix:@"action="]) {
                    action = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];                    
                } else if([entry hasPrefix:@"value="]) {
                    value = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];                    
                } else {
                    MBLOGV(MBLOG_WARN, @"[ExtTextViewController -dataForLink:] unknown parameter: %@\n", entry);
                }
            }
            
            [ret setObject:module forKey:ATTRTYPE_MODULE];
            [ret setObject:passage forKey:ATTRTYPE_PASSAGE];
            [ret setObject:value forKey:ATTRTYPE_VALUE];
            [ret setObject:action forKey:ATTRTYPE_ACTION];
            [ret setObject:type forKey:ATTRTYPE_TYPE];
        }
    }
    
    return ret;
}

- (NSString *)selectedString {
    NSString *ret = nil;
    
    NSRange selRange = [textView selectedRange];
    if(selRange.length == 0) {
        // no selection
        MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -selectedString:] no selection!");
    } else {
        // get text for selection
        ret = [[textView string] substringWithRange:selRange];
        MBLOGV(MBLOG_DEBUG, @"[ExtTextViewController -selectedString:] selected text: %@", ret);
    }
    
    return ret;
}

#pragma mark - NSTextView delegates

- (NSString *)textView:(NSTextView *)textView willDisplayToolTip:(NSString *)tooltip forCharacterAtIndex:(NSUInteger)characterIndex {
    MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -textView:willDisplayToolTip:]");

    NSString *ret = nil;
    
    // create URL
    NSURL *url = [NSURL URLWithString:[tooltip stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if(!url) {
        MBLOGV(MBLOG_WARN, @"[ExtTextViewController -textView:willDisplayToolTip:] no URL: %@\n", tooltip);
    } else {
        NSDictionary *linkResult = [self dataForLink:url];
        SendNotifyShowPreviewData(linkResult);
        
        if([userDefaults boolForKey:DefaultsShowPreviewToolTip]) {
            ret = [[HUDPreviewController previewDataFromDict:linkResult] objectForKey:PreviewDisplayTextKey];
        }
    }
    
    return ret;
}

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -textView:clickedOnLink:]");
    
    // this is NSURL
    MBLOGV(MBLOG_DEBUG, @"[ExtTextViewController -textView:clickedOnLink:] classname: %@", [link className]);    
    MBLOGV(MBLOG_DEBUG, @"[ExtTextViewController -textView:clickedOnLink:] link: %@", [link description]);
    
    NSDictionary *linkResult = [self dataForLink:(NSURL *)link];    
    SendNotifyShowPreviewData(linkResult);
    
    return YES;
}

- (void)textView:(NSTextView *)aTextView doubleClickedOnCell:(id < NSTextAttachmentCell >)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
    MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -textView:doubleClickedOnCell:inRect:atIndex:]");
    
    /*
    NSDictionary *attrs = [[aTextView textStorage] attributesAtIndex:charIndex effectiveRange:nil];
    NSURL *link = [attrs objectForKey:NSLinkAttributeName];
    if(link != nil) {
        // set link in delegate
        [delegate performSelector:@selector(setContextMenuClickedLink:) withObject:link];
        // call openLink
        [delegate performSelector:@selector(openLink:) withObject:nil];
    }
     */
}

#pragma mark - mouse tracking protocol

- (void)mouseEntered:(NSView *)theView {
    //MBLOG(MBLOG_DEBUG, @"[ExtTextViewController - mouseEntered]");
    if(delegate && [delegate respondsToSelector:@selector(mouseEntered:)]) {
        [delegate performSelector:@selector(mouseEntered:) withObject:[self view]];
    }
}

- (void)mouseExited:(NSView *)theView {
    //MBLOG(MBLOG_DEBUG, @"[ExtTextViewController - mouseExited]");
    if(delegate && [delegate respondsToSelector:@selector(mouseExited:)]) {
        [delegate performSelector:@selector(mouseExited:) withObject:[self view]];
    }
}

- (void)scrollViewFrameDidChange:(NSNotification *)n {
    //MBLOG(MBLOG_DEBUG, @"[ExtTextViewController - scrollViewFrameDidChange]");
    
    // update tracking rect
    [scrollView updateMouseTracking];
}

@end
