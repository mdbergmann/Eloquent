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
}

#ifdef __cplusplus
+ (SwordKey *)swordKeyWithSWKey:(sword::SWKey *)aSk;
+ (SwordKey *)swordKeyWithNewSWKey:(sword::SWKey *)aSk;

/**
    This is only an assigned key. The module will handle deleting it.
*/
- (SwordKey *)initWithSWKey:(sword::SWKey *)aSk;

/**
    We have to handle deletion of this.
*/
- (SwordKey *)initWithNewSWKey:(sword::SWKey *)aSk;
- (sword::SWKey *)swKey;
#endif

@property (assign, readwrite) NSString *keyText;

- (int)error;

- (void)decrement;
- (void)increment;

- (void)setPosition:(int)pos;

@end
