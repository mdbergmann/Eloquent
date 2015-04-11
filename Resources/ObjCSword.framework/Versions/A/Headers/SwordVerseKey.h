//
//  SwordVerseKey.h
//  MacSword2
//
//  Created by Manfred Bergmann on 17.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwordKey.h"

#ifdef __cplusplus
#include <versekey.h>
#endif

@interface SwordVerseKey : SwordKey {
}

+ (SwordVerseKey *)verseKey;
+ (SwordVerseKey *)verseKeyWithVersification:(NSString *)scheme;
+ (SwordVerseKey *)verseKeyWithRef:(NSString *)aRef;
+ (SwordVerseKey *)verseKeyWithRef:(NSString *)aRef v11n:(NSString *)scheme;

#ifdef __cplusplus
+ (SwordVerseKey *)verseKeyWithSWVerseKey:(sword::VerseKey *)aVk;
+ (SwordVerseKey *)verseKeyWithSWVerseKey:(sword::VerseKey *)aVk makeCopy:(BOOL)copy;
- (SwordVerseKey *)initWithSWVerseKey:(sword::VerseKey *)aVk;
- (SwordVerseKey *)initWithSWVerseKey:(sword::VerseKey *)aVk makeCopy:(BOOL)copy;
- (sword::VerseKey *)swVerseKey;
#endif

- (SwordVerseKey *)initWithVersification:(NSString *)scheme;
- (SwordVerseKey *)initWithRef:(NSString *)aRef;
- (SwordVerseKey *)initWithRef:(NSString *)aRef v11n:(NSString *)scheme;

- (int)index;
- (int)testament;
- (void)setTestament:(char)val;
- (int)book;
- (void)setBook:(char)val;
- (int)chapter;
- (void)setChapter:(int)val;
- (int)verse;
- (void)setVerse:(int)val;
- (BOOL)headings;
- (void)setHeadings:(BOOL)flag;
- (BOOL)autoNormalize;
- (void)setAutoNormalize:(BOOL)flag;
- (NSString *)bookName;
- (NSString *)osisBookName;
- (NSString *)osisRef;
- (void)setVersification:(NSString *)versification;
- (NSString *)versification;

@end
