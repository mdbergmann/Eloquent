//
//  SwordModCategory.h
//  MacSword2
//
//  Created by Manfred Bergmann on 23.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SwordModCategory : NSObject {
    NSString *name;
}

@property (retain, readwrite) NSString *name;

+ (NSArray *)moduleCategories;
- (id)initWithName:(NSString *)aName;

@end
