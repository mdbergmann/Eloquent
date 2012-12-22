//
//  SearchTextObject.m
//  Eloquent
//
//  Created by Manfred Bergmann on 21.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SearchTextObject.h"
#import "Indexer.h"

@interface SearchTextObject ()

@property (retain, readwrite) NSMutableDictionary *searchTextsForTypes;
@property (retain, readwrite) NSMutableDictionary *recentSearchesForTypes;

@end

@implementation SearchTextObject

@synthesize searchTextsForTypes;
@synthesize recentSearchesForTypes;
@synthesize searchType;

- (id)init {
    self = [super init];
    if(self) {
        [self setSearchTextsForTypes:[NSMutableDictionary dictionary]];
        [self setRecentSearchesForTypes:[NSMutableDictionary dictionary]];
    }
    
    return self;
}

- (void)dealloc {
    [searchTextsForTypes release];
    [recentSearchesForTypes release];
    [super dealloc];
}

- (void)finalize {
    [super finalize];
}

/**
 return the search text for the given type
 */
- (NSString *)searchTextForType:(SearchType)aType {
    NSString *searchText = [searchTextsForTypes objectForKey:[NSNumber numberWithInt:aType]];
    if(searchText == nil) {
        searchText = @"";
        [self setSearchText:searchText forSearchType:aType];
    }
    
    return searchText;
}

/**
 sets search text for search type
 */
- (void)setSearchText:(NSString *)aText forSearchType:(SearchType)aType {
    [searchTextsForTypes setObject:aText forKey:[NSNumber numberWithInt:aType]];
}

- (NSMutableArray *)recentSearchsForType:(SearchType)aType {
    NSMutableArray *recentSearches = [recentSearchesForTypes objectForKey:[NSNumber numberWithInt:aType]];
    
    if(recentSearches == nil) {
        recentSearches = [NSMutableArray array];
        [self setRecentSearches:recentSearches forSearchType:aType];
    }
    
    return recentSearches;
}

- (void)setRecentSearches:(NSMutableArray *)searches forSearchType:(SearchType)aType {
    [recentSearchesForTypes setObject:searches forKey:[NSNumber numberWithInt:aType]];
}        

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    
    SearchTextObject *obj = [[[SearchTextObject alloc] init] autorelease];
    
    // decode searchQuery
    obj.searchTextsForTypes = [decoder decodeObjectForKey:@"SearchTextsForTypesEncoded"];
    // decode recent searches
    obj.recentSearchesForTypes = [decoder decodeObjectForKey:@"RecentSearchesForTypesEncoded"];
    
    return obj;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode searchQuery
    [encoder encodeObject:searchTextsForTypes forKey:@"SearchTextsForTypesEncoded"];
    // encode searchQuery
    [encoder encodeObject:recentSearchesForTypes forKey:@"RecentSearchesForTypesEncoded"];
}

@end
