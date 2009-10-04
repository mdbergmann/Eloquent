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
    return [[SwordListKey alloc] initWithRef:aRef];
}

+ (id)listKeyWithRef:(NSString *)aRef versification:(NSString *)scheme {
    return [[SwordListKey alloc] initWithRef:aRef versification:scheme];
}

- (id)init {
    return [super init];
}

- (id)initWithSWListKey:(sword::ListKey *)aLk {
    self = [self init];
    if(self) {
        // copy reference
        lk = aLk;
        created = NO;
    }
    
    return self;
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
        lk = new sword::ListKey(listKey);
        created = YES;
    }
    
    return self;    
}

- (void)finalize {
    if(created) {
        delete lk;
    }
    
    [super finalize];
}

- (NSInteger)numberOfVerses {
    NSInteger ret = 0;
    
    if(lk) {
        for(*lk = sword::TOP; !lk->Error(); *lk++) ret++;    
    }
    
    return ret;
}

- (BOOL)containsKey:(SwordVerseKey *)aVerseKey {
    BOOL ret = NO;
    
    if(lk) {
        *lk = [[aVerseKey osisRef] UTF8String];
        ret = !lk->Error();
    }
    
    return ret;
}

- (sword::ListKey *)swListKey {
    return lk;
}

@end
