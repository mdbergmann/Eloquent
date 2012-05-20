//
//  BookmarkManager.m
//  Eloquent
//
//  Created by Manfred Bergmann on 21.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkManager.h"
#import "globals.h"
#import "Bookmark.h"
#import "ObjCSword/SwordListKey.h"
#import "ObjCSword/SwordVerseKey.h"

@interface BookmarkManager ()

- (NSMutableArray *)loadBookmarks;
- (NSMutableArray *)_loadBookmarks:(NSArray *)group;
- (Bookmark *)_bookmarkForReference:(SwordVerseKey *)aVerseKey inList:(NSArray *)bookmarkList;
- (void)saveBookmarks;
- (int)getIndexPath:(NSMutableArray *)reverseIndex forBookmark:(Bookmark *)bm inList:(NSArray *)list;

@end

@implementation BookmarkManager

@dynamic bookmarks;

+ (BookmarkManager *)defaultManager {
    static BookmarkManager *instance = nil;
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

- (void)dealloc {
    [bookmarks release];
    [super dealloc];
}

- (NSMutableArray *)bookmarks {
    if(bookmarks == nil) {
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
    
    // check for new bookmarks file first
    NSString *bookmarkFile = DEFAULT_BOOKMARK_PATH;
    if([fm fileExistsAtPath:bookmarkFile] == YES) {
        NSData *data = [NSData dataWithContentsOfFile:bookmarkFile];
        if(data != nil) {
            NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
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
                Bookmark *bmark = [[[Bookmark alloc] init] autorelease];
                [bmark setName:[ditem objectForKey:@"name"]];
                [bmark setReference:[ditem objectForKey:@"reference"]];
                [bms addObject:bmark];
            } else if([item isKindOfClass:[NSArray class]]) {
                NSArray *aitem = item;
                // this is a subgroup
                // index 0 has the name of the node
                Bookmark *bmark = [[[Bookmark alloc] initWithName:[aitem objectAtIndex:0]] autorelease];
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
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
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
                SwordListKey *lk = [SwordListKey listKeyWithRef:[bm reference] v11n:[aVerseKey versification]];
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

- (BOOL)deleteBookmark:(Bookmark *)aBookmark {
    return [self deleteBookmarkForPath:[self indexPathForBookmark:aBookmark]];
}

- (BOOL)deleteBookmarkForPath:(NSIndexPath *)path {
    NSMutableArray *list = [self bookmarks];
    for(NSUInteger i = 0;i < [path length] - 1;i++) {
        Bookmark *b = [list objectAtIndex:[path indexAtPosition:i]];
        list = [b subGroups];
    }
    
    if(list) {
        [list removeObjectAtIndex:[path indexAtPosition:[path length] - 1]];
        return YES;
    }
    
    return NO;
}

- (NSIndexPath *)indexPathForBookmark:(Bookmark *)bm {
    NSMutableArray *reverseIndex = [NSMutableArray array];
    [self getIndexPath:reverseIndex forBookmark:bm inList:[self bookmarks]];
    NSUInteger len = [reverseIndex count];
    NSUInteger indexes[len];
    for(NSUInteger i = 0;i < len;i++) {
        indexes[len-1 - i] = (NSUInteger)[[reverseIndex objectAtIndex:i] intValue];
    }

    NSIndexPath *ret = [[[NSIndexPath alloc] initWithIndexes:indexes length:len] autorelease];
    return ret;
}

- (int)getIndexPath:(NSMutableArray *)reverseIndex forBookmark:(Bookmark *)bm inList:(NSArray *)list {
    if(list && [list count] > 0) {
        for(NSUInteger i = 0;i < [list count];i++) {
            Bookmark *b = [list objectAtIndex:i];
            if(bm != b) {
                NSInteger index = [self getIndexPath:reverseIndex forBookmark:bm inList:[b subGroups]];
                if(index > -1) {
                    // record
                    [reverseIndex addObject:[NSNumber numberWithInt:i]];
                    return i;
                }
            } else {
                // record
                [reverseIndex addObject:[NSNumber numberWithInt:i]];
                return i;
            }
        }        
    }
    
    return -1;
}

@end
