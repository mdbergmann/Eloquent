//
//  BookmarkManager.m
//  MacSword2
//
//  Created by Manfred Bergmann on 21.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkManager.h"
#import "globals.h"
#import "Bookmark.h"
#import "SwordListKey.h"
#import "SwordVerseKey.h"

@interface BookmarkManager ()

- (NSMutableArray *)loadBookmarks;
- (NSMutableArray *)_loadBookmarks:(NSArray *)group;

- (Bookmark *)_bookmarkForReference:(SwordVerseKey *)aVerseKey inList:(NSArray *)bookmarkList;

- (void)saveBookmarks;

@end

@implementation BookmarkManager

@dynamic bookmarks;

+ (BookmarkManager *)defaultManager {
    static BookmarkManager *instance;
    if(instance == nil) {
        instance = [[BookmarkManager alloc] init]; 
    }
    
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        [self setBookmarks:nil];
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

- (NSMutableArray *)bookmarks {
    if(bookmarks == nil) {
        // load
        [self setBookmarks:[self loadBookmarks]];
    }
    
    return bookmarks;
}

- (void)setBookmarks:(NSMutableArray *)bmarks {
    [bookmarks release];
    bookmarks = [bmarks retain];
}

- (NSMutableArray *)loadBookmarks {
    
    NSMutableArray *ret = nil;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // check for new boommarks file first
    NSString *bookmarkFile = DEFAULT_BOOKMARK_PATH;
    if([fm fileExistsAtPath:bookmarkFile] == YES) {
        NSData *data = [NSData dataWithContentsOfFile:bookmarkFile];
        if(data != nil) {
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            ret = [unarchiver decodeObjectForKey:@"Bookmarks"];
        }
    } else {
        // then check for old
        bookmarkFile = OLD_BOOKMARK_PATH;
        if([fm fileExistsAtPath:bookmarkFile] == YES) {
            // load from here
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bookmarkFile];
            // check for old style bookmarks
            NSArray *bmarks = [dict objectForKey:@"Bookmarks"];
            if(bmarks != nil) {
                ret = [self _loadBookmarks:bmarks];            
            }
        }
    }
    
    // still nil?
    if(ret == nil) {
        ret = [NSMutableArray array];
    }
    
    return ret;
}

/** load bookmarks recursive and build up a structure of Bookmark instances */
- (NSMutableArray *)_loadBookmarks:(NSArray *)group {
    NSMutableArray *bms = nil;

    if(group != nil) {
        // create mutable array that is passed to the data section of the bookmark as a subgroup
        bms = [NSMutableArray array];
        for(id item in group) {
            if([item isKindOfClass:[NSDictionary class]]) {
                NSDictionary *ditem = item;
                // create bookmark for dictionary
                Bookmark *bmark = [[Bookmark alloc] init];
                [bmark setName:[ditem objectForKey:@"name"]];
                [bmark setReference:[ditem objectForKey:@"reference"]];
                [bms addObject:bmark];
            } else if([item isKindOfClass:[NSArray class]]) {
                NSArray *aitem = item;
                // this is a subgroup
                // index 0 has the name of the node
                Bookmark *bmark = [[Bookmark alloc] initWithName:[aitem objectAtIndex:0]];
                // pass on
                [bmark setSubGroups:[self _loadBookmarks:aitem]];
                [bms addObject:bmark];
            }
        }
    }
    
    return bms;
}

- (void)saveBookmarks {
    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeObject:bookmarks forKey:@"Bookmarks"];
    [archiver finishEncoding];
    // write data object
    [data writeToFile:DEFAULT_BOOKMARK_PATH atomically:NO];    
}

/**
 delivers a bookmark that references the given verse key
 */
- (Bookmark *)bookmarkForReference:(SwordVerseKey *)aVerseKey {
    return [self _bookmarkForReference:aVerseKey inList:[self bookmarks]];
}

/**
 private method for recursively retrieves the first found bookmark that contains the given reference
 */
- (Bookmark *)_bookmarkForReference:(SwordVerseKey *)aVerseKey inList:(NSArray *)bookmarkList {    
    Bookmark *ret = nil;
    
    // loop over bookmarks in list
    for(Bookmark *bm in bookmarkList) {
        if([bm isLeaf]) {
            if([[bm reference] length] > 0) {
                SwordListKey *lk = [SwordListKey listKeyWithRef:[bm reference] versification:[aVerseKey versification]];
                if([lk containsKey:aVerseKey]) {
                    return bm;
                }                
            }
        } else {
            ret = [self _bookmarkForReference:aVerseKey inList:[bm subGroups]];
            if(ret) {
                break;
            }
        }
    }
    
    return ret;
}


@end
