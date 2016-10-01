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

@property (strong, readwrite) NSString *name;
@property (strong, readwrite) NSString *reference;
@property (strong, readwrite) NSString *comment;
@property (strong, readwrite) NSColor *foregroundColor;
@property (strong, readwrite) NSColor *backgroundColor;
@property (strong, readwrite) NSMutableArray *subGroups;
@property (readwrite) BOOL highlight;

- (id)initWithName:(NSString *)aName;
- (id)initWithName:(NSString *)aName ref:(NSString *)aReference;

- (NSInteger)childCount;
- (BOOL)isLeaf;

@end
