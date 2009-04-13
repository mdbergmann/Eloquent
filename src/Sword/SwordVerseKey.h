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

#ifdef __cplusplus
- (id)initWithSWVerseKey:(sword::VerseKey *)aVk;
- (sword::VerseKey *)verseKey;
#endif

- (id)initWithRef:(NSString *)aRef;

- (int)testament;
- (int)book;
- (int)chapter;
- (int)verse;
- (NSString *)bookName;
- (NSString *)osisBookName;
- (NSString *)osisRef;

@end
