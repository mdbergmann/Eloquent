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
    OutlineItemModuleRoot,
    OutlineItemModuleCategory,
    OutlineItemModule,
    OutlineItemBookmarkRoot,
    OutlineItemBookmarkDir,
    OutlineItemBookmark,    
}OutlineListObjectType;

@interface OutlineListObject : NSObject {
    id listObject;
    OutlineListObjectType type;
}

@property (retain, readwrite) id listObject;
@property (readwrite) OutlineListObjectType type;

- (id)initWithObject:(id)anObject;

- (BOOL)isRoot;
- (BOOL)isLeaf;
- (OutlineListObjectType)objectType;
- (NSString *)displayString;
- (NSArray *)children;

@end
