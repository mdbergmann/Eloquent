/*	SwordModule.mm - Sword API wrapper for Modules.

	Copyright 2008 Manfred Bergmann
	Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import "SwordModule.h"
#import "rtfhtml.h"
#import "utils.h"
#import "SwordManager.h"

@interface SwordModule (/* Private, class continuation */)
/** private property */
@property(readwrite, retain) NSMutableDictionary *configEntries;
@end

@interface SwordModule (PrivateAPI)

- (void)mainInit;

@end

@implementation SwordModule (PrivateAPI)

- (void)mainInit {
    // set type
    self.type = [SwordModule moduleTypeForModuleTypeString:[self typeString]];
    // init lock
    self.moduleLock = [[NSRecursiveLock alloc] init];
    // nil values
    self.configEntries = [NSMutableDictionary dictionary];
}

@end

@implementation SwordModule

// -------------- property implementations -----------------
@synthesize configEntries;
@synthesize type;
@synthesize status;
@synthesize moduleLock;
@synthesize swManager;

/**
 \brief maps type string to ModuleType enum
 @param[in] typeStr type String as in -moduleType(SwordModule)
 @return type according to ModuleType enum
 */
+ (ModuleType)moduleTypeForModuleTypeString:(NSString *)typeStr {
     ModuleType ret = bible;
    
    if(typeStr == nil) {
        MBLOG(MBLOG_ERR, @"have a nil typeStr!");
        return ret;
    }
    
    if([typeStr isEqualToString:SWMOD_CATEGORY_BIBLES]) {
        ret = bible;
    } else if([typeStr isEqualToString:SWMOD_CATEGORY_COMMENTARIES]) {
        ret = commentary;
    } else if([typeStr isEqualToString:SWMOD_CATEGORY_DICTIONARIES]) {
        ret = dictionary;
    } else if([typeStr isEqualToString:SWMOD_CATEGORY_GENBOOKS]) {
        ret = genbook;
    }
    
    return ret;
}

// initalises the module from a manager
- (id)initWithName:(NSString *)aName swordManager:(SwordManager *)aManager {

	if((self = [super init])) {
        
        // get the sword module
		swModule = [aManager getSWModuleWithName:aName];
        // set manager
        self.swManager = aManager;
        
        // main init
        [self mainInit];
	}
	
	return self;
}

/** init with given SWModule */
- (id)initWithSWModule:(sword::SWModule *)aModule {
    
    self = [super init];
    if(self) {
		
        // copy the module instance
        swModule = aModule;
        // set default manager
        self.swManager = nil;
        
        // main init
        [self mainInit];
    }
    
    return self;
}

/**
 gc will cleanup
 */
- (void)finalize {    
	[super finalize];
}

#pragma mark - convenience methods

- (NSString *)name {
    return [NSString stringWithCString:swModule->Name() encoding:NSUTF8StringEncoding];
}

- (NSString *)descr {
    return [NSString stringWithCString:swModule->Description() encoding:NSUTF8StringEncoding];
}

- (NSString *)lang {
    return [NSString stringWithCString:swModule->Lang() encoding:NSUTF8StringEncoding];
}

- (NSString *)typeString {
    return [NSString stringWithCString:swModule->Type() encoding:NSUTF8StringEncoding];
}

/** cipher key in config */
- (NSString *)cipherKey {
    NSString *cipherKey = [configEntries objectForKey:SWMOD_CONFENTRY_CIPHERKEY];
    if(cipherKey == nil) {
        cipherKey = [self configEntryForKey:SWMOD_CONFENTRY_CIPHERKEY];
        if(cipherKey != nil) {
            [configEntries setObject:cipherKey forKey:SWMOD_CONFENTRY_CIPHERKEY];
        }
    }
    return cipherKey;
}

/** version in config */
- (NSString *)version {
    NSString *version = [configEntries objectForKey:SWMOD_CONFENTRY_VERSION];
    if(version == nil) {
        version = [self configEntryForKey:SWMOD_CONFENTRY_VERSION];
        if(version != nil) {
            [configEntries setObject:version forKey:SWMOD_CONFENTRY_VERSION];
        }
    }
    return version;
}

/** minimum version in config */
- (NSString *)minVersion {
    NSString *minVersion = [configEntries objectForKey:SWMOD_CONFENTRY_MINVERSION];
    if(minVersion == nil) {
        minVersion = [self configEntryForKey:SWMOD_CONFENTRY_MINVERSION];
        if(minVersion != nil) {
            [configEntries setObject:minVersion forKey:SWMOD_CONFENTRY_MINVERSION];
        }
    }
    return minVersion;
}

- (NSString *)aboutText {
    NSString *aboutText = [configEntries objectForKey:SWMOD_CONFENTRY_ABOUT];
    if(aboutText == nil) {
        aboutText = [self configEntryForKey:SWMOD_CONFENTRY_ABOUT];
        if(aboutText != nil) {
            [configEntries setObject:aboutText forKey:SWMOD_CONFENTRY_ABOUT];
        }
    }
    return aboutText;    
}

/** read config entry for encoding */
- (BOOL)isUnicode {    
    return swModule->isUnicode();
}

/** is module encrypted/has a cipher key */
- (BOOL)isEncrypted {
    BOOL encrypted = YES;
    if([self cipherKey] == nil) {
        encrypted = NO;
    }
    return encrypted;
}

/** is module locked/has cipherkey config entry but cipherkey entry is empty */
- (BOOL)isLocked {
    BOOL locked = NO;
    
    NSString *key = [self cipherKey];
    if(key != nil) {
        if([key length] == 0) {
            locked = YES;
        }
    }
    
    return locked;
}

#pragma mark - SwordModuleAccess

/** 
 number of entries
 abstract method, should be overriden by subclasses
 */
- (long)entryCount {
    return 0;
}

- (int)htmlForRef:(NSString *)reference html:(NSString **)htmlString {
    int ret = 1;
    
    [moduleLock lock];
    if([self isUnicode]) {
        swModule->setKey(toUTF8(reference));
    } else {
        swModule->setKey(toLatin1(reference));
    }
    char *bytes = (char *)swModule->RenderText();
    [moduleLock unlock];
    
    *htmlString = [NSString stringWithUTF8String:bytes];
    
    return ret;
}

- (void)writeEntry:(NSString *)value forRef:(NSString *)reference {
}

#pragma mark - lowlevel access

// general feature access
- (BOOL)hasFeature:(NSString *)feature {
	BOOL has = NO;
	
	[moduleLock lock];
	if(swModule->getConfig().has("Feature", [feature UTF8String])) {
		has = YES;
    } else if (swModule->getConfig().has("GlobalOptionFilter",[[NSString stringWithFormat:@"GBF%@", feature] UTF8String])) {
 		has = YES;
    } else if (swModule->getConfig().has("GlobalOptionFilter",[[NSString stringWithFormat:@"ThML%@", feature] UTF8String])) {
 		has = YES;
    } else if (swModule->getConfig().has("GlobalOptionFilter",[[NSString stringWithFormat:@"UTF8%@", feature] UTF8String])) {
 		has = YES;
    } else if (swModule->getConfig().has("GlobalOptionFilter",[[NSString stringWithFormat:@"OSIS%@", feature] UTF8String])) {
 		has = YES;
    } else if (swModule->getConfig().has("GlobalOptionFilter",[feature UTF8String])) {
 		has = YES;
    }
	[moduleLock unlock];
	
	return has;
}

/** wrapper around getConfogEntry() */
- (NSString *)configEntryForKey:(NSString *)entryKey {
	NSString *result = nil;	
    
	[moduleLock lock];
    const char *entryStr = swModule->getConfigEntry([entryKey UTF8String]);
	if(entryStr) {
		result = [NSString stringWithUTF8String:entryStr];
    }
	[moduleLock unlock];
	
	return result;
}


- (sword::SWModule *)swModule {
	return swModule;
}

@end
