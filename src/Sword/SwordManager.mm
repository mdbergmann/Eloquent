/*	SwordManager.mm - Sword API wrapper for Modules.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import "SwordManager.h"
#include <string>
#include <list>

#include "gbfplain.h"
#include "thmlplain.h"
#include "osisplain.h"
#include "msstringmgr.h"
#import "CocoLogger/CocoLogger.h"
#import "IndexingManager.h"
#import "globals.h"
#import "utils.h"
#import "SwordBook.h"
#import "SwordModule.h"
#import "SwordBible.h"
#import "SwordCommentary.h"
#import "SwordDictionary.h"
#import "SwordListKey.h"
#import "SwordVerseKey.h"

using std::string;
using std::list;

@interface SwordManager (PrivateAPI)

- (void)refreshModules;
- (void)addFiltersToModule:(sword::SWModule *)mod;

@end

@implementation SwordManager (PrivateAPI)

- (void)refreshModules {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // loop over modules
    sword::SWModule *mod;
	for(ModMap::iterator it = swManager->Modules.begin(); it != swManager->Modules.end(); it++) {
		mod = it->second;
        
        // create module instances
        NSString *type;
        NSString *name;
        if(mod->isUnicode()) {
            type = [NSString stringWithUTF8String:mod->Type()];
            name = [NSString stringWithUTF8String:mod->Name()];
        } else {
            type = [NSString stringWithCString:mod->Type() encoding:NSISOLatin1StringEncoding];
            name = [NSString stringWithCString:mod->Name() encoding:NSISOLatin1StringEncoding];
        }
        
        SwordModule *sm = nil;
        if([type isEqualToString:SWMOD_CATEGORY_BIBLES]) {
            sm = [[SwordBible alloc] initWithSWModule:mod swordManager:self];
        } else if([type isEqualToString:SWMOD_CATEGORY_COMMENTARIES]) {
            sm = [[SwordCommentary alloc] initWithSWModule:mod swordManager:self];
        } else if([type isEqualToString:SWMOD_CATEGORY_DICTIONARIES]) {
            sm = [[SwordDictionary alloc] initWithSWModule:mod swordManager:self];
        } else if([type isEqualToString:SWMOD_CATEGORY_GENBOOKS]) {
            sm = [[SwordBook alloc] initWithSWModule:mod swordManager:self];
        } else {
            sm = [[SwordModule alloc] initWithSWModule:mod swordManager:self];
        }
        [dict setObject:sm forKey:[sm name]];
        
        [self addFiltersToModule:mod];
	}
    
    // set modules
    self.modules = dict;
}

- (void)addFiltersToModule:(sword::SWModule *)mod {
    // prepare display filters
    switch(mod->Markup()) {
        case sword::FMT_GBF:
            if(!gbfFilter) {
                gbfFilter = new sword::GBFHTMLHREF();
            }
            if(!gbfStripFilter) {
                gbfStripFilter = new sword::GBFPlain();
            }
            mod->AddRenderFilter(gbfFilter);
            mod->AddStripFilter(gbfStripFilter);
            break;
        case sword::FMT_THML:
            if(!thmlFilter) {
                thmlFilter = new sword::ThMLHTMLHREF();
            }
            if(!thmlStripFilter) {
                thmlStripFilter = new sword::ThMLPlain();
            }
            mod->AddRenderFilter(thmlFilter);
            mod->AddStripFilter(thmlStripFilter);
            break;
        case sword::FMT_OSIS:
            if(!osisFilter) {
                osisFilter = new sword::OSISHTMLHREF();
            }
            if(!osisStripFilter) {
                osisStripFilter = new sword::OSISPlain();
            }
            mod->AddRenderFilter(osisFilter);
            mod->AddStripFilter(osisStripFilter);
            break;
        case sword::FMT_TEI:
            if(!teiFilter) {
                teiFilter = new sword::TEIHTMLHREF();
            }
            mod->AddRenderFilter(teiFilter);
            break;
        case sword::FMT_PLAIN:
        default:
            if(!plainFilter) {
                plainFilter = new sword::PLAINHTML();
            }
            mod->AddRenderFilter(plainFilter);
            break;
    }    
}

@end

@implementation SwordManager

@synthesize modules;
@synthesize modulesPath;
@synthesize managerLock;
@synthesize temporaryManager;

# pragma mark - class methods

+ (NSDictionary *)linkDataForLinkURL:(NSURL *)aURL {
    // there are two types of links
    // our generated sword:// links and study data beginning with applewebdata://
    
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    NSString *scheme = [aURL scheme];
    if([scheme isEqualToString:@"sword"]) {
        // in this case host is the module and path the reference
        [ret setObject:[aURL host] forKey:ATTRTYPE_MODULE];
        [ret setObject:[[[aURL path] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
                        stringByReplacingOccurrencesOfString:@"/" withString:@""]
                forKey:ATTRTYPE_VALUE];
        [ret setObject:@"scriptRef" forKey:ATTRTYPE_TYPE];
        [ret setObject:@"showRef" forKey:ATTRTYPE_ACTION];
    } else if([scheme isEqualToString:@"applewebdata"]) {
        // in this case
        NSString *path = [aURL path];
        NSString *query = [aURL query];
        if([[path lastPathComponent] isEqualToString:@"passagestudy.jsp"]) {
            NSArray *data = [query componentsSeparatedByString:@"&"];
            NSString *type = @"x";
            NSString *module = @"";
            NSString *passage = @"";
            NSString *value = @"1";
            NSString *action = @"";
            for(NSString *entry in data) {
                if([entry hasPrefix:@"type="]) {
                    type = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];
                } else if([entry hasPrefix:@"module="]) {
                    module = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];
                } else if([entry hasPrefix:@"passage="]) {
                    passage = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];
                } else if([entry hasPrefix:@"action="]) {
                    action = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];                    
                } else if([entry hasPrefix:@"value="]) {
                    value = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];                    
                } else {
                    MBLOGV(MBLOG_WARN, @"[ExtTextViewController -dataForLink:] unknown parameter: %@\n", entry);
                }
            }
            
            [ret setObject:module forKey:ATTRTYPE_MODULE];
            [ret setObject:passage forKey:ATTRTYPE_PASSAGE];
            [ret setObject:value forKey:ATTRTYPE_VALUE];
            [ret setObject:action forKey:ATTRTYPE_ACTION];
            [ret setObject:type forKey:ATTRTYPE_TYPE];
        }
    }
    
    return ret;
}

+ (void)initLocale {
    // set locale swManager
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *localePath = [resourcePath stringByAppendingPathComponent:@"locales.d"];
    sword::LocaleMgr *lManager = sword::LocaleMgr::getSystemLocaleMgr();
    lManager->loadConfigDir([localePath UTF8String]);
    
    //get the language
    NSArray *availLocales = [NSLocale preferredLanguages];
    
    NSString *lang = nil;
    NSString *loc = nil;
    BOOL haveLocale = NO;
    // for every language, check if we know the locales
    StringList localelist = lManager->getAvailableLocales();
    NSEnumerator *iter = [availLocales objectEnumerator];
    while((loc = [iter nextObject]) && !haveLocale) {
        // check if this locale is available in SWORD
        StringList::iterator it;
        SWBuf locale;
        for(it = localelist.begin(); it != localelist.end(); ++it) {
            locale = *it;
            NSString *swLoc = [NSString stringWithCString:locale.c_str() encoding:NSUTF8StringEncoding];
            if([swLoc hasPrefix:loc]) {
                haveLocale = YES;
                lang = loc;
                break;
            }
        }        
    }
    
    if(haveLocale) {
        lManager->setDefaultLocaleName([lang UTF8String]);    
    }    
}

+ (NSArray *)moduleTypes {
    return [NSArray arrayWithObjects:
            SWMOD_CATEGORY_BIBLES, 
            SWMOD_CATEGORY_COMMENTARIES,
            SWMOD_CATEGORY_DICTIONARIES,
            SWMOD_CATEGORY_GENBOOKS, nil];
}

/**
 return a manager for the specified path
 */
+ (SwordManager *)managerWithPath:(NSString *)path {
    SwordManager *manager = [[[SwordManager alloc] initWithPath:path] autorelease];
    return manager;
}

+ (SwordManager *)defaultManager {
    static SwordManager *instance;
    if(instance == nil) {
        // use default path
        instance = [[SwordManager alloc] initWithPath:DEFAULT_MODULE_PATH];
    }
    
	return instance;
}


/* 
 Initializes Sword Manager with the path to the folder that contains the mods.d, modules.
*/
- (id)initWithPath:(NSString *)path {

	if((self = [super init])) {
        // this is our main swManager
        temporaryManager = NO;
        
        self.modulesPath = path;

		self.modules = [NSDictionary dictionary];
		self.managerLock = [[NSRecursiveLock alloc] init];

        // setting locale
        [SwordManager initLocale];
        
        [self reInit];
        
        sword::StringList options = swManager->getGlobalOptions();
        sword::StringList::iterator	it;
        for(it = options.begin(); it != options.end(); it++) {
            [self setGlobalOption:[NSString stringWithCString:it->c_str() encoding:NSUTF8StringEncoding] value:SW_OFF];
        }        
    }	
	
	return self;
}

/** 
 initialize a new SwordManager with given SWMgr
 */
- (id)initWithSWMgr:(sword::SWMgr *)aSWMgr {
    MBLOG(MBLOG_DEBUG, @"[SwordManager -initWithSWMgr:]");
    
    self = [super init];
    if(self) {
        swManager = aSWMgr;
        // this is a temporary swManager
        temporaryManager = YES;
        
		self.modules = [NSDictionary dictionary];
        self.managerLock = [[NSRecursiveLock alloc] init];
        
		[self refreshModules];
    }
    
    return self;
}

/** 
 reinit the swManager 
 */
- (void)reInit {
    MBLOG(MBLOG_DEBUG, @"[SwordManager -reInit]");
    
	[managerLock lock];
    if(modulesPath && [modulesPath length] > 0) {
        
        // modulePath is the main sw manager
        swManager = new sword::SWMgr([modulesPath UTF8String], true, new sword::EncodingFilterMgr(sword::ENC_UTF8));

        if(!swManager) {
            MBLOG(MBLOG_ERR, @"[SwordManager -reInit] cannot create SWMgr instance for default module path!");
        } else {
            NSFileManager *fm = [NSFileManager defaultManager];
            NSArray *subDirs = [fm directoryContentsAtPath:modulesPath];
            // for all sub directories add module
            BOOL directory;
            NSString *fullSubDir = nil;
            NSString *subDir = nil;
            for(subDir in subDirs) {
                // as long as it's not hidden
                if(![subDir hasPrefix:@"."] && 
                   ![subDir isEqualToString:@"InstallMgr"] && 
                   ![subDir isEqualToString:@"mods.d"] &&
                   ![subDir isEqualToString:@"modules"]) {
                    fullSubDir = [modulesPath stringByAppendingPathComponent:subDir];
                    fullSubDir = [fullSubDir stringByStandardizingPath];
                    
                    //if its a directory
                    if([fm fileExistsAtPath:fullSubDir isDirectory:&directory]) {
                        if(directory) {
                            MBLOGV(MBLOG_DEBUG, @"[SwordManager -reInit] augmenting folder: %@", fullSubDir);
                            swManager->augmentModules([fullSubDir UTF8String]);
                            MBLOG(MBLOG_DEBUG, @"[SwordManager -reInit] augmenting folder done");
                        }
                    }
                }
            }
            
            // clear some data
            [self refreshModules];
            
            SendNotifyModulesChanged(nil);
        }
    }
	[managerLock unlock];    
}

/**
 adds modules in this path
 */
- (void)addPath:(NSString *)path {
    
	[managerLock lock];
	if(swManager == nil) {
		swManager = new sword::SWMgr([path UTF8String], true, new sword::EncodingFilterMgr(sword::ENC_UTF8));
    } else {
		swManager->augmentModules([path UTF8String]);
    }
	
	[self refreshModules];
	[managerLock unlock];
    
    SendNotifyModulesChanged(nil);
}

/** 
 Unloads Sword Manager.
*/
- (void)finalize {
    MBLOG(MBLOG_DEBUG, @"[SwordManager -finalize]");
    
    if(!temporaryManager) {
        delete swManager;
    }
    
	[super finalize];
}

/**
 get module with name from internal list
 */
- (SwordModule *)moduleWithName:(NSString *)name {
    
	SwordModule	*ret = [modules objectForKey:name];
    if(ret == nil) {
        sword::SWModule *mod = [self getSWModuleWithName:name];
        if(mod == NULL) {
            MBLOGV(MBLOG_WARN, @"No module by that name: %@!", name);
        } else {
            NSString *type;
            if(mod->isUnicode()) {
                type = [NSString stringWithUTF8String:mod->Type()];
            } else {
                type = [NSString stringWithCString:mod->Type() encoding:NSISOLatin1StringEncoding];
            }
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:modules];
            // create module
            if([type isEqualToString:SWMOD_CATEGORY_BIBLES]) {
                ret = [[[SwordBible alloc] initWithName:name swordManager:self] autorelease];
            } else if([type isEqualToString:SWMOD_CATEGORY_COMMENTARIES]) {
                ret = [[[SwordBible alloc] initWithName:name swordManager:self] autorelease];
                //ret = [[[SwordCommentary alloc] initWithName:name swordManager:self] autorelease];
            } else if([type isEqualToString:SWMOD_CATEGORY_DICTIONARIES]) {
                ret = [[[SwordDictionary alloc] initWithName:name swordManager:self] autorelease];
            } else if([type isEqualToString:SWMOD_CATEGORY_GENBOOKS]) {
                ret = [[[SwordBook alloc] initWithName:name swordManager:self] autorelease];
            } else {
                ret = [[[SwordModule alloc] initWithName:name swordManager:self] autorelease];
            }
            [dict setObject:ret forKey:name];
            self.modules = dict;
        }        
    }
    
	return ret;
}

- (void)setCipherKey:(NSString *)key forModuleNamed:(NSString *)name {
	[managerLock lock];	
	swManager->setCipherKey([name UTF8String], [key UTF8String]);
	[managerLock unlock];
}

#pragma mark - module access

/** 
 Sets global options such as 'Strongs' or 'Footnotes'. 
 */
- (void)setGlobalOption:(NSString *)option value:(NSString *)value {
	[managerLock lock];
    swManager->setGlobalOption([option UTF8String], [value UTF8String]);
	[managerLock unlock];
}

- (BOOL)globalOption:(NSString *)option {
    return [[NSString stringWithUTF8String:swManager->getGlobalOption([option UTF8String])] isEqualToString:SW_ON];
}

/** 
 list all module and return them in a Array 
 */
- (NSArray *)listModules {
    return [modules allValues];
}
- (NSArray *)moduleNames {
    return [modules allKeys];
}

- (NSArray *)sortedModuleNames {
    return [[self moduleNames] sortedArrayUsingSelector:@selector(compare:)];
}

/** 
 Retrieve list of installed modules as an array, where the module has a specific feature
*/
- (NSArray *)modulesForFeature:(NSString *)feature {

    NSMutableArray *ret = [NSMutableArray array];
    for(SwordModule *mod in [modules allValues]) {
        if([mod hasFeature:feature]) {
            [ret addObject:mod];
        }
    }
	
    // sort
    NSArray *sortDescritors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]; 
    [ret sortUsingDescriptors:sortDescritors];

	return [NSArray arrayWithArray:ret];
}

/* 
 Retrieve list of installed modules as an array, where type is: @"Biblical Texts", @"Commentaries", ..., @"ALL"
*/
- (NSArray *)modulesForType:(NSString *)type {

    NSMutableArray *ret = [NSMutableArray array];
    for(SwordModule *mod in [modules allValues]) {
        if([[mod typeString] isEqualToString:type]) {
            [ret addObject:mod];
        }
    }
    
    // sort
    NSArray *sortDescritors = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]; 
    [ret sortUsingDescriptors:sortDescritors];
    
	return [NSArray arrayWithArray:ret];
}

#pragma mark - lowlevel methods

/** 
 return the sword swManager of this class 
 */
- (sword::SWMgr *)swManager {
    return swManager;
}

/**
 Retrieves C++ SWModule pointer - used internally by SwordBible. 
 */
- (sword::SWModule *)getSWModuleWithName:(NSString *)moduleName {
	sword::SWModule *module = NULL;

	[managerLock lock];
	module = swManager->Modules[[moduleName UTF8String]];	
	[managerLock unlock];
    
	return module;
}

@end
