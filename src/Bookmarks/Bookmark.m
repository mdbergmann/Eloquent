//
//  Bookmark.m
//  MacSword2
//
//  Created by Manfred Bergmann on 21.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Bookmark.h"


@implementation Bookmark

@synthesize name;
@synthesize reference;
@synthesize comment;
@synthesize colour;
@synthesize subGroups;

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
        [self setSubGroups:[NSMutableArray array]];
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

- (int)childCount {
    return [subGroups count];
}
- (BOOL)isLeaf {
    return [self childCount] == 0 ? YES : NO;
}

- (NSString *)description {
    return name;
}

- (int)hash {
    // let's build a hash that is unique
    int ret = 0;
    
    // count all characters that we have here
    int len = [name length];
    for(int i = 0;i < len;i++) {
        unichar c = [name characterAtIndex:i];
        ret += c;
    }
    len = [reference length];
    for(int i = 0;i < len;i++) {
        unichar c = [reference characterAtIndex:i];
        ret += c;
    }
    // instance
    char pointer[256];
    bzero(pointer, 256);
    sprintf(pointer, "%x", (unsigned int)self);
    for(int i = 0;i < 256;i++) {
        ret += pointer[i];
    }
    
    return ret;
}

// --------- NSCoding implementation ----------------
#pragma mark NSCoding implementation

- (id)initWithCoder:(NSCoder *)decoder {
    Bookmark *bm = [[Bookmark alloc] init];
    [bm setName:[decoder decodeObjectForKey:@"BookmarkName"]];
    [bm setReference:[decoder decodeObjectForKey:@"BookmarkRef"]];
    [bm setComment:[decoder decodeObjectForKey:@"BookmarkComment"]];
    [bm setColour:[decoder decodeObjectForKey:@"BookmarkColor"]];
    [bm setSubGroups:[decoder decodeObjectForKey:@"BookmarkSubgroup"]];
    
    return bm;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:name forKey:@"BookmarkName"];
    [encoder encodeObject:reference forKey:@"BookmarkRef"];
    [encoder encodeObject:comment forKey:@"BookmarkComment"];
    [encoder encodeObject:colour forKey:@"BookmarkColor"];
    [encoder encodeObject:subGroups forKey:@"BookmarkSubgroup"];
}

@end
