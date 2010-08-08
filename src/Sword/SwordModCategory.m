//
//  SwordModCategory.m
//  MacSword2
//
//  Created by Manfred Bergmann on 23.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SwordModCategory.h"
#import "ObjCSword/SwordManager.h"


@implementation SwordModCategory

@synthesize type;

+ (NSArray *)moduleCategories {
    static NSArray *cats;
    if(cats == nil) {
        cats = [NSArray arrayWithObjects:
                [[SwordModCategory alloc] initWithType:Bible], 
                [[SwordModCategory alloc] initWithType:Commentary],
                [[SwordModCategory alloc] initWithType:Dictionary],
                [[SwordModCategory alloc] initWithType:Genbook], nil];
    }
    
    return cats;
}

- (id)initWithType:(ModuleType)aType {
    self = [super init];
    if(self) {
        [self setType:aType];
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [super dealloc];
}

- (NSString *)name {
    NSString *ret = @"";
    
    switch(type) {
        case Bible:
            ret = SWMOD_TYPES_BIBLES;
            break;
        case Commentary:
            ret = SWMOD_TYPES_COMMENTARIES;
            break;
        case Dictionary:
            ret = SWMOD_TYPES_DICTIONARIES;
            break;
        case Genbook:
            ret = SWMOD_TYPES_GENBOOKS;
            break;
    }
    
    return ret;    
}

- (NSString *)description {    
    return NSLocalizedString([self name], @"");
}

@end
