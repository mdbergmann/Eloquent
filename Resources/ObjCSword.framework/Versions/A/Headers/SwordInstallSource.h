//
//  SwordInstallSource.h
//  Eloquent
//
//  Created by Manfred Bergmann on 13.08.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwordModule.h"

#ifdef __cplusplus
#include <swmgr.h>
#include <installmgr.h>
#endif

@class SwordManager;
@class SwordInstallSourceManager;

#define INSTALLSOURCE_TYPE_FTP  @"FTP"

@interface SwordInstallSource : NSObject

- (id)init;
#ifdef __cplusplus
- (id)initWithSource:(sword::InstallSource *)is;
#endif
- (id)initWithType:(NSString *)aType;

@property (retain, readwrite) NSString *caption;
@property (retain, readwrite) NSString *type;
@property (retain, readwrite) NSString *source;
@property (retain, readwrite) NSString *directory;
@property (readwrite) BOOL deleteOnDealloc;

- (BOOL)isLocalSource;

// get config entry
- (NSString *)configEntry;

// install module
- (void)installModuleWithName:(NSString *)mName 
                 usingManager:(SwordManager *)swManager 
        withInstallController:(SwordInstallSourceManager *)sim;

/** List of available InstallSources */
- (NSDictionary *)allModules;

/** List of modules for given type */
- (NSArray *)listModulesForType:(ModuleType)aType;

/** list module types */
- (NSArray *)listModuleTypes;

/** Returns the SwordManager attached to this SwordInstallSource */
- (SwordManager *)swordManager;

#ifdef __cplusplus
- (sword::InstallSource *)installSource;
#endif

@end
