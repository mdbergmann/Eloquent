//
//  BookmarkDragItem.m
//  MacSword2
//
//  Created by Manfred Bergmann on 18.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkDragItem.h"
#import "Bookmark.h"


@implementation BookmarkDragItem

@synthesize path;
@synthesize bookmark;

- (id)init {
    self = [super init];
    if(self) {
        self.path = [NSIndexPath indexPathWithIndex:0];
        self.bookmark = [[Bookmark alloc] init];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    BookmarkDragItem *item = [[BookmarkDragItem alloc] init];
    item.bookmark = [decoder decodeObjectForKey:@"Bookmark"];
    item.path = [decoder decodeObjectForKey:@"IndexPath"];
    
    return item;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:bookmark forKey:@"Bookmark"];
    [encoder encodeObject:path forKey:@"IndexPath"];
}

@end
