/*	SwordDict.mm - Sword API wrapper for lexicons and Dictionaries.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import "SwordDictionary.h"
#import "utils.h"
#import "globals.h"

@interface SwordDictionary (/* Private, class continuation */)
/** private property */
@property(readwrite, retain) NSMutableArray *keys;
@end

@interface SwordDictionary (PrivateAPI)

- (void)readKeys;
- (void)readFromCache;
- (void)writeToCache;

@end

@implementation SwordDictionary (PrivateAPI)

/**
 only the keys are stored here in an array
 */
- (void)readKeys {
    
	if(keys == nil) {
        [self readFromCache];
    }
    
    // still no entries?
	if([keys count] == 0) {
        [moduleLock lock];
        
        NSMutableArray *arr = [NSMutableArray array];
        
        swModule->setSkipConsecutiveLinks(true);
        *swModule = sword::TOP;
        swModule->getRawEntry();        
        while(!swModule->Error()) {
            if(swModule->isUnicode()) {
                [arr addObject:[[NSString stringWithUTF8String:swModule->KeyText()] capitalizedString]];
            } else {
                [arr addObject:[[NSString stringWithCString:swModule->KeyText() encoding:NSISOLatin1StringEncoding] capitalizedString]];
            }
            (*swModule)++;
        }
        
        // set entries
        self.keys = arr;
        
        [moduleLock unlock];
        [self writeToCache];
    }
}

- (void)readFromCache {
	//open cached file
    NSString *cachePath = [DEFAULT_APPSUPPORT_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"cache-%@", [self name]]];
	NSMutableArray *data = [NSArray arrayWithContentsOfFile:cachePath];
    if(data != nil) {
        self.keys = data;
    } else {
        self.keys = [NSMutableArray array];
    }
}

- (void)writeToCache {
	// save cached file
    NSString *cachePath = [DEFAULT_APPSUPPORT_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"cache-%@", [self name]]];
	[keys writeToFile:cachePath atomically:NO];
}

@end

@implementation SwordDictionary

@synthesize keys;

- (id)initWithName:(NSString *)aName swordManager:(SwordManager *)aManager {
    
	self = [super initWithName:aName swordManager:aManager];
    if(self) {
        self.keys = nil;
    }
    	
	return self;
}

- (void)finalize {
	[super finalize];
}

- (NSArray *)allKeys {
    NSArray *ret = self.keys;
    if(ret == nil) {
        [self readKeys];
        ret = self.keys;
    }
	return ret;    
}

- (NSString *)fullRefName:(NSString *)ref {
	[moduleLock lock];
	
	sword::SWKey *key = swModule->CreateKey();	
	if([self isUnicode]) {
		(*key) = toUTF8([ref uppercaseString]);
    } else {
		(*key) = toLatin1([ref uppercaseString]);
    }
	
	swModule->setKey(key);
	swModule->getRawEntry();
	
	NSString *result;
	if([self isUnicode]) {
		result = fromUTF8(swModule->KeyText());
    } else {
		result = fromLatin1(swModule->KeyText());
    }
	[moduleLock unlock];
	
	return result;
}

/**
 returns stripped text for key.
 nil if the key does not exist.
 */
- (NSString *)entryForKey:(NSString *)aKey {
    NSString *ret = nil;
    
	[moduleLock lock];	
	sword::SWKey *swkey = swModule->CreateKey();
	if([self isUnicode]) {
		(*swkey) = [[aKey uppercaseString] UTF8String];
    } else {
		(*swkey) = [[aKey uppercaseString] cStringUsingEncoding:NSISOLatin1StringEncoding];
    }
    
    // error on key addressing?
	if(swkey->Error()) {
        MBLOG(MBLOG_ERR, @"[SwordDictionary -entryForKey:] error on getting key!");
    } else {
        // get text
        [self textForRef:aKey text:&ret];
    }
	[moduleLock unlock];
	
	return ret;
}

#pragma mark - SwordModuleAccess

- (int)textForRef:(NSString *)reference text:(NSString **)textString {
	return [super textForRef:[reference uppercaseString] text:textString];    
}

- (int)htmlForRef:(NSString *)reference html:(NSString **)htmlString {
	return [super htmlForRef:[reference uppercaseString] html:htmlString];
}

- (long)entryCount {
    return [[self allKeys] count];    
}

- (void)writeEntry:(NSString *)value forRef:(NSString *)reference {
    [super writeEntry:value forRef:reference];
}

@end
