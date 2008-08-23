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
#import "utils.h"

@interface SwordBook (/* Private, class continuation */)
/** private property */
@property(readwrite, retain) NSMutableArray *contents;

- (id)createContentsB:(sword::TreeKeyIdx *)treeKey;
@end

@implementation SwordBook

@synthesize contents;

- (id)initWithName:(NSString *)aName swordManager:(SwordManager *)aManager {
    
	self = [super initWithName:aName swordManager:aManager];
    if(self) {
        self.contents = nil;
    }
                         
	return self;
}

- (NSArray *)getContents {
    NSArray *ret = self.contents;
    if(ret == nil) {
        [moduleLock lock];
        if([contents count] == 0) {
            sword::TreeKeyIdx *treeKey = dynamic_cast<sword::TreeKeyIdx*>((sword::SWKey *)*(swModule));
            self.contents = (NSMutableArray *)[self createContentsB:treeKey];
        }
        [moduleLock unlock];
        // try again
        ret = self.contents;
    }
	return ret;    
}

// fill tree content with keys of book
- (id)createContentsB:(sword::TreeKeyIdx *)treeKey {
    
	char *treeNodeName = (char *)treeKey->getText();
	NSString *name = @"";
    
    // key encoding depends on module encoding
	if([self isUnicode]) {
		name = [NSString stringWithUTF8String:treeNodeName];
	} else {
		name = [NSString stringWithCString:treeNodeName encoding:NSISOLatin1StringEncoding];
	}
	
    // if this node has children, walk them
	if(treeKey->hasChildren()) {
		NSMutableArray *c = [NSMutableArray array];
		
		[c addObject:name];
        // get first child
		treeKey->firstChild();
		
        // walk the subtree
		do {
			[c addObject:[self createContentsB:treeKey]];
		}
		while(treeKey->nextSibling());
		
        // back to parent
		treeKey->parent();
        
        // returns the subtree array
		return c;
	}
	
    // returns the node name
	return name;
}

#pragma mark - SwordModuleAccess

- (long)entryCount {
    return [[self getContents] count];
}

- (NSArray *)stripedTextForRef:(NSString *)reference {
	return [super stripedTextForRef:[reference uppercaseString]];    
}

- (NSArray *)renderedTextForRef:(NSString *)reference {
    return [super renderedTextForRef:reference];
}

- (void)writeEntry:(NSString *)value forRef:(NSString *)reference {
    [super writeEntry:value forRef:reference];
}

@end
