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
    
    NSString *localizedName;
    int number;
    int numberInTestament;
    int testament;
    NSArray *chapters;
}

@property (readwrite) int number;
@property (readwrite) int numberInTestament;
@property (readwrite) int testament;
@property (strong, readwrite) NSString *localizedName;
@property (strong, readwrite) NSArray *chapters;

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
