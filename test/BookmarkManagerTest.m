//
//  BookmarkManagerTest.m
//  Eloquent
//
//  Created by Manfred Bergmann on 22.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BookmarkManagerTest.h"
#import "BookmarkManager.h"


@implementation BookmarkManagerTest

- (void)testLoadBookmarks {
    BookmarkManager *manager = [BookmarkManager defaultManager];
    STAssertNotNil(manager, @"manager is nil");
    
    NSArray *bmarks = [manager bookmarks];
    STAssertNotNil(bmarks, @"boookmarks nil");
}

@end
