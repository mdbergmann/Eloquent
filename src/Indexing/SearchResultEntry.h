//
//  SearchResultEntry.h
//  Eloquent
//
//  Created by Manfred Bergmann on 02.06.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

// result dictionary property key names
#define IndexPropDocName @"DocumentName"
#define IndexPropDocScore @"DocumentScore"
#define IndexPropSwordKeyString @"SwordKeyString"
#define IndexPropSwordStrongString @"SwordStrongString"

@interface SearchResultEntry : NSObject
{
    NSMutableDictionary *properties;
}

- (id)init;
- (id)initWithDictionary:(NSDictionary *)aDict;

// general methods for adding and getting properties
- (void)addObject:(NSObject *)object forKey:(NSObject *)key;
- (id)objectForKey:(NSObject *)key;

// convenient methods
- (NSString *)documentName;
- (NSNumber *)documentScore;
- (NSString *)keyString;

/**
 \brief take care for compare: operations
 this method returns the document name property
 */
- (NSString *)description;

@end
