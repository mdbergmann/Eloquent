//
//  OutlineListObject.m
//  MacSword2
//
//  Created by Manfred Bergmann on 10.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "OutlineListObject.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SwordModCategory.h"
#import "BookmarkManager.h"
#import "Bookmark.h"

@implementation OutlineListObject

@synthesize listObject;
@synthesize type;
@synthesize path;

- (id)initWithObject:(id)anObject {
    self = [super init];
    if(self) {
        self.listObject = anObject;
        self.type = OutlineItemUnset;
        self.path = nil;
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

- (BOOL)isRoot {
    OutlineListObjectType t = [self objectType];
    if(t == OutlineItemModuleRoot || t == OutlineItemBookmarkRoot) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isLeaf {
    OutlineListObjectType t = [self objectType];
    if(t == OutlineItemModule || t == OutlineItemBookmark) {
        return YES;
    }
    
    return NO;
}

- (NSString *)displayString {
    OutlineListObjectType t = [self objectType];
    if(t == OutlineItemModuleRoot) {
        return NSLocalizedString(@"LSBModules", @"");
    } else if(t == OutlineItemBookmarkRoot) {
        return NSLocalizedString(@"LSBBookmarks", @"");
    } else {
        return [listObject description];
    }
}

- (OutlineListObjectType)objectType {
    OutlineListObjectType ret = type;
    
    if(type == OutlineItemUnset) {
        if([listObject isKindOfClass:[SwordModCategory class]]) {
            ret = OutlineItemModuleCategory;
        } else if([listObject isKindOfClass:[SwordModule class]]) {
            ret = OutlineItemModule;
        } else if([listObject isKindOfClass:[Bookmark class]]) {
            Bookmark *bm = listObject;
            if([bm isLeaf]) {
                ret = OutlineItemBookmark;
            } else {
                ret = OutlineItemBookmarkDir;
            }
        }
    }
    
    return ret;
}

- (NSArray *)children {
    NSMutableArray *ret = [NSMutableArray array];
    
    OutlineListObjectType t = [self objectType];
    if(t == OutlineItemModuleRoot) {
        // get categories
        NSArray *types = [SwordModCategory moduleCategories];
        for(SwordModCategory *mt in types) {
            OutlineListObject *o = [[OutlineListObject alloc] initWithObject:mt];
            [ret addObject:o];
        }
    } else if(t == OutlineItemBookmarkRoot) {
        // get first level bookmarks
        NSArray *bms = [[BookmarkManager defaultManager] bookmarks];
        for(Bookmark *bm in bms) {
            OutlineListObject *o = [[OutlineListObject alloc] initWithObject:bm];
            [ret addObject:o];
        }
    } else if(t == OutlineItemModuleCategory) {
        // get modules in this category
        SwordModCategory *cat = listObject;
        NSArray *mods = [[SwordManager defaultManager] modulesForType:[cat name]];
        for(SwordModule *mod in mods) {
            OutlineListObject *o = [[OutlineListObject alloc] initWithObject:mod];
            [ret addObject:o];            
        }
    } else if(t == OutlineItemBookmarkDir) {
        // get sub bookmarks
        Bookmark *bm = listObject;
        NSArray *bms = [bm subGroups];
        for(Bookmark *b in bms) {
            OutlineListObject *o = [[OutlineListObject alloc] initWithObject:b];
            [ret addObject:o];            
        }
    }
    
    return ret;
}

@end
