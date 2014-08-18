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

@interface ModuleListObject : NSObject {

    SwordModule *module;
    SwordInstallSource *installSource;
    ModuleTaskId taskId;
}

// ------------- getter / setter -------------
- (SwordModule *)module;
- (void)setModule:(SwordModule *)value;

- (SwordInstallSource *)installSource;
- (void)setInstallSource:(SwordInstallSource *)value;

- (ModuleTaskId)taskId;
- (void)setTaskId:(ModuleTaskId)value;

// --------------- methods --------------
- (NSString *)moduleName;
- (NSString *)moduleTypeString;
- (NSInteger)moduleStatus;

@end
