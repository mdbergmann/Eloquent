//
//  SwordListKey.h
//  MacSword2
//
//  Created by Manfred Bergmann on 10.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SwordKey.h>

#ifdef __cplusplus
#include <swkey.h>
#include <listkey.h>
#endif

@class SwordBible, VerseEnumerator;

@interface SwordListKey : SwordKey {
}

+ (id)listKeyWithRef:(NSString *)aRef;
+ (id)listKeyWithRef:(NSString *)aRef v11n:(NSString *)scheme;
+ (id)listKeyWithRef:(NSString *)aRef headings:(BOOL)headings v11n:(NSString *)scheme;

#ifdef __cplusplus
+ (id)listKeyWithSWListKey:(sword::ListKey *)aLk;
+ (id)listKeyWithSWListKey:(sword::ListKey *)aLk makeCopy:(BOOL)copy;
- (id)initWithSWListKey:(sword::ListKey *)aLk;
- (id)initWithSWListKey:(sword::ListKey *)aLk makeCopy:(BOOL)copy;
- (sword::ListKey *)swListKey;
#endif

- (id)initWithRef:(NSString *)aRef;
- (id)initWithRef:(NSString *)aRef v11n:(NSString *)scheme;
- (id)initWithRef:(NSString *)aRef headings:(BOOL)headings v11n:(NSString *)scheme;

- (void)parse;
- (void)parseWithHeaders;
- (VerseEnumerator *)verseEnumerator;

- (NSInteger)numberOfVerses;
- (BOOL)containsKey:(SwordKey *)aVerseKey;

@end
