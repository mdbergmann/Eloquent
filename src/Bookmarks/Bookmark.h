//
//  Bookmark.h
//  Eloquent
//
//  Created by Manfred Bergmann on 21.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Bookmark : NSObject <NSCoding> {
	NSString *name;
	NSString *reference;
    NSColor *foregroundColor;
    NSColor *backgroundColor;
    NSString *comment;
	NSMutableArray *subGroups;
    BOOL highlight;
}

@property (retain, readwrite) NSString *name;
@property (retain, readwrite) NSString *reference;
@property (retain, readwrite) NSString *comment;
@property (retain, readwrite) NSColor *foregroundColor;
@property (retain, readwrite) NSColor *backgroundColor;
@property (retain, readwrite) NSMutableArray *subGroups;
@property (readwrite) BOOL highlight;

- (id)initWithName:(NSString *)aName;
- (id)initWithName:(NSString *)aName ref:(NSString *)aReference;

- (int)childCount;
- (BOOL)isLeaf;

@end
