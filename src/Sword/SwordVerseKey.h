//
//  SwordVerseKey.h
//  MacSword2
//
//  Created by Manfred Bergmann on 17.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
#include <versekey.h>
#endif

@interface SwordVerseKey : NSObject {
#ifdef __cplusplus
    sword::VerseKey *vk;
#endif
    BOOL created;
}

+ (id)verseKeyWithRef:(NSString *)aRef;
+ (id)verseKeyWithRef:(NSString *)aRef versification:(NSString *)scheme;

#ifdef __cplusplus
- (id)initWithSWVerseKey:(sword::VerseKey *)aVk;
- (sword::VerseKey *)swVerseKey;
#endif

- (id)initWithRef:(NSString *)aRef;
- (id)initWithRef:(NSString *)aRef versification:(NSString *)scheme;

- (int)testament;
- (int)book;
- (int)chapter;
- (int)verse;
- (void)setTestament:(int)val;
- (void)setBook:(int)val;
- (void)setChapter:(int)val;
- (void)setVerse:(int)val;
- (void)decrement;
- (void)increment;
- (NSString *)keyText;
- (NSString *)bookName;
- (NSString *)osisBookName;
- (NSString *)osisRef;
- (void)setVersification:(NSString *)versification;
- (NSString *)versification;

@end
