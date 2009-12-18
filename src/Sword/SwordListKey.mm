//
//  SwordListKey.mm
//  MacSword2
//
//  Created by Manfred Bergmann on 10.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordListKey.h"
#import "SwordBible.h"
#import "SwordVerseKey.h"


@interface SwordListKey ()

@end

@implementation SwordListKey

+ (id)listKeyWithRef:(NSString *)aRef {
    return [[[SwordListKey alloc] initWithRef:aRef] autorelease];
}

+ (id)listKeyWithRef:(NSString *)aRef versification:(NSString *)scheme {
    return [[[SwordListKey alloc] initWithRef:aRef versification:scheme] autorelease];
}

- (id)init {
    return [super init];
}

- (id)initWithSWListKey:(sword::ListKey *)aLk {
    return [super initWithSWKey:aLk];
}

- (id)initWithRef:(NSString *)aRef {
    return [self initWithRef:aRef versification:nil];
}

- (id)initWithRef:(NSString *)aRef versification:(NSString *)scheme {
    self = [self init];
    if(self) {
        sword::VerseKey vk;
        if(scheme) {
            vk.setVersificationSystem([scheme UTF8String]);
        }
        sword::ListKey listKey = vk.ParseVerseList([aRef UTF8String], "Gen1", true);
        sk = new sword::ListKey(listKey);
        created = YES;
    }
    
    return self;    
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [super dealloc];    
}

- (NSInteger)numberOfVerses {
    NSInteger ret = 0;
    
    if(sk) {
        for(*sk = sword::TOP; !sk->Error(); *sk++) ret++;    
    }
    
    return ret;
}

- (BOOL)containsKey:(SwordVerseKey *)aVerseKey {
    BOOL ret = NO;
    
    if(sk) {
        *sk = [[aVerseKey osisRef] UTF8String];
        ret = !sk->Error();
    }
    
    return ret;
}

- (sword::ListKey *)swListKey {
    return (sword::ListKey *)sk;
}

@end
