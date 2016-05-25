//
//  SwordModCategory.h
//  Eloquent
//
//  Created by Manfred Bergmann on 23.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ObjCSword/SwordModule.h"

@interface SwordModCategory : NSObject

@property (readwrite) ModuleType modType;

+ (NSArray *)moduleCategories;
- (id)initWithType:(ModuleType)aType;
- (NSString *)name;

@end
