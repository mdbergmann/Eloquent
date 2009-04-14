//
//  SwordVerseKey.mm
//  MacSword2
//
//  Created by Manfred Bergmann on 17.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordVerseKey.h"


@implementation SwordVerseKey

+ (id)verseKeyWithRef:(NSString *)aRef {
    return [[SwordVerseKey alloc] initWithRef:aRef];
}

+ (id)verseKeyWithRef:(NSString *)aRef versification:(NSString *)scheme {
    return [[SwordVerseKey alloc] initWithRef:aRef versification:scheme];    
}

- (id)init {
    return [super init];
}

- (id)initWithSWVerseKey:(sword::VerseKey *)aVk {
    self = [self init];
    if(self) {
        // copy reference
        vk = aVk;
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
        vk = new sword::VerseKey([aRef UTF8String]);
        created = YES;
        
        if(scheme) {
            [self setVersification:scheme];
        }
    }
    
    return self;    
}

- (void)finalize {
    if(created) {
        delete vk;
    }
    
    [super finalize];
}

- (int)testament {
    return vk->Testament();
}

- (int)book {
    return vk->Book();
}

- (int)chapter {
    return vk->Chapter();
}

- (int)verse {
    return vk->Verse();
}

- (NSString *)bookName {
    return [NSString stringWithUTF8String:vk->getBookName()];
}

- (NSString *)osisBookName {
    return [NSString stringWithUTF8String:vk->getOSISBookName()];
}

- (NSString *)osisRef {
    return [NSString stringWithUTF8String:vk->getOSISRef()];    
}

- (void)setVersification:(NSString *)versification {
    vk->setVersificationSystem([versification UTF8String]);
}

- (NSString *)versification {
    return [NSString stringWithUTF8String:vk->getVersificationSystem()];
}

- (sword::VerseKey *)verseKey {
    return vk;
}

@end
