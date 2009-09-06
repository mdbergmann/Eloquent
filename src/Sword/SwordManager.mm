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
            case sword::FMT_PLAIN:
            default:
				if(!plainFilter) {
					plainFilter = new sword::PLAINHTML();
                }
				mod->AddRenderFilter(plainFilter);
				break;
		}        
	}
    
    // set modules
    self.modules = dict;
}

@end

@implementation SwordManager

@synthesize modules;
@synthesize modulesPath;
@synthesize managerLock;
@synthesize temporaryManager;

# pragma mark - class methods

+ (void)initLocale {
    // set locale swManager
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *localePath = [resourcePath stringByAppendingPathComponent:@"locales.d"];
    sword::LocaleMgr *lManager = sword::LocaleMgr::getSystemLocaleMgr();
    lManager->loadConfigDir([localePath UTF8String]);
    
    //get the language
    NSArray *availLocales = [NSLocale preferredLanguages];
    //NSLocale *loc = [NSLocale currentLocale];
    //NSString *lang = [loc objectForKey:NSLocaleIdentifier];
    
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
    
    // if still haveLocale is still NO, we have a problem
    // use english for testing
    if(haveLocale) {
        // set the locale
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

/** the singleton instance */
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
                if(![subDir hasPrefix:@"."]) {
                    fullSubDir = [modulesPath stringByAppendingPathComponent:subDir];
                    fullSubDir = [fullSubDir stringByStandardizingPath];
                    
                    //if its a directory
                    if([fm fileExistsAtPath:fullSubDir isDirectory:&directory]) {
                        if(directory) {
                            swManager->augmentModules([fullSubDir UTF8String]);
                        }
                    }
                }
            }
            
            // also add the executing path to the path of modules
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            if(bundlePath) {
                // remove last path component
                NSString *appPath = [bundlePath stringByDeletingLastPathComponent];
                swManager->augmentModules([appPath UTF8String]);
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

/**
 generate a menu structure
 
 @params[in|out] subMenuItem is the start of the menustructure.
 @params[in] type, create menu for module types. ModuleType enum values can be ORed, -1 for all
 @params[in] aTarget the target object of the created menuitem
 @params[in] aSelector the selector of the target that should be called
 */
- (void)generateModuleMenu:(NSMenu **)itemMenu 
             forModuletype:(int)type 
            withMenuTarget:(id)aTarget 
            withMenuAction:(SEL)aSelector {
    
    // create menu for modules for specified type
    // bibles
    if((type == -1) || ((type & bible) == bible)) {
        // get bibles
        NSArray *bibles = [self modulesForType:SWMOD_CATEGORY_BIBLES];
        for(SwordBible *mod in bibles) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] init];
            [menuItem setTitle:[mod name]];
            //[menuItem setToolTip:[[urlval valueData] absoluteString]];					
            //image = [NSImage imageNamed:@"ItemAdd"];
            //[image setSize:NSMakeSize(32,32)];
            //[menuItem setImage:image];
            [menuItem setTarget:aTarget];
            [menuItem setAction:aSelector];
            [*itemMenu addItem:menuItem];
            [menuItem release];
        }
        
        // add separator as last item
        [*itemMenu addItem:[NSMenuItem separatorItem]];
    }
    
    // commentaries
    if((type == -1) || ((type & commentary) == commentary)) {
        // get bibles
        NSArray *bibles = [self modulesForType:SWMOD_CATEGORY_COMMENTARIES];
        for(SwordBible *mod in bibles) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] init];
            [menuItem setTitle:[mod name]];
            //[menuItem setToolTip:[[urlval valueData] absoluteString]];					
            //image = [NSImage imageNamed:@"ItemAdd"];
            //[image setSize:NSMakeSize(32,32)];
            //[menuItem setImage:image];
            [menuItem setTarget:aTarget];
            [menuItem setAction:aSelector];
            [*itemMenu addItem:menuItem];
            [menuItem release];
        }
        
        // add separator as last item
        [*itemMenu addItem:[NSMenuItem separatorItem]];
    }

    // dictionaries
    if((type == -1) || ((type & dictionary) == dictionary)) {
        // get bibles
        NSArray *bibles = [self modulesForType:SWMOD_CATEGORY_DICTIONARIES];
        for(SwordBible *mod in bibles) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] init];
            [menuItem setTitle:[mod name]];
            //[menuItem setToolTip:[[urlval valueData] absoluteString]];					
            //image = [NSImage imageNamed:@"ItemAdd"];
            //[image setSize:NSMakeSize(32,32)];
            //[menuItem setImage:image];
            [menuItem setTarget:aTarget];
            [menuItem setAction:aSelector];
            [*itemMenu addItem:menuItem];
            [menuItem release];
        }
        
        // add separator as last item
        [*itemMenu addItem:[NSMenuItem separatorItem]];
    }

    // gen books
    if((type == -1) || ((type & genbook) == genbook)) {
        // get bibles
        NSArray *bibles = [self modulesForType:SWMOD_CATEGORY_GENBOOKS];
        for(SwordBible *mod in bibles) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] init];
            [menuItem setTitle:[mod name]];
            //[menuItem setToolTip:[[urlval valueData] absoluteString]];					
            //image = [NSImage imageNamed:@"ItemAdd"];
            //[image setSize:NSMakeSize(32,32)];
            //[menuItem setImage:image];
            [menuItem setTarget:aTarget];
            [menuItem setAction:aSelector];
            [*itemMenu addItem:menuItem];
            [menuItem release];
        }
        
        // add separator as last item
        [*itemMenu addItem:[NSMenuItem separatorItem]];
    }
    
    // check last item is a separator, then remove    
    int len = [[*itemMenu itemArray] count];
    if(len > 0) {
        NSMenuItem *last = [*itemMenu itemAtIndex:len-1];
        if([last isSeparatorItem]) {
            [*itemMenu removeItem:last];
        }
    }
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

/** 
 list all module and return them in a Array 
 */
- (NSArray *)listModules {
    return [modules allValues];
}
- (NSArray *)moduleNames {
    return [modules allKeys];
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
