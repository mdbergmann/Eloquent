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
#import "VerseEnumerator.h"

@interface SwordListKey ()
@end

@implementation SwordListKey

+ (id)listKeyWithRef:(NSString *)aRef {
    return [[[SwordListKey alloc] initWithRef:aRef] autorelease];
}

+ (id)listKeyWithRef:(NSString *)aRef v11n:(NSString *)scheme {
    return [[[SwordListKey alloc] initWithRef:aRef v11n:scheme] autorelease];
}

+ (id)listKeyWithRef:(NSString *)aRef headings:(BOOL)headings v11n:(NSString *)scheme {
    return [[[SwordListKey alloc] initWithRef:aRef headings:headings v11n:scheme] autorelease];
}

+ (id)listKeyWithSWListKey:(sword::ListKey *)aLk {
    return [[[SwordListKey alloc] initWithSWListKey:aLk] autorelease];
}

+ (id)listKeyWithSWListKey:(sword::ListKey *)aLk makeCopy:(BOOL)copy {
    return [[[SwordListKey alloc] initWithSWListKey:aLk makeCopy:copy] autorelease];    
}

- (id)init {
    return [super init];
}

- (id)initWithSWListKey:(sword::ListKey *)aLk {
    return [super initWithSWKey:aLk];
}

- (id)initWithSWListKey:(sword::ListKey *)aLk makeCopy:(BOOL)copy {
    return [super initWithSWKey:aLk makeCopy:copy];
}

- (id)initWithRef:(NSString *)aRef {
    return [self initWithRef:aRef v11n:nil];
}

- (id)initWithRef:(NSString *)aRef v11n:(NSString *)scheme {
    return [self initWithRef:aRef headings:NO v11n:scheme];
}

- (id)initWithRef:(NSString *)aRef headings:(BOOL)headings v11n:(NSString *)scheme {
    sword::VerseKey vk;
    vk.Headings((char)headings);
    if(scheme) {
        vk.setVersificationSystem([scheme UTF8String]);
    }
    sword::ListKey listKey = vk.ParseVerseList([aRef UTF8String], "gen", true);
    sword::ListKey *lk = new sword::ListKey(listKey);
    return [super initWithSWKey:lk];    
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

- (void)parse {
    
}

- (void)parseWithHeaders {
    
}

- (VerseEnumerator *)verseEnumerator {
    return [[[VerseEnumerator alloc] initWithListKey:self] autorelease];
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
