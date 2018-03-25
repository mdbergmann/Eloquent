//
//  SwordBibleChapter.h
//  MacSword2
//
//  Created by Manfred Bergmann on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SwordBibleBook;

@interface SwordBibleChapter : NSObject

@property (readonly) int number;
@property (retain, readonly) SwordBibleBook *book;

- (id)initWithBook:(SwordBibleBook *)aBook andChapter:(int)aNumber;

@end
