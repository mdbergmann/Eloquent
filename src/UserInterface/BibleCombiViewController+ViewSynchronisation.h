//
//  BibleCombiViewController+ViewSynchronisation.h
//  Eloquent
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BibleCombiViewController.h"


@interface BibleCombiViewController (ViewSynchronisation)

- (void)stopScrollSynchronizationForView:(NSScrollView *)aView;
- (void)establishScrollSynchronization:(NSScrollView *)scrollView;
- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)aNotification;

- (NSRange)rangeFromViewableFirstLineInTextView:(NSTextView *)theTextView lineRect:(NSRect *)lineRect;
- (NSString *)verseMarkerInTextLine:(NSAttributedString *)text;
- (NSRect)rectForTextRange:(NSRange)range inTextView:(NSTextView *)textView;
- (NSRect)rectForAttributeName:(NSString *)attrName attributeValue:(id)attrValue inTextView:(NSTextView *)textView;
- (NSString *)verseMarkerOfFirstLineOfTextView:(ScrollSynchronizableView *)syncView;

@end
