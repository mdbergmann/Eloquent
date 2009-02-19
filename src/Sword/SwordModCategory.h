//
//  SwordModCategory.h
//  MacSword2
//
//  Created by Manfred Bergmann on 23.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SwordModule.h>

@interface SwordModCategory : NSObject {
    ModuleType type;
}

@property (readwrite) ModuleType type;

+ (NSArray *)moduleCategories;
- (id)initWithType:(ModuleType)aType;
- (NSString *)name;

@end
