//
//  ModuleListObject.h
//  Eloquent
//
//  Created by Manfred Bergmann on 01.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SwordModule;
@class SwordInstallSource;

// tasks
typedef enum _ModuleTaskId {
    TaskNone = 0,
    TaskInstall,
    TaskRemove,
    TaskUpdate
}ModuleTaskId;

@interface ModuleListObject : NSObject

@property (strong, readwrite) SwordModule *module;
@property (strong, readwrite) SwordInstallSource *installSource;
@property (readwrite) ModuleTaskId taskId;

- (NSString *)moduleName;
- (NSString *)moduleTypeString;
- (NSInteger)moduleStatus;

@end
