//
//  ThreeCellsCell.h
//  ThreeCellsCell
//
//  Created by Manfred Bergmann on 16.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ThreeCellsCell : NSCell {
    NSImage *image;
    NSNumber *numberValue;
    NSColor *textColor;
    NSFont *textFont;
}

@property (retain, readwrite) NSImage *image;
@property (retain, readwrite) NSColor *textColor;
@property (retain, readwrite) NSNumber *numberValue;
@property (retain, readwrite) NSFont *textFont;

@end
