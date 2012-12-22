//
//  SearchTextObject.h
//  Eloquent
//
//  Created by Manfred Bergmann on 21.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Indexer.h"

@interface SearchTextObject : NSObject <NSCoding> {
    // texts for search type
    NSMutableDictionary *searchTextsForTypes;
    // recent search arrays for search type
    NSMutableDictionary *recentSearchesForTypes;
    // the search type
    SearchType searchType;
}

@property (readwrite) SearchType searchType;

- (NSString *)searchTextForType:(SearchType)aType;
- (void)setSearchText:(NSString *)aText forSearchType:(SearchType)aType;
- (NSMutableArray *)recentSearchsForType:(SearchType)aType;
- (void)setRecentSearches:(NSMutableArray *)searches forSearchType:(SearchType)aType;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
