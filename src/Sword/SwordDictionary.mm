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
@property(readwrite, retain) NSMutableArray *entries;
@end

@interface SwordDictionary (PrivateAPI)

- (void)readEntries;
- (void)readFromCache;
- (void)writeToCache;

@end

@implementation SwordDictionary (PrivateAPI)

- (void)readEntries {
    
	if(entries == nil) {
        [self readFromCache];
    }
    
    // still no entries?
	if([entries count] == 0) {
        [moduleLock lock];
        
        NSMutableArray *arr = [NSMutableArray array];
        
        swModule->setSkipConsecutiveLinks(true);
        *swModule = sword::TOP;
        swModule->getRawEntry();        
        if(swModule->isUnicode()) {
            while (!swModule->Error()) {
                [arr addObject: [fromUTF8(swModule->KeyText()) capitalizedString]];
                (*swModule)++;
            }
        } else {
            while (!swModule->Error()) {
                [arr addObject: [fromLatin1(swModule->KeyText()) capitalizedString]];
                (*swModule)++;
            }
        }
        
        // set entries
        self.entries = arr;
        
        [moduleLock unlock];
        [self writeToCache];
    }
}

- (void)readFromCache {
	//open cached file
    NSString *cachePath = [DEFAULT_APPSUPPORT_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"cache-%@", [self name]]];
	NSMutableArray *data = [NSArray arrayWithContentsOfFile:cachePath];
    if(data != nil) {
        self.entries = data;
    } else {
        self.entries = [NSMutableArray array];
    }
}

- (void)writeToCache {
	// save cached file
    NSString *cachePath = [DEFAULT_APPSUPPORT_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"cache-%@", [self name]]];
	[entries writeToFile:cachePath atomically:NO];
}

@end

@implementation SwordDictionary

@synthesize entries;

- (id)initWithName:(NSString *)aName swordManager:(SwordManager *)aManager {
    
	self = [super initWithName:aName swordManager:aManager];
    if(self) {
        self.entries = nil;
    }
    	
	return self;
}

- (void)finalize {
	[super finalize];
}

- (NSArray *)getEntries {
    NSArray *ret = self.entries;
    if(ret == nil) {
        [self readEntries];
        ret = self.entries;
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
		result =  fromLatin1(swModule->KeyText());
    }
	[moduleLock unlock];
	
	return result;
}

// does dict have key?
- (BOOL)hasReference:(NSString *)ref {
	[moduleLock lock];
	
	sword::SWKey *key = swModule->CreateKey();
	if([self isUnicode]) {
		(*key) = toUTF8([ref uppercaseString]);
    } else {
		(*key) = toLatin1([ref uppercaseString]);
    }
	BOOL result = !key->Error();
	[moduleLock unlock];
	
	return result;
}

#pragma mark - SwordModuleAccess

- (int)htmlForRef:(NSString *)reference html:(NSString **)htmlString {
	return [super htmlForRef:[reference uppercaseString] html:htmlString];
}

- (long)entryCount {
    return [[self getEntries] count];
}

- (void)writeEntry:(NSString *)value forRef:(NSString *)reference {
    [super writeEntry:value forRef:reference];
}

@end
