//
//  SwordInstallManager.h
//  Eloquent
//
//  Created by Manfred Bergmann on 13.08.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

#ifdef __cplusplus
#include <swmgr.h>
#include <installmgr.h>
#include <swconfig.h>
#include <multimapwdef.h>
class sword::SWModule;
class sword::InstallMgr;
using sword::SWModule;
using sword::InstallMgr;
#endif

@class SwordInstallSource;
@class SwordModule;
@class SwordManager;

typedef enum _ModuleStatusConst {
    ModStatOlder = 0x001,
    ModStatSameVersion = 0x002,
    ModStatUpdated = 0x004,
    ModStatNew = 0x008,
    ModStatCiphered = 0x010,
    ModStatCipheredKeyPresent = 0x020
}ModuleStatusConst;

@interface SwordInstallSourceController : NSObject
{
@private
#ifdef __cplusplus
    sword::InstallMgr *swInstallMgr;
#endif
    
    BOOL createPath;
    
    NSString *configPath;
    NSString *configFilePath;
    
    /** the dictionary holding the install sources. caption is the key */
    NSMutableDictionary *installSources;
    NSMutableArray *installSourceList;
}

// ------------------- getter / setter -------------------
@property (retain, readwrite) NSString *configPath;
@property (retain, readwrite) NSString *configFilePath;
@property (retain, readwrite) NSMutableDictionary *installSources;
@property (retain, readwrite) NSMutableArray *installSourceList;

// -------------------- methods --------------------

// initialization
+ (SwordInstallSourceController *)defaultController;

/**
base path of the module installation
 */
- (id)init;
- (id)initWithPath:(NSString *)aPath createPath:(BOOL)create;

/** re-init after adding or removing new modules */
- (void)reinitialize;

// installation/uninstallation
- (int)installModule:(SwordModule *)aModule fromSource:(SwordInstallSource *)is withManager:(SwordManager *)manager;
- (int)uninstallModule:(SwordModule *)aModule fromManager:(SwordManager *)swManager;

// add/remove install sources
- (void)addInstallSource:(SwordInstallSource *)is;
- (void)removeInstallSource:(SwordInstallSource *)is;
- (void)updateInstallSource:(SwordInstallSource *)is;
- (int)refreshMasterRemoteInstallSourceList;

// disclaimer
- (BOOL)userDisclaimerConfirmed;
- (void)setUserDisclainerConfirmed:(BOOL)flag;

// list modules in sources
- (NSArray *)listModulesForSource:(SwordInstallSource *)is;

// remote source list
- (int)refreshInstallSource:(SwordInstallSource *)is;

// get module status
- (NSArray *)moduleStatusInInstallSource:(SwordInstallSource *)is baseManager:(SwordManager *)baseMgr;

// low level access
#ifdef __cplusplus
- (sword::InstallMgr *)installMgr;
#endif

@end
