//
//  SwordModCategory.m
//  MacSword2
//
//  Created by Manfred Bergmann on 23.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SwordModCategory.h"
#import "SwordManager.h"


@implementation SwordModCategory

@synthesize type;

+ (NSArray *)moduleCategories {
    static NSArray *cats;
    if(cats == nil) {
        cats = [NSArray arrayWithObjects:
                [[SwordModCategory alloc] initWithType:bible], 
                [[SwordModCategory alloc] initWithType:commentary],
                [[SwordModCategory alloc] initWithType:dictionary],
                [[SwordModCategory alloc] initWithType:genbook], nil];
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

- (NSString *)name {
    NSString *ret = @"";
    
    switch(type) {
        case bible:
            ret = SWMOD_CATEGORY_BIBLES;
            break;
        case commentary:
            ret = SWMOD_CATEGORY_COMMENTARIES;
            break;
        case devotional:
        case dictionary:
            ret = SWMOD_CATEGORY_DICTIONARIES;
            break;
        case genbook:
            ret = SWMOD_CATEGORY_GENBOOKS;
            break;
    }
    
    return ret;    
}

- (NSString *)description {    
    return NSLocalizedString([self name], @"");
}

@end
