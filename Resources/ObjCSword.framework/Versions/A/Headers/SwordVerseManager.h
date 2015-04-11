//
//  SwordVerseManager.h
//  MacSword2
//
//  Created by Manfred Bergmann on 19.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <versificationmgr.h>
#endif

#define SW_VERSIFICATION_KJV       @"KJV"

@interface SwordVerseManager : NSObject {
#ifdef __cplusplus
    sword::VersificationMgr *verseMgr;
#endif
    NSMutableDictionary *booksPerVersification;
}

+ (SwordVerseManager *)defaultManager;

/** convenience method that returns the books for default scheme (KJV) */
- (NSArray *)books;
/** books for a versification scheme */
- (NSArray *)booksForVersification:(NSString *)verseScheme;

#ifdef __cplusplus
- (sword::VersificationMgr *)verseMgr;
#endif

@end
