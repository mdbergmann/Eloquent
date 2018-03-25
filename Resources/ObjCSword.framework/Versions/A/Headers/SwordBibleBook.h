//
//  SwordBibleBook.h
//  MacSword2
//
//  Created by Manfred Bergmann on 18.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SwordBibleChapter;

#ifdef __cplusplus
#include <versificationmgr.h>
#include <versekey.h>
#include <localemgr.h>
#endif

@interface SwordBibleBook : NSObject {
#ifdef __cplusplus
    sword::VersificationMgr::Book *swBook;
#endif
}

@property (readwrite) int number;
@property (readonly) int numberInTestament;
@property (readonly) int testament;
@property (retain, readonly) NSString *localizedName;
@property (retain, readonly) NSArray *chapters;

#ifdef __cplusplus
- (id)initWithBook:(sword::VersificationMgr::Book *)aBook;
- (sword::VersificationMgr::Book *)book;
#endif

- (NSString *)name;
- (NSString *)osisName;
- (int)numberOfChapters;
- (int)numberOfVersesForChapter:(int)chapter;
/**
 get book index for verseKey
 that is: book number + testament * 100
 */
- (int)generatedIndex;

@end
