//
//  SwordVerseKey.mm
//  MacSword2
//
//  Created by Manfred Bergmann on 17.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordVerseKey.h"


@implementation SwordVerseKey

+ (id)verseKey {
    return [[[SwordVerseKey alloc] init] autorelease];
}

+ (id)verseKeyWithVersification:(NSString *)scheme {
    return [[[SwordVerseKey alloc] initWithVersification:scheme] autorelease];
}

+ (id)verseKeyWithRef:(NSString *)aRef {
    return [[[SwordVerseKey alloc] initWithRef:aRef] autorelease];
}

+ (id)verseKeyWithRef:(NSString *)aRef versification:(NSString *)scheme {
    return [[[SwordVerseKey alloc] initWithRef:aRef versification:scheme] autorelease];
}

+ (id)verseKeyWithSWVerseKey:(sword::VerseKey *)aVk {
    return [[[SwordVerseKey alloc] initWithSWVerseKey:aVk] autorelease];
}

- (id)init {
    return [self initWithRef:nil];
}

- (id)initWithVersification:(NSString *)scheme {
    return [self initWithRef:nil versification:scheme];
}

- (id)initWithSWVerseKey:(sword::VerseKey *)aVk {
    self = [super initWithSWKey:aVk];
    if(self) {
        [self swVerseKey]->setVersificationSystem(aVk->getVersificationSystem());
    }
    return self;
}

- (id)initWithRef:(NSString *)aRef {
    return [self initWithRef:aRef versification:nil];
}

- (id)initWithRef:(NSString *)aRef versification:(NSString *)scheme {
    sword::VerseKey *vk = new sword::VerseKey();            
    self = [super initWithSWKey:vk];
    if(self) {
        created = YES;
        if(scheme) {
            [self setVersification:scheme];
        }
        
        if(aRef) {
            [self setKeyText:aRef];
        }        
    }    
    
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [super dealloc];    
}

- (id)clone {
    return [SwordVerseKey verseKeyWithSWVerseKey:(sword::VerseKey *)sk];
}

- (BOOL)headings {
    return (BOOL)((sword::VerseKey *)sk)->Headings();
}

- (void)setHeadings:(BOOL)flag {
    ((sword::VerseKey *)sk)->Headings((int)flag);
}

- (BOOL)autoNormalize {
    return (BOOL)((sword::VerseKey *)sk)->AutoNormalize();
}

- (void)setAutoNormalize:(BOOL)flag {
    ((sword::VerseKey *)sk)->AutoNormalize((int)flag);    
}

- (int)testament {
    return ((sword::VerseKey *)sk)->getTestament();
}

- (int)book {
    return ((sword::VerseKey *)sk)->getBook();
}

- (int)chapter {
    return ((sword::VerseKey *)sk)->getChapter();
}

- (int)verse {
    return ((sword::VerseKey *)sk)->getVerse();
}

- (void)setTestament:(int)val {
    ((sword::VerseKey *)sk)->setTestament(val);
}

- (void)setBook:(int)val {
    ((sword::VerseKey *)sk)->setBook(val);
}

- (void)setChapter:(int)val {
    ((sword::VerseKey *)sk)->setChapter(val);
}

- (void)setVerse:(int)val {
    ((sword::VerseKey *)sk)->setVerse(val);
}

- (NSString *)bookName {
    return [NSString stringWithUTF8String:((sword::VerseKey *)sk)->getBookName()];
}

- (NSString *)osisBookName {
    return [NSString stringWithUTF8String:((sword::VerseKey *)sk)->getOSISBookName()];
}

- (NSString *)osisRef {
    return [NSString stringWithUTF8String:((sword::VerseKey *)sk)->getOSISRef()];    
}

- (void)setVersification:(NSString *)versification {
    ((sword::VerseKey *)sk)->setVersificationSystem([versification UTF8String]);
}

- (NSString *)versification {
    return [NSString stringWithUTF8String:((sword::VerseKey *)sk)->getVersificationSystem()];
}

- (sword::VerseKey *)swVerseKey {
    return (sword::VerseKey *)sk;
}

@end
