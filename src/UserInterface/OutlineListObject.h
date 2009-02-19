//
//  OutlineListObject.h
//  MacSword2
//
//  Created by Manfred Bergmann on 10.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum OutlineListObjectType{
    OutlineItemUnset,
    OutlineItemModuleRoot = 10,
    OutlineItemModuleCategory,
    OutlineItemModule,
    OutlineItemBookmarkRoot = 20,
    OutlineItemBookmarkDir,
    OutlineItemBookmark,
}OutlineListObjectType;

@interface OutlineListObject : NSObject {
    id listObject;
    OutlineListObjectType type;
    NSIndexPath *path;
}

@property (retain, readwrite) id listObject;
@property (readwrite) OutlineListObjectType type;
@property (retain, readwrite) NSIndexPath *path;

- (id)initWithObject:(id)anObject;

- (BOOL)isRoot;
- (BOOL)isLeaf;
- (OutlineListObjectType)objectType;
- (NSString *)displayString;
- (NSArray *)children;

@end
