//
//  NSTextView+LookupAdditions.h
//  Eloquent
//
//  Created by Manfred Bergmann on 09.12.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>


@interface NSTextView (LookupAdditions)

- (NSRange)rangeOfFirstLineWithLineRect:(NSRect *)lineRect;
- (NSRange)rangeOfLineAtIndex:(NSUInteger)index;
- (NSRect)rectOfFirstLine;
- (NSRect)rectOfLastLine;
- (NSRange)rangeOfVisibleText;
- (NSRange)rangeOfTextToken:(NSString *)token lastFound:(NSRange)lastFoundRange directionRight:(BOOL)right;
- (NSRect)rectForTextRange:(NSRange)range;
- (NSRect)rectForAttributeName:(NSString *)attrName attributeValue:(id)attrValue;
- (NSAttributedString *)selectedAttributedString;
- (NSString *)selectedString;

@end
