/*	SwordBook.mm - Sword API wrapper for GenBooks.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import "SwordBook.h"
#import "SwordModule.h"
#import "SwordModuleTreeEntry.h"
#import "utils.h"

@interface SwordBook ()

- (SwordModuleTreeEntry *)_treeEntryForKey:(sword::TreeKeyIdx *)treeKey;

@end

@implementation SwordBook

@synthesize contents;

- (id)initWithName:(NSString *)aName swordManager:(SwordManager *)aManager {
	self = [super initWithName:aName swordManager:aManager];
    if(self) {
        [self setContents:[NSMutableDictionary dictionary]];
    }
                         
	return self;
}

- (id)initWithSWModule:(sword::SWModule *)aModule swordManager:(SwordManager *)aManager {
    self = [super initWithSWModule:aModule swordManager:aManager];
    if(self) {
        [self setContents:[NSMutableDictionary dictionary]];
    }
    
    return self;
}

/**
 return the tree content for the given treekey
 the treekey has to be already loaded
 @param[in]: treekey that we should look for, nil for root
 @return: SwordTreeEntry
 */
- (SwordModuleTreeEntry *)treeEntryForKey:(NSString *)treeKey {
    SwordModuleTreeEntry * ret = nil;
    
    if(treeKey == nil) {
        ret = [contents objectForKey:@"root"];
        if(ret == nil) {
            sword::TreeKeyIdx *treeKey = dynamic_cast<sword::TreeKeyIdx*>((sword::SWKey *)*(swModule));
            ret = [self _treeEntryForKey:treeKey];
            // add to content
            [contents setObject:ret forKey:@"root"];
        }
    } else {
        ret = [contents objectForKey:treeKey];
        if(ret == nil) {
            const char *keyStr = [treeKey UTF8String];
            if(![self isUnicode]) {
                keyStr = [treeKey cStringUsingEncoding:NSISOLatin1StringEncoding];
            }
            // position module
            sword::SWKey *mkey = new sword::SWKey(keyStr);
            swModule->setKey(mkey);
            sword::TreeKeyIdx *key = dynamic_cast<sword::TreeKeyIdx*>((sword::SWKey *)*(swModule));
            ret = [self _treeEntryForKey:key];
            // add to content
            [contents setObject:ret forKey:treeKey];
        }
    }
    
    return ret;
}

- (SwordModuleTreeEntry *)_treeEntryForKey:(sword::TreeKeyIdx *)treeKey {
    SwordModuleTreeEntry *ret = [[SwordModuleTreeEntry alloc] init];    
    
	char *treeNodeName = (char *)treeKey->getText();
	NSString *nname = @"";
    
    if(strlen(treeNodeName) == 0) {
        nname = @"root";
    } else {    
        // key encoding depends on module encoding
        nname = [NSString stringWithUTF8String:treeNodeName];
        if(!nname) {
            nname = [NSString stringWithCString:treeNodeName encoding:NSISOLatin1StringEncoding];
        }
    }
    // set name
    [ret setKey:nname];
    NSMutableArray *c = [NSMutableArray array];
    [ret setContent:c];
	
    // if this node has children, walk them
	if(treeKey->hasChildren()) {
        // get first child
		treeKey->firstChild();
        do {
            NSString *subname = @"";
            // key encoding depends on module encoding
            const char *textStr = treeKey->getText();
            subname = [NSString stringWithUTF8String:textStr];
            if(!subname) {
                subname = [NSString stringWithCString:textStr encoding:NSISOLatin1StringEncoding];
            }
            if(subname) {
                [c addObject:subname];            
            }
        }
        while(treeKey->nextSibling());            
	}
	
	return ret;
}

- (void)testLoop {
    SwordModuleTreeEntry *entry = [self treeEntryForKey:nil];
    if([[entry content] count] > 0) {
        for(NSString *subkey in [entry content]) {
            entry = [self treeEntryForKey:subkey];
            if([[entry content] count] > 0) {
            } else {
                MBLOGV(MBLOG_DEBUG, @"Entry: %@\n", [entry key]);
            }    
        }
    } else {
        MBLOGV(MBLOG_DEBUG, @"Entry: %@\n", [entry key]);
    }    
}

#pragma mark - SwordModuleAccess

- (long)entryCount {
    // TODO: set value according to maximum entries here
    return 1000;
}

@end
