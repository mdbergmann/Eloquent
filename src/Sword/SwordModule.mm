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
#import "globals.h"
#import "MBPreferenceController.h"

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
    [self setType:[SwordModule moduleTypeForModuleTypeString:[self typeString]]];
    // init lock
    self.moduleLock = [[NSRecursiveLock alloc] init];
    self.indexLock = [[NSLock alloc] init];
    // nil values
    self.configEntries = [NSMutableDictionary dictionary];
    // set name
    self.name = [NSString stringWithCString:swModule->Name() encoding:NSUTF8StringEncoding];
}

@end

@implementation SwordModule

// -------------- property implementations -----------------
@synthesize configEntries;
@synthesize type;
@synthesize status;
@synthesize moduleLock;
@synthesize indexLock;
@synthesize swManager;
@synthesize name;

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

- (NSAttributedString *)fullAboutText {
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] init];
    
    // module Name, book name, type, lang, version, about
    // module name
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleName", @"") 
                                                                     attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [self name]] 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module description
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleDescription", @"")
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [self descr]] 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module type
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleType", @"") 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [self typeString]] 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module lang
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleLang", @"") 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [self lang]] 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module version
    attrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"AboutModuleVersion", @"") 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [self version]] 
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }
    
    // module about
    attrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", NSLocalizedString(@"AboutModuleAboutText", @"")]
                                                 attributes:[NSDictionary dictionaryWithObject:FontMoreLargeBold forKey:NSFontAttributeName]];
    [ret appendAttributedString:attrString];
    NSString *aboutStr = [self aboutText];
    //NSData *aboutData = [NSData dataWithBytes:[aboutStr UTF8String] length:[aboutStr length]];
    //NSData *aboutData = [NSData dataWithBytes:[aboutStr cStringUsingEncoding:NSISOLatin1StringEncoding] length:[aboutStr length]];
//    if(aboutData) {
//        attrString = [[NSAttributedString alloc] initWithRTF:aboutData documentAttributes:nil];
//    } else {
        attrString = [[NSAttributedString alloc] initWithString:aboutStr 
                                                     attributes:[NSDictionary dictionaryWithObject:FontMoreLarge forKey:NSFontAttributeName]];    
//    }
    if(attrString) {
        [ret appendAttributedString:attrString];    
    }

    return ret;
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

/**
 this might be RTF string
 */
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

- (BOOL)isEditable {
    BOOL ret = NO;
    NSString *editable = [configEntries objectForKey:SWMOD_CONFENTRY_EDITABLE];
    if(editable == nil) {
        editable = [self configEntryForKey:SWMOD_CONFENTRY_EDITABLE];
        if(editable != nil) {
            [configEntries setObject:editable forKey:SWMOD_CONFENTRY_EDITABLE];
        }
    }
    
    if(editable) {
        if([editable isEqualToString:@"YES"]) {
            ret = YES;
        }
    }
    
    return ret;
}

- (BOOL)isRTL {
    BOOL ret = NO;
    NSString *direction = [configEntries objectForKey:SWMOD_CONFENTRY_DIRECTION];
    if(direction == nil) {
        direction = [self configEntryForKey:SWMOD_CONFENTRY_DIRECTION];
        if(direction != nil) {
            [configEntries setObject:direction forKey:SWMOD_CONFENTRY_DIRECTION];
        }
    }
    
    if(direction) {
        if([direction isEqualToString:SW_DIRECTION_RTL]) {
            ret = YES;
        }
    }
    
    return ret;    
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
        // check user defaults, that's where we store the entered keys
        NSDictionary *cipherKeys = [userDefaults objectForKey:DefaultsModuleCipherKeysKey];
        if([key length] == 0 && [[cipherKeys allKeys] containsObject:[self name]] == NO) {
            locked = YES;
        }
    }
    
    return locked;
}

/** Sets the unlock key of the modules and writes the key into the pref file */
- (BOOL)unlock:(NSString *)unlockKey {
    
	if (![self isEncrypted]) {
		return NO;
    }
    
    NSMutableDictionary	*cipherKeys = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:DefaultsModuleCipherKeysKey]];
    [cipherKeys setObject:unlockKey forKey:[self name]];
    [userDefaults setObject:cipherKeys forKey:DefaultsModuleCipherKeysKey];
    
	[swManager setCipherKey:unlockKey forModuleNamed:[self name]];
    
	return YES;
}

- (id)attributeValueForEntryData:(NSDictionary *)data {

    id ret = nil;
    
    // first set module to key
    [moduleLock lock];
    NSString *passage = [data objectForKey:ATTRTYPE_PASSAGE];
    if(passage) {
        passage = [[passage stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } 
    NSString *attrType = [data objectForKey:ATTRTYPE_TYPE];
    if([attrType isEqualToString:@"n"]) {
        if([self isUnicode]) {
            swModule->setKey([passage UTF8String]);
        } else {
            swModule->setKey([passage cStringUsingEncoding:NSISOLatin1StringEncoding]);
        }
        swModule->RenderText(); // force processing of key
        
        sword::SWBuf footnoteText = swModule->getEntryAttributes()["Footnote"][[[data objectForKey:ATTRTYPE_VALUE] UTF8String]]["body"].c_str();
        // convert from base markup to display markup
        char *fText = (char *)swModule->StripText(footnoteText);
        ret = [NSString stringWithUTF8String:fText];
    } else if([attrType isEqualToString:@"x"]) {
        if([self isUnicode]) {
            swModule->setKey([passage UTF8String]);
        } else {
            swModule->setKey([passage cStringUsingEncoding:NSISOLatin1StringEncoding]);
        }
        swModule->RenderText(); // force processing of key
        
        sword::SWBuf refList = swModule->getEntryAttributes()["Footnote"][[[data objectForKey:ATTRTYPE_VALUE] UTF8String]]["refList"];
        sword::VerseKey parser([passage UTF8String]);
        sword::ListKey refs = parser.ParseVerseList(refList, parser, true);
        
        ret = [NSMutableArray array];
        // collect references
        for(refs = sword::TOP; !refs.Error(); refs++) {
            swModule->setKey(refs);
            
            NSString *key = [NSString stringWithUTF8String:swModule->getKeyText()];
            NSString *text = [NSString stringWithUTF8String:swModule->StripText()];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
            [dict setObject:text forKey:SW_OUTPUT_TEXT_KEY];
            [dict setObject:key forKey:SW_OUTPUT_REF_KEY];
            [ret addObject:dict];            
        }
    } else if([attrType isEqualToString:@"scriptRef"] || [attrType isEqualToString:@"scripRef"]) {
        NSString *key = [[[data objectForKey:ATTRTYPE_VALUE] stringByReplacingOccurrencesOfString:@"+" 
                                                                                       withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        sword::VerseKey parser("gen.1.1");
        sword::ListKey refs = parser.ParseVerseList([key UTF8String], parser, true);
        
        ret = [NSMutableArray array];
        // collect references
        for(refs = sword::TOP; !refs.Error(); refs++) {
            swModule->setKey(refs);
            
            NSString *key = [NSString stringWithUTF8String:swModule->getKeyText()];
            NSString *text = [NSString stringWithUTF8String:swModule->StripText()];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
            [dict setObject:text forKey:SW_OUTPUT_TEXT_KEY];
            [dict setObject:key forKey:SW_OUTPUT_REF_KEY];
            [ret addObject:dict];            
        }
    } else if([attrType isEqualToString:@"Greek"] || [attrType isEqualToString:@"Hebrew"]) {
        NSString *key = [data objectForKey:ATTRTYPE_VALUE];        

        swModule->setKey([key UTF8String]);
        NSString *text = [NSString stringWithUTF8String:swModule->StripText()];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        [dict setObject:text forKey:SW_OUTPUT_TEXT_KEY];
        [dict setObject:key forKey:SW_OUTPUT_REF_KEY];
        
        ret = dict;
    }
    
    [moduleLock unlock];
    
    return ret;
}

#pragma mark - SwordModuleAccess

/** 
 number of entries
 abstract method, should be overriden by subclasses
 */
- (long)entryCount {
    return 0;
}

- (NSArray *)stripedTextForRef:(NSString *)reference {
    NSArray *ret = nil;
    
    [moduleLock lock];
    if([self isUnicode]) {
        swModule->setKey([reference UTF8String]);
    } else {
        swModule->setKey([reference cStringUsingEncoding:NSISOLatin1StringEncoding]);
    }
    char *bytes = (char *)swModule->StripText();
    [moduleLock unlock];
    
    if(bytes != NULL) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        NSString *entry = [NSString stringWithUTF8String:bytes];
        if(!entry) {
            entry = [NSString stringWithCString:bytes encoding:NSISOLatin1StringEncoding];
            if(!entry) {
                MBLOG(MBLOG_ERR, @"[SwordModule -stripedTextForRef:] cannot convert string!");
                // make valid String
                entry = @"";
            }
        }
        [dict setObject:entry forKey:SW_OUTPUT_TEXT_KEY];        
        [dict setObject:reference forKey:SW_OUTPUT_REF_KEY];
        ret = [NSArray arrayWithObject:dict];
    }
    
    return ret;    
}

- (NSArray *)renderedTextForRef:(NSString *)reference {
    NSArray *ret = nil;
    
    [moduleLock lock];
    if([self isUnicode]) {
        swModule->setKey([reference UTF8String]);
    } else {
        swModule->setKey([reference cStringUsingEncoding:NSISOLatin1StringEncoding]);
    }
    char *bytes = (char *)swModule->RenderText();
    [moduleLock unlock];
    
    if(bytes != NULL) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        NSString *entry = [NSString stringWithUTF8String:bytes];
        if(!entry) {
            entry = [NSString stringWithCString:bytes encoding:NSISOLatin1StringEncoding];
            if(!entry) {
                MBLOG(MBLOG_ERR, @"[SwordModule -stripedTextForRef:] cannot convert string!");
                // make valid String
                entry = @"";
            }
        }
        [dict setObject:entry forKey:SW_OUTPUT_TEXT_KEY];        
        [dict setObject:reference forKey:SW_OUTPUT_REF_KEY];
        ret = [NSArray arrayWithObject:dict];
    }
    
    return ret;
}

/**
 subclasses need to implement this
 */
- (void)writeEntry:(NSString *)value forRef:(NSString *)reference {
}

- (NSString *)description {
    return [self name];
}

#pragma mark - lowlevel access

// general feature access
- (BOOL)hasFeature:(NSString *)feature {
	BOOL has = NO;
	
	[moduleLock lock];
	if(swModule->getConfig().has("Feature", [feature UTF8String])) {
		has = YES;
    } else if (swModule->getConfig().has("GlobalOptionFilter", [[NSString stringWithFormat:@"GBF%@", feature] UTF8String])) {
 		has = YES;
    } else if (swModule->getConfig().has("GlobalOptionFilter", [[NSString stringWithFormat:@"ThML%@", feature] UTF8String])) {
 		has = YES;
    } else if (swModule->getConfig().has("GlobalOptionFilter", [[NSString stringWithFormat:@"UTF8%@", feature] UTF8String])) {
 		has = YES;
    } else if (swModule->getConfig().has("GlobalOptionFilter", [[NSString stringWithFormat:@"OSIS%@", feature] UTF8String])) {
 		has = YES;
    } else if (swModule->getConfig().has("GlobalOptionFilter", [feature UTF8String])) {
 		has = YES;
    }
	[moduleLock unlock];
	
	return has;
}

/** wrapper around getConfigEntry() */
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
