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
    
    NSArray *verseKeyList;    
}

+ (id)listKeyWithRef:(NSString *)aRef;

#ifdef __cplusplus
- (id)initWithSWListKey:(sword::ListKey *)aLk;
- (sword::ListKey *)listKey;
#endif

- (id)initWithRef:(NSString *)aRef;

- (NSInteger)numberOfVerses;
- (BOOL)containsKey:(SwordVerseKey *)aVerseKey;
- (NSArray *)verseKeysForModule:(SwordBible *)aModule;

@end
