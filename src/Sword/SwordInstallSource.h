//
//  SwordInstallSource.h
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
class sword::SWModule;
#endif

@class SwordManager;
@class SwordInstallSourceController;

#define INSTALLSOURCE_TYPE_FTP  @"FTP"

@interface SwordInstallSource : NSObject {
    
#ifdef __cplusplus
    sword::InstallSource *swInstallSource;
#endif
    
    /** the sword manager for this source */
    SwordManager *swordManager;
    
    BOOL temporarySource;
}

// init
- (id)init;
#ifdef __cplusplus
- (id)initWithSource:(sword::InstallSource *)is;
#endif
- (id)initWithType:(NSString *)aType;

// accessors
- (NSString *)caption;
- (void)setCaption:(NSString *)aCaption;
- (NSString *)type;
- (void)setType:(NSString *)aType;
- (NSString *)source;
- (void)setSource:(NSString *)aSource;
- (NSString *)directory;
- (void)setDirectory:(NSString *)aDir;

// get config entry
- (NSString *)configEntry;

// install module
- (void)installModuleWithName:(NSString *)mName 
                 usingManager:(SwordManager *)swManager 
        withInstallController:(SwordInstallSourceController *)sim;

// list modules of this source
- (NSArray *)listModules;
/** list module types */
- (NSArray *)listModuleTypes;
// get associated SwordManager
- (SwordManager *)swordManager;

#ifdef __cplusplus
- (sword::InstallSource *)installSource;
#endif

@end
