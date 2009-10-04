//
//  SwordListKey.h
//  MacSword2
//
//  Created by Manfred Bergmann on 10.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
#include <versekey.h>
#include <listkey.h>
#endif

@class SwordBible;
@class SwordVerseKey;

@interface SwordListKey : NSObject {
#ifdef __cplusplus
    sword::ListKey *lk;
#endif
    BOOL created;
}

+ (id)listKeyWithRef:(NSString *)aRef;
+ (id)listKeyWithRef:(NSString *)aRef versification:(NSString *)scheme;

#ifdef __cplusplus
- (id)initWithSWListKey:(sword::ListKey *)aLk;
- (sword::ListKey *)swListKey;
#endif

- (id)initWithRef:(NSString *)aRef;
- (id)initWithRef:(NSString *)aRef versification:(NSString *)scheme;

- (NSInteger)numberOfVerses;
- (BOOL)containsKey:(SwordVerseKey *)aVerseKey;

@end
