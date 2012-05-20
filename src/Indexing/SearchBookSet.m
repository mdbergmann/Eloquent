//
//  SearchBookSet.m
//  Eloquent
//
//  Created by Manfred Bergmann on 18.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchBookSet.h"

@interface SearchBookSet ()
@property (retain, readwrite) NSMutableDictionary *osisBookNames;
@end

@implementation SearchBookSet

@synthesize name;
@synthesize osisBookNames;
@synthesize isPredefined;

+ (id)searchBookSetWithName:(NSString *)aName {
    return [[[SearchBookSet alloc] initWithName:aName] autorelease];
}

- (id)init {
    self = [super init];
    if(self) {
        self.name = @"";
        self.osisBookNames = [NSMutableDictionary dictionary];
        self.isPredefined = NO;
    }
    
    return self;
}

- (id)initWithName:(NSString *)aName {
    self = [self init];
    if(self) {
        self.name = aName;
    }
    
    return self;
}

- (void)dealloc {
    [name release];
    [osisBookNames release];
    [super dealloc];
}

- (int)count {
    return [osisBookNames count];
}

- (BOOL)containsBook:(NSString *)bookName {
    return ([osisBookNames objectForKey:bookName] != nil);
}

- (void)addBook:(NSString *)bookName {
    [osisBookNames setObject:bookName forKey:bookName];
}

- (void)addFromArray:(NSArray *)bookNames {
    for(NSString *aName in bookNames) {
        [self addBook:aName];
    }
}

- (void)removeBook:(NSString *)bookName {
    [osisBookNames removeObjectForKey:bookName];
}

- (void)removeAll {
    [osisBookNames removeAllObjects];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    
    SearchBookSet *obj = [[SearchBookSet alloc] init];
    
    obj.name = [decoder decodeObjectForKey:@"NameEncoded"];
    obj.osisBookNames = [[[decoder decodeObjectForKey:@"OSISBookNamesEncoded"] mutableCopy] autorelease];
    obj.isPredefined = [decoder decodeBoolForKey:@"PredefinedEncoded"];
    
    return obj;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:name forKey:@"NameEncoded"];
    [encoder encodeObject:osisBookNames forKey:@"OSISBookNamesEncoded"];
    [encoder encodeBool:isPredefined forKey:@"PredefinedEncoded"];
}

@end
