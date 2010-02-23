//
//  SwordBibleBook.h
//  MacSword2
//
//  Created by Manfred Bergmann on 18.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
#include <versemgr.h>
#include <versekey.h>
#include <localemgr.h>
class sword::VerseMgr::Book;
#endif

@interface SwordBibleBook : NSObject {
#ifdef __cplusplus
    sword::VerseMgr::Book *swBook;
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
@property (retain, readwrite) NSString *localizedName;
@property (retain, readwrite) NSArray *chapters;

#ifdef __cplusplus
- (id)initWithBook:(sword::VerseMgr::Book *)aBook;
- (sword::VerseMgr::Book *)book;
#endif

- (NSString *)name;
- (NSString *)osisName;
- (int)numberOfChapters;
- (int)numberOfVersesForChapter:(int)chapter;
/**
 get book index for versekey
 that is: book number + testament * 100
 */
- (int)generatedIndex;

@end
