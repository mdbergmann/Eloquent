//
//  SearchBookSet.h
//  Eloquent
//
//  Created by Manfred Bergmann on 18.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchBookSet : NSObject <NSCoding> {
    NSString *name;
    NSMutableDictionary *osisBookNames;
    BOOL isPredefined;
}

@property (retain, readwrite) NSString *name;
@property (readwrite) BOOL isPredefined;

+ (id)searchBookSetWithName:(NSString *)aName;
- (id)initWithName:(NSString *)aName;

- (int)count;
- (BOOL)containsBook:(NSString *)bookName;
- (void)addBook:(NSString *)bookName;
- (void)addFromArray:(NSArray *)bookNames;
- (void)removeBook:(NSString *)bookName;
- (void)removeAll;

@end
