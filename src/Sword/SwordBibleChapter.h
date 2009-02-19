//
//  SwordBibleChapter.h
//  MacSword2
//
//  Created by Manfred Bergmann on 19.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SwordBibleBook;

@interface SwordBibleChapter : NSObject {
    /** the back reference */
    SwordBibleBook *book;
    NSNumber *number;
}

@property (retain, readwrite) NSNumber *number;
@property (readwrite) SwordBibleBook *book;

- (id)initWithBook:(SwordBibleBook *)aBook andChapter:(NSNumber *)aNumber;

@end
