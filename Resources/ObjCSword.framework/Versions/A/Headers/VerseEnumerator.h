//
//  VerseEnumerator.h
//  MacSword2
//
//  Created by Manfred Bergmann on 25.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SwordListKey;

@interface VerseEnumerator : NSEnumerator {
    SwordListKey *listKey;
}

- (id)initWithListKey:(SwordListKey *)aListKey;

- (NSArray *)allObjects;
- (NSString *)nextObject;

@end
