/*	SwordManager.h - Sword API wrapper for Modules.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import <Foundation/Foundation.h>
#import "SwordModule.h"

#ifdef __cplusplus
#include <swmgr.h>		// C++ Sword API
#include <localemgr.h>
#include <versekey.h>
#endif

/** the major types as returned in -[SwordModule -typeString] */
#define SWMOD_TYPES_BIBLES              @"Biblical Texts"
#define SWMOD_TYPES_COMMENTARIES        @"Commentaries"
#define SWMOD_TYPES_DICTIONARIES        @"Lexicons / Dictionaries"
#define SWMOD_TYPES_GENBOOKS            @"Generic Books"

#define SWMOD_CATEGORY_DAILYDEVS        @"Daily Devotional"
#define SWMOD_CATEGORY_GLOSSARIES       @"Glossaries"
#define SWMOD_CATEGORY_CULTS            @"Cults / Unorthodox / Questionable Material"
#define SWMOD_CATEGORY_ESSEYS           @"Essays"
#define SWMOD_CATEGORY_MAPS             @"Maps"
#define SWMOD_CATEGORY_IMAGES           @"Images"

/** number of sword module stypes */
#define SWMODTYPE_COUNT                 5

/** config entries */
#define SWMOD_CONFENTRY_VERSION             @"Version"
#define SWMOD_CONFENTRY_MINVERSION          @"MinimumVersion"
#define SWMOD_CONFENTRY_CIPHERKEY           @"CipherKey"
#define SWMOD_CONFENTRY_ABOUT               @"About"
#define SWMOD_CONFENTRY_CATEGORY            @"Category"
#define SWMOD_CONFENTRY_INSTALLSIZE         @"InstallSize"
#define SWMOD_CONFENTRY_COPYRIGHT           @"Copyright"
#define SWMOD_CONFENTRY_COPYRIGHTHOLDER     @"CopyrightHolder"
#define SWMOD_CONFENTRY_DISTRLICENSE        @"DistributionLicense"
#define SWMOD_CONFENTRY_DISTRNOTES          @"DistributionNotes"
#define SWMOD_CONFENTRY_TEXTSOURCE          @"TextSource"
#define SWMOD_CONFENTRY_VERSIFICATION       @"Versification"
#define SWMOD_CONFENTRY_DIRECTION           @"Direction"
#define SWMOD_CONFENTRY_EDITABLE            @"Editable"

/** module features */
#define SWMOD_FEATURE_STRONGS           @"Strongs"
#define SWMOD_FEATURE_HEADINGS          @"Headings"
#define SWMOD_FEATURE_FOOTNOTES         @"Footnotes"
#define SWMOD_FEATURE_MORPH             @"Morph"
#define SWMOD_FEATURE_CANTILLATION      @"Cantillation"
#define SWMOD_FEATURE_HEBREWPOINTS      @"HebrewPoints"
#define SWMOD_FEATURE_GREEKACCENTS      @"GreekAccents"
#define SWMOD_FEATURE_LEMMA             @"Lemma"
#define SWMOD_FEATURE_SCRIPTREF         @"Scripref"     // not Scriptref
#define SWMOD_FEATURE_VARIANTS          @"Variants"
#define SWMOD_FEATURE_REDLETTERWORDS    @"RedLetterWords"

/** global options */
#define SW_OPTION_STRONGS               @"Strong's Numbers"
#define SW_OPTION_HEADINGS              @"Headings"
#define SW_OPTION_FOOTNOTES             @"Footnotes"
#define SW_OPTION_MORPHS                @"Morphological Tags"
#define SW_OPTION_HEBREWCANTILLATION    @"Hebrew Cantillation"
#define SW_OPTION_HEBREWPOINTS          @"Hebrew Vowel Points"
#define SW_OPTION_GREEKACCENTS          @"Greek Accents"
#define SW_OPTION_LEMMAS                @"Lemmas"
#define SW_OPTION_SCRIPTREFS            @"Cross-references"
#define SW_OPTION_VARIANTS              @"Textual Variants"
#define SW_OPTION_REDLETTERWORDS        @"Words of Christ in Red"
// this is not part of Sword
#define SW_OPTION_REF                   @"Reference"
#define SW_OPTION_MODULENAME            @"ModuleName"

/** config features definitions */
#define SWMOD_CONF_FEATURE_STRONGS       @"StrongsNumbers"
#define SWMOD_CONF_FEATURE_GREEKDEF      @"GreekDef"
#define SWMOD_CONF_FEATURE_HEBREWDEF     @"HebrewDef"
#define SWMOD_CONF_FEATURE_GREEKPARSE    @"GreekParse"
#define SWMOD_CONF_FEATURE_HEBREWPARSE   @"HebrewParse"
#define SWMOD_CONF_FEATURE_DAILYDEVOTION @"DailyDevotion"
#define SWMOD_CONF_FEATURE_GLOSSARY      @"Glossary"
#define SWMOD_CONF_FEATURE_IMAGES        @"Images"

/** On / Off */
#define SW_ON    @"On"
#define SW_OFF   @"Off"

// direction
#define SW_DIRECTION_RTL    @"RtoL"

// CipherKeys NSUserdefaultsKey
#define DefaultsModuleCipherKeysKey     @"DefaultsModuleCipherKeysKey"

@interface SwordManager : NSObject {
    
#ifdef __cplusplus
	sword::SWMgr *swManager;
#endif

}

// ------------------- getter / setter -------------------
@property (strong, readwrite) NSString *modulesPath;
@property (strong, readwrite) NSLock *managerLock;

// --------------------- methods -----------------------

/**
 Convenience initializer. Creates an instance of SwordManager for a given module path.
 Internally -initWithPath: is called.
 */
+ (SwordManager *)managerWithPath:(NSString*)path;

/**
 Create an instance of SwordManager that will get the default manager
 in this application.
 Internally a static reference is set so that this instance will get a singleton object.
 */
+ (SwordManager *)defaultManager;

/**
 Retrieve a list of known module types.
 See SWMOD_CATEGORY_*
 */
+ (NSArray *)moduleTypes;

/** uses the current instance as default manager */
- (void)useAsDefaultManager;

/**
 Initializes this manager for the given module path.
 */
- (id)initWithPath:(NSString *)path;

/**
 Add an additional path to the manager to augment more modules.
 */
- (void)addModulesPath:(NSString*)path;

/** 
 Loads all modules, filters and such
 */
- (void)initManager;

/** should be called to reload all modules and such */
- (void)reloadManager;

/**
 Set a cipher key for the given module to make it unlocked and in order to render it's text.
 */
- (void)setCipherKey:(NSString*)key forModuleNamed:(NSString *)name;

/**
 Set a global option, for example render option.
 */
- (void)setGlobalOption:(NSString*)option value:(NSString *)value;

/**
 Returns the value of an option.
 */
- (BOOL)globalOption:(NSString *)option;

/** the number of modules */
- (NSInteger)numberOfModules;

/**
 List of module names known by this manager
 */
- (NSArray *)moduleNames;

/**
 List of modules known by this manager
 */
- (NSDictionary *)allModules;

/**
 Module list sorted by name
 */
- (NSArray *)sortedModuleNames;

/**
 Get module with name from internal list
 */
- (SwordModule *)moduleWithName:(NSString *)name;

/**
 Get modules with certain feature from internal list
 */
- (NSArray *)modulesForFeature:(NSString *)feature;

/**
 Get modules with certain type from internal list
 */
- (NSArray *)modulesForType:(ModuleType)type;

/**
 Get modules with certain category from the internal list
 */
- (NSArray *)modulesForCategory:(ModuleCategory)cat;

#ifdef __cplusplus
- (id)initWithSWMgr:(sword::SWMgr *)swMgr;
- (sword::SWModule *)getSWModuleWithName:(NSString *)moduleName;

/**
 Returns the underlying sword::SWMgr instance
 */
- (sword::SWMgr *)swManager;

#endif

@end
