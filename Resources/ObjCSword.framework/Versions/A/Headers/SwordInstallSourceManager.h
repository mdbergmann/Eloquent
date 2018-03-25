//
//  SwordInstallManager.h
//  Eloquent
//
//  Created by Manfred Bergmann on 13.08.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <swmgr.h>
#include <installmgr.h>
#include <swconfig.h>
#include <multimapwdef.h>
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

@interface SwordInstallSourceManager : NSObject

// ------------------- properties -------------------
/** Dictionary of InstallSources. Key: Caption */
@property (retain, readwrite) NSString *ftpUser;
@property (retain, readwrite) NSString *ftpPassword;
@property (retain, readonly) NSString *configPath;

// -------------------- methods --------------------

// initialization
+ (SwordInstallSourceManager *)defaultManager;

/**
    base path of the module installation
 */
- (id)initWithPath:(NSString *)aPath createPath:(BOOL)create;

/** marks this manager as the default one / singleton */
- (void)useAsDefaultManager;

/** init after adding or removing new modules */
- (void)initManager;

/** dictionary of all available install sources: <is.caption>:<is> */
- (NSDictionary *)allInstallSources;

// installation/unInstallation
- (int)installModule:(SwordModule *)aModule fromSource:(SwordInstallSource *)is withManager:(SwordManager *)manager;
- (int)uninstallModule:(SwordModule *)aModule fromManager:(SwordManager *)swManager;

// add/remove install sources
- (void)addInstallSource:(SwordInstallSource *)is reload:(BOOL)doReload;
- (void)removeInstallSource:(SwordInstallSource *)is reload:(BOOL)doReload;
- (void)updateInstallSource:(SwordInstallSource *)is;
- (int)refreshMasterRemoteInstallSourceList;

/** after adding or removing sources */
- (void)saveConfig;

// disclaimer
- (BOOL)userDisclaimerConfirmed;
- (void)setUserDisclaimerConfirmed:(BOOL)flag;

// list modules in sources
- (NSDictionary *)listModulesForSource:(SwordInstallSource *)is;

// remote source list
- (int)refreshInstallSource:(SwordInstallSource *)is;

// get module status
- (NSArray *)moduleStatusInInstallSource:(SwordInstallSource *)is baseManager:(SwordManager *)baseMgr;

// low level access
#ifdef __cplusplus
- (sword::InstallMgr *)installMgr;
#endif

@end
