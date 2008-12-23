//
//  Bookmark.h
//  MacSword2
//
//  Created by Manfred Bergmann on 21.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Bookmark : NSObject <NSCoding> {
	NSString *name;
	NSString *reference;
	NSNumber *colour;
	NSMutableArray *subGroups;
}

@property (retain, readwrite) NSString *name;
@property (retain, readwrite) NSString *reference;
@property (retain, readwrite) NSNumber *colour;
@property (retain, readwrite) NSMutableArray *subGroups;

- (id)initWithName:(NSString *)aName;
- (id)initWithName:(NSString *)aName ref:(NSString *)aReference;

- (int)childCount;
- (BOOL)isLeaf;

- (int)hash;

@end
