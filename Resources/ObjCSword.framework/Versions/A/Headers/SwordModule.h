/*	SwordModule.h - Sword API wrapper for Modules.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby
  
	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#import "swmodule.h"
#endif

// defines for dictionary entries for passage study
#define ATTRTYPE_TYPE       @"type"
#define ATTRTYPE_PASSAGE    @"passage"
#define ATTRTYPE_MODULE     @"modulename"
#define ATTRTYPE_NOTENUMBER @"notenumber"
#define ATTRTYPE_ACTION     @"action"
#define ATTRTYPE_VALUE      @"value"

// positions
#define SWPOS_BOTTOM   2
#define SWPOS_TOP      1


@class SwordManager, SwordModuleTextEntry, SwordKey, SwordFilter;

typedef enum {
    RenderTypeStripped = 1,
    RenderTypeRendered
}RenderType;

/** These are the main module types as returned in -typeString */
typedef enum {
    All         = 0x0000,
	Bible       = 0x0001, 
    Commentary  = 0x0002, 
    Dictionary  = 0x0004,
    Genbook     = 0x0008
}ModuleType;

/**
 These are the main module categories as returned in -categoryString
 Remember that modules type bible, commentary, dictionary and genbook not necessarily have a category
 */
typedef enum {
    Unset           = -1,
    NoCategory      = 0,
	DailyDevotion   = 0x0001, 
    Maps            = 0x0002, 
    Glossary        = 0x0004,
    Images          = 0x0008,
    Essays          = 0x0010,
    Cults           = 0x0011    
}ModuleCategory;


@interface SwordModule : NSObject {
	ModuleCategory category;

    /** yes, we have a delegate to report any action to */
    id delegate;

    NSLock *indexLock;
    NSRecursiveLock *moduleLock;
}

@property (retain, readwrite) SwordManager *swManager;
@property (readwrite) int status;
@property (readonly) ModuleType type;

#ifdef __cplusplus
/**
 Convenience initializer
 */
+ (id)moduleForSWModule:(sword::SWModule *)aModule;

/**
 Factory method that creates the correct module type instance for the given type
 */
+ (id)moduleForType:(ModuleType)aType swModule:(sword::SWModule *)swModule;

/**
 Initialize this module with an the SWModule.
 This initializer should normally not need to be used.
 */
- (id)initWithSWModule:(sword::SWModule *)aModule;

/**
 Retrieve the underlying SWModule instance
 */
- (sword::SWModule *)swModule;
#endif

/**
 maps type string to ModuleType enum
 @param[in] typeStr type String as in -typeString(SwordModule)
 @return type according to ModuleType enum
 */
+ (ModuleType)moduleTypeForModuleTypeString:(NSString *)typeStr;

/**
 maps type string to ModuleType enum
 @param[in] categoryStr category String as in -categoryString(SwordModule)
 @return type according to ModuleCategory enum
 */
+ (ModuleCategory)moduleCategoryForModuleCategoryString:(NSString *)categoryStr;

// ------------- instance methods ---------------

/** Sets a render filter to this module */
- (void)setRenderFilter:(SwordFilter *)aFilter;

/** Sets a strip filter to this module */
- (void)setStripFilter:(SwordFilter *)aFilter;

/**
 Any error while processing the module?
 */
- (NSInteger)error;

/** module name */
- (NSString *)name;
/** module description */
- (NSString *)descr;
/** module language */
- (NSString *)lang;
/** module type string */
- (NSString *)typeString;

// --------------- Conf entries --------------
/**
 Module category as string
 */
- (NSString *)categoryString;
/**
 Module category
 */
- (ModuleCategory)category;
/**
 Module version
 */
- (NSString *)version;
/**
 Module Promo string (ShortPromo)
 */
- (NSString *)shortPromo;
/**
 Module distribution license
 */
- (NSString *)distributionLicense;
/**
 Module minimum Sword version
 */
- (NSString *)minVersion;
/**
 Module about text
 */
- (NSString *)aboutText;
/**
 Override to get custom behaviour.
 */
- (NSAttributedString *)fullAboutText;
/**
 Module versification type
 */
- (NSString *)versification;
/**
 Is module Unicode UTF-8?
 */
- (BOOL)isUnicode;
/**
 Is module encrypted
 */
- (BOOL)isEncrypted;
/**
 Is module locked, that is encrypted but not unlocked?
 */
- (BOOL)isLocked;
/**
 Is module editable, i.e. is it's a personal commentary?
 */
- (BOOL)isEditable;
/**
 Is module writing direction Right to Left?
 */
- (BOOL)isRTL;
/**
 Has module this feature?
 See SWMOD_FEATURE_* in SwordManager
 */
- (BOOL)hasFeature:(NSString *)feature;
/**
 Returns a config entry for a given config key
 */
- (NSString *)configFileEntryForConfigKey:(NSString *)entryKey;

// ------------------ module access semaphores -----------------

- (void)lockIndexAccess;

- (void)unlockIndexAccess;

/**
 Aquires a module access lock so that no other thread may access this module.
 */
- (void)lockModuleAccess;
/**
 Unlock module access. Make it accessible to other threads.
 */
- (void)unlockModuleAccess;

// ----------------- module positioning ------------------------

/**
 Increment module key position
 */
- (void)incKeyPosition;
/**
 Decrement module key position
 */
- (void)decKeyPosition;
/**
 Set position key from a string
 */
- (SwordKey *)setKeyString:(NSString *)aKeyString;
/**
 Set position from a key
 */
- (SwordKey *)setSwordKey:(SwordKey *)aKey;

/**
 Module key. New instance created by module.
 */
- (SwordKey *)createKey;
/**
 Module key. Reference only.
 */
- (SwordKey *)getKey;

// ------------------- module metadata processing ------------------

/**
 Process metadata attributes of module entry.
 */
- (void)setProcessEntryAttributes:(BOOL)flag;
/**
 Are metadata attributes of module entry processed?
 */
- (BOOL)processEntryAttributes;

/**
 returns attribute values from the engine for notes, cross-refs and such for the given link type
 @return NSArray for references
 @return NSString for text data
 */
- (id)attributeValueForParsedLinkData:(NSDictionary *)data;
- (id)attributeValueForParsedLinkData:(NSDictionary *)data withTextRenderType:(RenderType)textType;

/** returns the pre-verse entry value */
- (NSString *)entryAttributeValuePreverse;
- (NSString *)entryAttributeValuePreverseForKey:(SwordKey *)aKey;

- (NSString *)entryAttributeValueFootnoteOfType:(NSString *)fnType indexValue:(NSString *)index;
- (NSString *)entryAttributeValueFootnoteOfType:(NSString *)fnType indexValue:(NSString *)index forKey:(SwordKey *)aKey;

- (NSArray *)entryAttributeValuesLemma;
- (NSArray *)entryAttributeValuesLemmaNormalized;

// ----------------- Module text access ----------------------

/**
 Returns a rendered text for the text at the current module position
 */
- (NSString *)renderedText;
/**
 Renders the given string with the modules render filters
 */
- (NSString *)renderedTextFromString:(NSString *)aString;
/**
 Returns a stripped text for the text at the current module position
 */
- (NSString *)strippedText;
/**
 Strips the given string with the modules strip filters
 */
- (NSString *)strippedTextFromString:(NSString *)aString;

/**
 Convenience method, delegates to textEntriesForReference:textType:
 This method generates stripped text string for a given reference.
 @param aReference bible reference
 @return Array of SwordModuleTextEntry instances
 */
- (NSArray *)strippedTextEntriesForReference:(NSString *)aReference;
/**
 * Convenience method, delegates to textEntryForReference:textType:
 * @param aReference the reference key. i.e. 'Gen 1'
 * @return a single text entry, or null if not found
 */
- (SwordModuleTextEntry *)strippedTextEntryForReference:(NSString *)aReference;

/**
 Convenience method, delegates to textEntriesForReference:textType:
 This method generates HTML string for a given reference.
 @param aReference bible reference
 @return Array of SwordModuleTextEntry instances
 */
- (NSArray *)renderedTextEntriesForReference:(NSString *)aReference;
/**
 * Convenience method, delegates to textEntryForReference:textType:
 * @param aReference the reference key. i.e. 'Gen 1'
 * @return a single text entry, or null if not found
 */
- (SwordModuleTextEntry *)renderedTextEntryForReference:(NSString *)aReference;

/**
 This contains real logic.
 Returns an array of text entries, either rendered or stripped.

 the block is called with each search result for custom activity.

 !!! attention, is SwordModule this only returns one entry because we don't know if we are a bible or what.
 Subclasses should extend or override the functionality !!!

 It locks and unlock the module.

 @return Array of SwordModuleTextEntry
 */
- (NSArray *)textEntriesForReference:(NSString *)aReference
                          renderType:(RenderType)aType
                           withBlock:(void(^)(SwordModuleTextEntry *))entryResult;

/**
 * Retrieves a text entry for the given reference.
 * @param aReference a reference as 'Gen 1' for bibles
 * @param aType
 * @return
 */
- (SwordModuleTextEntry *)textEntryForReference:(NSString *)aReference renderType:(RenderType)aType;

/**
 number of entries
 abstract method, should be overridden by subclasses
 */
- (long)entryCount;

/**
 Write text to module position
 */
- (void)writeEntry:(SwordModuleTextEntry *)anEntry;

@end
