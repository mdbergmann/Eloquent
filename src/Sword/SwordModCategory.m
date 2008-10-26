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

@synthesize name;

+ (NSArray *)moduleCategories {
    static NSArray *cats;
    if(cats == nil) {
        cats = [NSArray arrayWithObjects:
                [[SwordModCategory alloc] initWithName:SWMOD_CATEGORY_BIBLES], 
                [[SwordModCategory alloc] initWithName:SWMOD_CATEGORY_COMMENTARIES],
                [[SwordModCategory alloc] initWithName:SWMOD_CATEGORY_DICTIONARIES],
                [[SwordModCategory alloc] initWithName:SWMOD_CATEGORY_GENBOOKS], nil];
    }
    
    return cats;
}

- (id)initWithName:(NSString *)aName {
    self = [super init];
    if(self) {
        [self setName:aName];
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

@end
