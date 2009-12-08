//
//  ThreeCellsCell.h
//  ThreeCellsCell
//
//  Created by Manfred Bergmann on 16.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ThreeCellsCell : NSTextFieldCell {
    NSImage *image;
    NSImage *rightImage;
    NSFont *countFont;
    int rightCounter;
    int leftCounter;
}

@property (retain, readwrite) NSImage *image;
@property (retain, readwrite) NSImage *rightImage;
@property (readwrite) int rightCounter;
@property (readwrite) int leftCounter;

@end
