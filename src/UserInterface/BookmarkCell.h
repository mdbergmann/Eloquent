//
//  BookmarkCell.h
//  Eloquent
//
//  Created by Manfred Bergmann on 27.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Bookmark;

@interface BookmarkCell : NSCell {
    NSImage *image;
    Bookmark *bookmark;
    NSFont *bmRefFont;
}

@property (retain, readwrite) NSImage *image;
@property (retain, readwrite) Bookmark *bookmark;

@end
