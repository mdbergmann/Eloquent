//
//  NSTextView+LookupAdditions.m
//  Eloquent
//
//  Created by Manfred Bergmann on 09.12.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "NSTextView+LookupAdditions.h"


@implementation NSTextView (LookupAdditions)

/**
 Delivers the range of the first visible line in the textview.
 @param[out] lineRect the rect of that first line
 @return the range of first line
 */
- (NSRange)rangeOfFirstLineWithLineRect:(NSRect *)lineRect {    
    if([self enclosingScrollView]) {
        NSLayoutManager *layoutManager = [self layoutManager];
        NSRect visibleRect = [self visibleRect];
        
        NSPoint containerOrigin = [self textContainerOrigin];
        visibleRect.origin.x -= containerOrigin.x;
        visibleRect.origin.y -= containerOrigin.y;
        
        NSRange glyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:[self textContainer]];

        // get line rect
        *lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:nil];

        // get range
        NSRange lineRange = [layoutManager glyphRangeForBoundingRect:*lineRect inTextContainer:[self textContainer]];

        return lineRange;
    }
    
    return NSMakeRange(NSNotFound, 0);
}

/**
 Delivers the range of the line at the given character index location
 @param[in] index location
 @return the range of line
 */
- (NSRange)rangeOfLineAtIndex:(NSUInteger)index {
    if([self enclosingScrollView]) {
        NSLayoutManager *layoutManager = [self layoutManager];
        // get line rect
        NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:nil];
        
        // get range
        NSRange lineRange = [layoutManager glyphRangeForBoundingRect:lineRect inTextContainer:[self textContainer]];
        
        return lineRange;
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (NSRect)rectOfFirstLine {
    NSRect visibleRect = [self visibleRect];
    NSPoint containerOrigin = [self textContainerOrigin];
    visibleRect.origin.x -= containerOrigin.x;
    visibleRect.origin.y -= containerOrigin.y;
    
    return NSMakeRect(0.0, visibleRect.origin.y, visibleRect.size.width, 15.0);
}

- (NSRect)rectOfLastLine {
    NSRect visibleRect = [self visibleRect];
    NSPoint containerOrigin = [self textContainerOrigin];
    visibleRect.origin.x -= containerOrigin.x;
    visibleRect.origin.y -= containerOrigin.y;
    
    return NSMakeRect(0.0, visibleRect.size.height, visibleRect.size.width, 15.0);    
}

/**
 Delivers the range of the visible text in textview.
 @return the range of visible text
 */
- (NSRange)rangeOfVisibleText {
    if([self enclosingScrollView]) {
        NSLayoutManager *layoutManager = [self layoutManager];
        NSRect visibleRect = [self visibleRect];
        
        NSPoint containerOrigin = [self textContainerOrigin];
        visibleRect.origin.x -= containerOrigin.x;
        visibleRect.origin.y -= containerOrigin.y;
        
        NSRange glyphRange = [layoutManager glyphRangeForBoundingRectWithoutAdditionalLayout:visibleRect inTextContainer:[self textContainer]];
        //CocoLog(LEVEL_DEBUG, @"glyphRange loc:%i len:%i", glyphRange.location, glyphRange.length);
        return glyphRange;
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (NSRange)rangeOfTextToken:(NSString *)token lastFound:(NSRange)lastFoundRange directionRight:(BOOL)right {
    NSRange ret;
    
    // get text
    NSString *text = [[self textStorage] string];
    NSUInteger startIndex;
    NSUInteger stopIndex;
    NSStringCompareOptions mask = 0;
    
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
    NSLayoutManager *layoutManager = [self layoutManager];
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
    
    NSAttributedString *text = [self attributedString];
    NSUInteger len = [[self string] length];
    NSRange foundRange;
    foundRange.location = NSNotFound;
    for(NSUInteger i = 0;i < len;i++) {
        id val = [text attribute:attrName atIndex:i effectiveRange:&foundRange];
        if(val != nil) {
            if([val isKindOfClass:[NSString class]] && [(NSString *)val isEqualToString:(NSString *)attrValue]) {
                CocoLog(LEVEL_DEBUG, @"found attribute");
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

- (NSString *)selectedString {
    return [[self selectedAttributedString] string];
}

- (NSAttributedString *)selectedAttributedString {
    NSAttributedString *ret = [[[NSAttributedString alloc] init] autorelease];
    
    NSRange selRange = [self selectedRange];
    if(selRange.length > 0) {
        ret = [[self attributedString] attributedSubstringFromRange:selRange];
    }    
    
    return ret;
}

@end
