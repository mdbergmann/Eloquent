//
//  SwordKey.h
//  MacSword2
//
//  Created by Manfred Bergmann on 17.12.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <swkey.h>
#endif

@interface SwordKey : NSObject {
#ifdef __cplusplus
    sword::SWKey *sk;
#endif
    BOOL created;
}

+ (SwordKey *)swordKey;
+ (SwordKey *)swordKeyWithRef:(NSString *)aRef;

#ifdef __cplusplus
+ (SwordKey *)swordKeyWithSWKey:(sword::SWKey *)aSk;
+ (SwordKey *)swordKeyWithSWKey:(sword::SWKey *)aSk makeCopy:(BOOL)copy;
- (SwordKey *)initWithSWKey:(sword::SWKey *)aSk;
- (SwordKey *)initWithSWKey:(sword::SWKey *)aSk makeCopy:(BOOL)copy;
- (sword::SWKey *)swKey;
#endif

- (SwordKey *)initWithRef:(NSString *)aRef;

- (SwordKey *)clone;
- (void)setPersist:(BOOL)flag;
- (BOOL)persist;

- (int)error;

- (void)setPosition:(int)aPosition;
- (void)decrement;
- (void)increment;
- (NSString *)keyText;
- (void)setKeyText:(NSString *)aKey;

@end
