//
//  NSArray+TextEntryDuplicateRemove.m
//  Eloquent
//
//  Created by Manfred Bergmann on 15.08.10.
//  Copyright 2010 CrossWire. All rights reserved.
//

#import "NSArray+TextEntryDuplicateRemove.h"
#import "ObjCSword/SwordModuleTextEntry.h"

@implementation NSArray (TextEntryDuplicateRemove)

- (NSArray *)arrayWithRemovedDuplicates {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    NSMutableDictionary *duplicateCheck = [NSMutableDictionary dictionaryWithCapacity:[self count]];
    
    for(SwordModuleTextEntry *entry in self) {
        if([duplicateCheck objectForKey:[entry key]] == nil) {
            [result addObject:entry];
        }
    }
    
    return result;
}

@end
