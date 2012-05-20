//
//  Bookmark.m
//  Eloquent
//
//  Created by Manfred Bergmann on 21.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Bookmark.h"


@implementation Bookmark

@synthesize name;
@synthesize reference;
@synthesize comment;
@synthesize foregroundColor;
@synthesize backgroundColor;
@synthesize subGroups;
@synthesize highlight;

- (id)init {
    return [self initWithName:@""];
}

- (id)initWithName:(NSString *)aName {
    return [self initWithName:aName ref:@""];
}

- (id)initWithName:(NSString *)aName ref:(NSString *)aReference {
    self = [super init];
    if(self) {
        [self setName:aName];
        [self setReference:aReference];
        [self setComment:@""];
        [self setSubGroups:nil];
        [self setForegroundColor:[NSColor blackColor]];
        [self setBackgroundColor:[NSColor whiteColor]];
        [self setHighlight:NO];
    }
    
    return self;
}

- (void)dealloc {
    [name release];
    [reference release];
    [comment release];
    [foregroundColor release];
    [backgroundColor release];
    [subGroups release];

    [super dealloc];
}

- (int)childCount {
    int ret = 0;
    if(subGroups) {
        ret = [subGroups count];
    }
    return ret;
}

- (BOOL)isLeaf {
    return subGroups == nil ? YES : NO;
}

- (NSString *)description {
    return name;
}

#pragma mark NSCoding implementation

- (id)initWithCoder:(NSCoder *)decoder {
    Bookmark *bm = [[[Bookmark alloc] init] autorelease];
    
    [bm setName:[decoder decodeObjectForKey:@"BookmarkName"]];
    [bm setReference:[decoder decodeObjectForKey:@"BookmarkRef"]];
    [bm setComment:[decoder decodeObjectForKey:@"BookmarkComment"]];
    NSColor *col = [decoder decodeObjectForKey:@"BookmarkForegroundColor"];
    [bm setForegroundColor:col == nil ? [NSColor blackColor] : col];
    col = [decoder decodeObjectForKey:@"BookmarkBackgroundColor"];
    [bm setBackgroundColor:col == nil ? [NSColor whiteColor] : col];

    // change: in former version subGroups was never nil. Now it is nil if it is a leaf
    NSMutableArray *subgroups = [decoder decodeObjectForKey:@"BookmarkSubgroup"];
    if(subgroups && [subgroups count] == 0) {
        subgroups = nil;
    } 
    [bm setSubGroups:subgroups];
    [bm setHighlight:[decoder decodeBoolForKey:@"BookmarkHighlight"]];

    return bm;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:name forKey:@"BookmarkName"];
    [encoder encodeObject:reference forKey:@"BookmarkRef"];
    [encoder encodeObject:comment forKey:@"BookmarkComment"];
    [encoder encodeObject:foregroundColor forKey:@"BookmarkForegroundColor"];
    [encoder encodeObject:backgroundColor forKey:@"BookmarkBackgroundColor"];
    [encoder encodeObject:subGroups forKey:@"BookmarkSubgroup"];
    [encoder encodeBool:highlight forKey:@"BookmarkHighlight"];
}

@end
