//
//  SwordInstallManager.mm
//  Eloquent
//
//  Created by Manfred Bergmann on 13.08.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SwordInstallSourceController.h"
#import "SwordInstallSource.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "globals.h"

#include "installmgr.h"
//#include "MyInstallMgr.h"

#ifdef __cplusplus
typedef std::map<sword::SWBuf, sword::InstallSource *> InstallSourceMap;
typedef sword::multimapwithdefault<sword::SWBuf, sword::SWBuf, std::less <sword::SWBuf> > ConfigEntMap;
#endif

#define INSTALLSOURCE_SECTION_TYPE_FTP  "FTPSource"

@implementation SwordInstallSourceController

@dynamic configPath;
@synthesize configFilePath;
@synthesize installSources;
@synthesize installSourceList;

// ------------------- getter / setter -------------------
- (NSString *)configPath {
    return configPath;
}

- (void)setConfigPath:(NSString *)value {
    MBLOG(MBLOG_DEBUG, @"[SwordInstallSourceController -setConfigPath:]");
    
    if(configPath != value) {
        [configPath release];
        configPath = [value copy];
        
        if(value != nil) {            
            // check for existence
            NSFileManager *fm = [NSFileManager defaultManager];
            BOOL isDir;
            if(([fm fileExistsAtPath:configPath] == NO) && createPath == YES) {
                // create path
                [fm createDirectoryAtPath:configPath attributes:nil];
            }
            
            if(([fm fileExistsAtPath:configPath isDirectory:&isDir] == YES) && (isDir)) {
                // set configFilePath
                [self setConfigFilePath:[configPath stringByAppendingPathComponent:@"InstallMgr.conf"]];
                
                // check config
                if([fm fileExistsAtPath:configFilePath] == NO) {
                    // create default Install source
                    SwordInstallSource *is = [[[SwordInstallSource alloc] initWithType:INSTALLSOURCE_TYPE_FTP] autorelease];
                    [is setCaption:@"CrossWire"];
                    [is setSource:@"ftp.crosswire.org"];
                    [is setDirectory:@"/pub/sword/raw"];
                    
                    // create config entry
                    sword::SWConfig config([configFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
                    config["General"]["PassiveFTP"] = "true";
                    config.Save();
                    
                    // add is
                    // addInstallSource will reinitialize
                    [self addInstallSource:is];
                } else {
                    // init installMgr
                    [self reinitialize];                
                }
            } else {
                MBLOG(MBLOG_WARN, @"[SwordInstallManager -setConfigPath:] config path does not exist!");
            }
        }
    }
}

// -------------------- methods --------------------

// initialization
+ (SwordInstallSourceController *)defaultController {
    static SwordInstallSourceController *singleton;
    if(singleton == nil) {
        singleton = [[SwordInstallSourceController alloc] init];
    }
    
    return singleton;
}

/**
base path of the module installation
 */
- (id)init {
    MBLOG(MBLOG_DEBUG, @"[SwordInstallSourceController -init]");

    self = [super init];
    if(self) {
        createPath = NO;
        [self setConfigPath:nil];
        [self setConfigFilePath:nil];
        [self setInstallSources:[NSDictionary dictionary]];
        [self setInstallSourceList:[NSArray array]];
    }
    
    return self;
}

/**
 initialize with given path
 */
- (id)initWithPath:(NSString *)aPath createPath:(BOOL)create {
    
    MBLOG(MBLOG_DEBUG, @"[SwordInstallSourceController -initWithPath:]");
    
    self = [self init];
    if(self) {
        createPath = create;
        [self setConfigPath:aPath];
    }
    
    return self;
}

/** re-init after adding or removing new modules */
- (void)reinitialize {

    MBLOG(MBLOG_INFO, @"[SwordInstallManager -reinitialize] loading config!");
    sword::SWConfig config([configFilePath UTF8String]);
    config.Load();

    // init installMgr
    BOOL disclaimerConfirmed = NO;
    if(swInstallMgr != nil) {
        disclaimerConfirmed = [self userDisclaimerConfirmed];
    }
    swInstallMgr = new sword::InstallMgr([configPath UTF8String]);
    if(swInstallMgr == nil) {
        MBLOG(MBLOG_ERR, @"[SwordInstallManager -reinitialize] could not initialize InstallMgr!");
    } else {
        [self setUserDisclainerConfirmed:disclaimerConfirmed];
        
        // empty all lists
        [installSources removeAllObjects];
        [installSourceList removeAllObjects];
        
        // init install sources
        for(InstallSourceMap::iterator it = swInstallMgr->sources.begin(); it != swInstallMgr->sources.end(); it++) {
            sword::InstallSource *sis = it->second;
            SwordInstallSource *is = [[SwordInstallSource alloc] initWithSource:(id)sis];
            
            [installSources setObject:is forKey:[is caption]];
            // also add to list
            [installSourceList addObject:is];
        }
    }
}

- (void)dealloc {
    MBLOG(MBLOG_DEBUG, @"[SwordInstallSourceController -finalize]");

    if(swInstallMgr != nil) {
        delete swInstallMgr;
    }
    
    [self setConfigPath:nil];
    [self setInstallSources:nil];
    [self setInstallSourceList:nil];
    [self setConfigFilePath:nil];
    
    [super dealloc];
}

// add/remove install sources
- (void)addInstallSource:(SwordInstallSource *)is {
    
    // save at once
    sword::SWConfig config([configFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
    config["Sources"].insert(ConfigEntMap::value_type(INSTALLSOURCE_SECTION_TYPE_FTP, [[is configEntry] UTF8String]));
    config.Save();
    
    // reinit
    [self reinitialize];
}

- (void)removeInstallSource:(SwordInstallSource *)is {
    
    // remove source
    [installSources removeObjectForKey:[is caption]];
    
    // save at once
    sword::SWConfig config([configFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
    config["Sources"].erase(INSTALLSOURCE_SECTION_TYPE_FTP);
    
    // build up new
    NSEnumerator *iter = [installSources objectEnumerator];
    SwordInstallSource *sis = nil;
    while((sis = [iter nextObject])) {
        config["Sources"].insert(ConfigEntMap::value_type("FTPSource", [[sis configEntry] UTF8String]));        
    }
    config.Save();
    
    // reinit
    [self reinitialize];
}

- (void)updateInstallSource:(SwordInstallSource *)is {
    // first remove, then add again
    [self removeInstallSource:is];
    [self addInstallSource:is];
}

// installation/uninstallation
- (int)installModule:(SwordModule *)aModule fromSource:(SwordInstallSource *)is withManager:(SwordManager *)manager {
    
    int stat = -1;
    if([[is source] isEqualToString:@"localhost"]) {
        stat = swInstallMgr->installModule([manager swManager], [[is directory] UTF8String], [[aModule name] UTF8String]);
    } else {
        stat = swInstallMgr->installModule([manager swManager], 0, [[aModule name] UTF8String], [is installSource]);
    }
    
    return stat;
}

/**
 uninstalls a module from a SwordManager
 */
- (int)uninstallModule:(SwordModule *)aModule fromManager:(SwordManager *)swManager {
    
    int stat = swInstallMgr->removeModule([swManager swManager], [[aModule name] UTF8String]);
    
    return stat;
}

// list modules in sources
- (NSArray *)listModulesForSource:(SwordInstallSource *)is {
    return [is listModules];
}

/** refresh modules of this source 
 refreshing the install source is necessary before installation of 
 */
- (int)refreshInstallSource:(SwordInstallSource *)is {
    int ret = 1;
    
    if(is == nil) {
        MBLOG(MBLOG_ERR, @"[SwordInstallManager -refreshInstallSourceForName:] install source is nil");
    } else {
        if([[is source] isEqualToString:@"localhost"] == NO) {
            ret = swInstallMgr->refreshRemoteSource([is installSource]);
        } else {
            MBLOG(MBLOG_INFO, @"[SwordInstallSourceController -refreshInstallSource:] not refreshing, DIR source");
        }
    }
    
    return ret;
}

/**
 returns an array of Modules with status set, nil on error
 */
- (NSArray *)moduleStatusInInstallSource:(SwordInstallSource *)is baseManager:(SwordManager *)baseMgr {
    
    NSArray *ret = nil;
    
    // get modules map
    NSMutableArray *ar = [NSMutableArray array];
    std::map<sword::SWModule *, int> modStats = swInstallMgr->getModuleStatus(*[baseMgr swManager], *[[is swordManager] swManager]);
    sword::SWModule *module;
	int status;
	for(std::map<sword::SWModule *, int>::iterator it = modStats.begin(); it != modStats.end(); it++) {
		module = it->first;
		status = it->second;
        
        SwordModule *mod = [[SwordModule alloc] initWithSWModule:module];
        [mod setStatus:status];
        [ar addObject:mod];
	}
    
    if(ar) {
        ret = [NSArray arrayWithArray:ar];
    }
    
    return ret;
}

- (BOOL)userDisclaimerConfirmed {
    return swInstallMgr->isUserDisclaimerConfirmed();
}

- (void)setUserDisclainerConfirmed:(BOOL)flag {
    swInstallMgr->setUserDisclaimerConfirmed(flag);
}

/** low level access */
- (sword::InstallMgr *)installMgr {
    return swInstallMgr;
}

@end
