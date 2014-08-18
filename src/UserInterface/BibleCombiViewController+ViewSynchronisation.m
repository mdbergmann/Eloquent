//
//  BibleCombiViewController+ViewSynchronisation.m
//  Eloquent
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "HostableViewController.h"
#import "ContentDisplayingViewController.h"
#import "ModuleCommonsViewController.h"
#import "BibleCombiViewController+ViewSynchronisation.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "ScrollSynchronizableView.h"
#import "ModuleViewController.h"

@implementation BibleCombiViewController (ViewSynchronisation)

#pragma mark - Scrollview Synchronization

- (void)stopScrollSynchronizationForView:(NSScrollView *)aScrollView {
    // get contentview of this view and remove listener
    if (aScrollView != nil) {
        NSView *contentView = [aScrollView contentView];
        
        // remove any existing notification registration
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSViewBoundsDidChangeNotification
                                                      object:contentView];
    }    
}

- (void)establishScrollSynchronization:(NSScrollView *)scrollView {
    // loop over all views in parallel bible splitview and deacivate the scroller for all but the most right view
    // let all left scrollview register for notifications from the bounds changes of the most right scrollview
    if(viewLoaded) {
        // register observer for notification only for the given one
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(synchronizedViewContentBoundsDidChange:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:[scrollView contentView]];
        // tell scrollview to post bounds notifications
        [scrollView setPostsBoundsChangedNotifications:YES];
    }
}

- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)aNotification {
    
    // get the changed content view from the notification
    NSView *changedContentView = [aNotification object];
    
    // get the origin of the NSClipView of the scroll view that
    // we're watching
    NSPoint changedBoundsOrigin = [changedContentView bounds].origin;
    
    NSString *sourceMarker = nil;
    if(searchType == ReferenceSearchType) {
        sourceMarker = [self verseMarkerOfFirstLineOfTextView:currentSyncView];
    }
    
    // loop over all parallel views and check bounds
    NSMutableArray *subViews = [NSMutableArray arrayWithArray:[parBibleSplitView subviews]];
    [subViews addObjectsFromArray:[parMiscSplitView subviews]];
    
    BOOL hasDefaultsInset = [userDefaults objectForKey:DefaultsTextContainerHorizontalMargins] != nil;
    float defaultsInset = [[userDefaults objectForKey:DefaultsTextContainerHorizontalMargins] floatValue];
    NSEnumerator *iter = [subViews reverseObjectEnumerator];
    ScrollSynchronizableView *v = nil;
    while((v = [iter nextObject])) {
        // get scrollView
        NSScrollView *scrollView = v.syncScrollView;
        
        // we only want to change bounds for the scrollviews that are not the sender of the notification
        if([scrollView contentView] != changedContentView) {
            // get our current origin
            NSPoint curOffset = [[scrollView contentView] bounds].origin;
            NSPoint newOffset = curOffset;
            
            // scrolling is synchronized in the vertical plane
            // so only modify the y component of the offset
            newOffset.y = changedBoundsOrigin.y;            
            
            // the point to scroll to
            NSPoint destPoint = curOffset;
            
            BOOL updateScroll = YES;
            if(searchType == ReferenceSearchType) {
                
                if(newOffset.y == 0.0) {
                    // scroll to top
                    destPoint.x = 0.0;
                    destPoint.y = 0.0;
                } else {
                    // get the verseMarker of this syncview
                    NSString *marker = [self verseMarkerOfFirstLineOfTextView:v];
                    
                    // the sender is the rightest scrollview
                    if((sourceMarker != nil) && ([sourceMarker length] > 0) && ![marker isEqualToString:sourceMarker]) {
                        /*
                         // get all text
                         NSAttributedString *allText = [[v textView] textStorage];
                         // get index of match
                         NSRange destRange = [[allText string] rangeOfString:match];
                         
                         // now get glyph range for these character range
                         NSRange glyphRange = [[[v textView] layoutManager] glyphRangeForCharacterRange:destRange actualCharacterRange:nil];
                         // get view rect of this glyph range
                         NSRect destRect = [[[v textView] layoutManager] lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:nil];
                         */
                        
                        NSRect destRect = [self rectForAttributeName:TEXT_VERSE_MARKER attributeValue:sourceMarker inTextView:v.textView];
                        if(destRect.origin.x != NSNotFound) {
                            // the current horizontal textcontainer inset
                            float inset = 0.0;
                            if(hasDefaultsInset && destRect.origin.y != 0) {
                                inset = defaultsInset;    
                            }
                            
                            destPoint.x = destRect.origin.x;
                            destPoint.y = destRect.origin.y + inset;                                            
                        } else {
                            updateScroll = NO;                        
                        }
                    } else {
                        updateScroll = NO;
                    }                    
                }
            } else {
                // for all others we can't garantie that all view have the verse key
                destPoint = newOffset;
            }
            
            // if our synced position is different from our current
            // position, reposition our content view
            if (!NSEqualPoints(curOffset, changedBoundsOrigin) && updateScroll) {
                // note that a scroll view watching this one will
                // get notified here
                [[scrollView contentView] scrollToPoint:destPoint];
                // we have to tell the NSScrollView to update its
                // scrollers
                [scrollView reflectScrolledClipView:[scrollView contentView]];
            }        
        }
    }        
}

- (NSRange)rangeFromViewableFirstLineInTextView:(NSTextView *)theTextView lineRect:(NSRect *)lineRect {    
    if([theTextView enclosingScrollView]) {
        NSLayoutManager *layoutManager = [theTextView layoutManager];
        NSRect visibleRect = [theTextView visibleRect];
        
        NSPoint containerOrigin = [theTextView textContainerOrigin];
        visibleRect.origin.x -= containerOrigin.x;
        visibleRect.origin.y -= containerOrigin.y;
        
        NSRange glyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:[theTextView textContainer]];
        //NSRange glyphRange = [layoutManager glyphRangeForBoundingRectWithoutAdditionalLayout:visibleRect inTextContainer:[theTextView textContainer]];
        //CocoLog(LEVEL_DEBUG, @"glyphRange loc:%i len:%i", glyphRange.location, glyphRange.length);
        
        // get line range
        *lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:nil];
        //CocoLog(LEVEL_DEBUG, @"lineRect x:%f y:%f w:%f h:%f", lineRect->origin.x, lineRect->origin.y, lineRect->size.width, lineRect->size.height);
        
        NSRange lineRange = [layoutManager glyphRangeForBoundingRect:*lineRect inTextContainer:[theTextView textContainer]];
        //CocoLog(LEVEL_DEBUG, @"lineRange loc:%i len:%i", lineRange.location, lineRange.length);        
        
        return lineRange;
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (NSString *)verseMarkerInTextLine:(NSAttributedString *)text {
    NSString *ret = nil;
    
    // get the first found verseMarker attribute in the given text
    long len = [text length];
    for(NSUInteger i = 0;i < len;i++) {
        NSString * val = [text attribute:TEXT_VERSE_MARKER atIndex:i effectiveRange:nil];
        if(val != nil) {
            ret = val;
            break;
        }
    }
    
    return ret;
}

- (NSRect)rectForTextRange:(NSRange)range inTextView:(NSTextView *)textView {
    NSLayoutManager *layoutManager = [textView layoutManager];
    NSRect rect = [layoutManager lineFragmentRectForGlyphAtIndex:range.location effectiveRange:nil];
    return rect;
}

/**
 tries to find the given attribute value
 if not found, ret.origin.x == NSNotFound
 */
- (NSRect)rectForAttributeName:(NSString *)attrName attributeValue:(id)attrValue inTextView:(NSTextView *)textView {
    NSRect ret;
    ret.origin.x = NSNotFound;
    
    NSAttributedString *text = [textView attributedString];
    long len = [[textView string] length];
    NSRange foundRange;
    foundRange.location = NSNotFound;
    for(NSUInteger i = 0;i < len;i++) {
        id val = [text attribute:attrName atIndex:i effectiveRange:&foundRange];
        if(val != nil) {
            if([val isKindOfClass:[NSString class]] && [(NSString *)val isEqualToString:(NSString *)attrValue]) {
                break;
            } else {
                i = foundRange.location + foundRange.length;
                foundRange.location = NSNotFound;
            }
        }
    }
    
    if(foundRange.location != NSNotFound) {
        ret = [self rectForTextRange:foundRange inTextView:textView];
    }
    
    return ret;
}

- (NSString *)verseMarkerOfFirstLineOfTextView:(ScrollSynchronizableView *)syncView {
    // all bible views display all verse keys whether they are empty or not. But we can search for the verse location
    NSRect lineRect;
    NSRange lineRange = [self rangeFromViewableFirstLineInTextView:[syncView textView] lineRect:&lineRect];
    // try to get characters of textStorage
    NSAttributedString *attrString = [[[syncView textView] textStorage] attributedSubstringFromRange:NSMakeRange(lineRange.location, lineRange.length)];
    
    // now, that we have the first line, extract the verse Marker
    return [self verseMarkerInTextLine:attrString];    
}

@end
