//
//  BookmarkDragItem.h
//  Eloquent
//
//  Created by Manfred Bergmann on 18.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@class Bookmark;

@interface BookmarkDragItem : NSObject  <NSCoding> {
    NSIndexPath *path;
    Bookmark *bookmark;
}

@property (retain, readwrite) NSIndexPath *path;
@property (retain, readwrite) Bookmark *bookmark;

@end
