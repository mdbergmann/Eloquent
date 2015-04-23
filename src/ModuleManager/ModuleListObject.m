//
//  ModuleListObject.m
//  Eloquent
//
//  Created by Manfred Bergmann on 01.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ModuleListObject.h"
#import "ObjCSword/SwordInstallSource.h"

@implementation ModuleListObject

- (NSString *)moduleName {
    return [self.module name];
}
- (NSString *)moduleTypeString {
    return [self.module typeString];
}
- (NSInteger)moduleStatus {
    return [self.module status];
}

@end
