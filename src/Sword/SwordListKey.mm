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

@property (retain, readwrite) NSArray *verseKeyList;

@end

@implementation SwordListKey

@synthesize verseKeyList;

+ (id)listKeyWithRef:(NSString *)aRef {
    return [[SwordListKey alloc] initWithRef:aRef];
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
    self = [self init];
    if(self) {
        sword::VerseKey vk;
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

- (NSArray *)verseKeysForModule:(SwordBible *)aModule {
    NSMutableArray *ret = [NSMutableArray array];
    
    if(aModule && lk) {
        [aModule aquireModuleLock];
        for(*lk = sword::TOP; !lk->Error(); *lk++) {
            [aModule swModule]->setKey(*lk);
            if(![aModule error]) {
                const char *keyCStr = [aModule swModule]->getKeyText();
                NSString *key = @"";
                key = [NSString stringWithUTF8String:keyCStr];
                
                // create versekey
                SwordVerseKey *vk = [SwordVerseKey verseKeyWithRef:key];
                [ret addObject:vk];                
            }
        }        
        [aModule releaseModuleLock];
    }
    
    return ret;
}

- (sword::ListKey *)listKey {
    return lk;
}

@end
