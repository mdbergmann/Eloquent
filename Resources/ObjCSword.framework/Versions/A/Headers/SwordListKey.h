//
//  SwordListKey.h
//  MacSword2
//
//  Created by Manfred Bergmann on 10.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwordKey.h"

#ifdef __cplusplus
#include <swkey.h>
#include <listkey.h>
#endif

@class SwordBible, VerseEnumerator;
@class SwordVerseKey;

@interface SwordListKey : SwordKey {
}

+ (SwordListKey *)listKeyWithRef:(NSString *)aRef;
+ (SwordListKey *)listKeyWithRef:(NSString *)aRef v11n:(NSString *)scheme;
+ (SwordListKey *)listKeyWithRef:(NSString *)aRef headings:(BOOL)headings v11n:(NSString *)scheme;

#ifdef __cplusplus
+ (SwordListKey *)listKeyWithSWListKey:(sword::ListKey *)aLk;
+ (SwordListKey *)listKeyWithSWListKey:(sword::ListKey *)aLk makeCopy:(BOOL)copy;
- (SwordListKey *)initWithSWListKey:(sword::ListKey *)aLk;
- (SwordListKey *)initWithSWListKey:(sword::ListKey *)aLk makeCopy:(BOOL)copy;
- (sword::ListKey *)swListKey;
#endif

- (SwordListKey *)initWithRef:(NSString *)aRef;
- (SwordListKey *)initWithRef:(NSString *)aRef v11n:(NSString *)scheme;
- (SwordListKey *)initWithRef:(NSString *)aRef headings:(BOOL)headings v11n:(NSString *)scheme;

- (void)parse;
- (void)parseWithHeaders;
- (VerseEnumerator *)verseEnumerator;

- (NSInteger)numberOfVerses;
- (BOOL)containsKey:(SwordVerseKey *)aVerseKey;

@end
