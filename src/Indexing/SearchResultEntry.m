//
//  SearchResultEntry.m
//  Eloquent
//
//  Created by Manfred Bergmann on 02.06.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import "SearchResultEntry.h"


@interface SearchResultEntry (PrivateAPI)

- (void)setProperties:(NSMutableDictionary *)dict;

@end

@implementation SearchResultEntry (PrivateAPI)

- (void)setProperties:(NSMutableDictionary *)dict {
    [dict retain];
    [properties release];
    properties = dict;
}

@end


@implementation SearchResultEntry

- (id)init {
    self = [self initWithDictionary:[NSMutableDictionary dictionary]];
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)aDict {
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc SearchResultEntry!");
	} else {
        [self setProperties:[NSMutableDictionary dictionaryWithDictionary:aDict]];
	}
	
	return self;
}

- (void)dealloc {
	[self setProperties:nil];
    
	[super dealloc];
}

// general methods for adding and getting properties
- (void)addObject:(NSObject *)object forKey:(NSObject *)key {
    if((object == nil) || (key == nil)) {
        CocoLog(LEVEL_ERR, @"object or key = nil!");
    } else {
        [properties setObject:object forKey:key];
    }
}

- (id)objectForKey:(NSObject *)key {
    NSObject *ret = nil;
    
    if(key == nil) {
        CocoLog(LEVEL_ERR, @"key = nil!");
    } else {
        ret = [properties objectForKey:key];
    }
    
    return ret;
}

// convenient methods
- (NSString *)documentName {
    return (NSString *)[self objectForKey:IndexPropDocName];
}

- (NSNumber *)documentScore {
    return (NSNumber *)[self objectForKey:IndexPropDocScore];
}

- (NSString *)keyString {
    return (NSString *)[self objectForKey:IndexPropSwordKeyString];
}

/**
\brief take care for compare: operations
 this method returns the document name property
 */
- (NSString *)description {
    return [self documentName];
}

@end
