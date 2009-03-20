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
    self = [self init];
    if(self) {
        vk = new sword::VerseKey([aRef UTF8String]);
        created = YES;
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

- (sword::VerseKey *)verseKey {
    return vk;
}

@end
