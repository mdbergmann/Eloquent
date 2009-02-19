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
#include <localemgr.h>
class sword::VerseMgr::Book;
#endif

@interface SwordBibleBook : NSObject {
#ifdef __cplusplus
    sword::VerseMgr::Book *swBook;
#endif
    
    NSString *localizedName;
    NSNumber *number;
    NSMutableArray *chapters;
}

@property (retain, readwrite) NSNumber *number;
@property (retain, readwrite) NSString *localizedName;
@property (retain, readwrite) NSMutableArray *chapters;

#ifdef __cplusplus
- (id)initWithBook:(sword::VerseMgr::Book *)aBook;
- (sword::VerseMgr::Book *)book;
#endif

- (NSString *)name;
- (NSNumber *)numberOfChapters;
- (NSNumber *)numberOfVersesForChapter:(int) chapter;

@end
