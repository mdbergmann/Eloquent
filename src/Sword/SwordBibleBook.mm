//
//  SwordBibleBook.m
//  MacSword2
//
//  Created by Manfred Bergmann on 18.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SwordBibleBook.h"
#import "SwordBibleChapter.h"


@implementation SwordBibleBook

@synthesize number;
@synthesize localizedName;
@synthesize chapters;

- (id)init {
    self = [super init];
    if(self) {
        self.number = [NSNumber numberWithInt:0];
        self.localizedName = @"";
        self.chapters = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithBook:(sword::VerseMgr::Book *)aBook {
    self = [self init];
    if(self) {
        swBook = aBook;
        
        // get system localemgr to be able to translate the english bookname
        sword::LocaleMgr *lmgr = sword::LocaleMgr::getSystemLocaleMgr();

        // set localized book name
        self.localizedName = [NSString stringWithUTF8String:lmgr->translate(swBook->getLongName())];
        
        // create chapters
        for(int i = 0;i < swBook->getChapterMax();i++) {
            [chapters addObject:[[SwordBibleChapter alloc] initWithBook:self andChapter:[NSNumber numberWithInt:i+1]]];
        }
    }
    
    return self;
}

- (NSString *)name {
    return [NSString stringWithUTF8String:swBook->getLongName()];
}

- (NSNumber *)numberOfChapters {
    return [NSNumber numberWithInt:swBook->getChapterMax()];
}

- (NSNumber *)numberOfVersesForChapter:(int)chapter {
    return [NSNumber numberWithInt:swBook->getVerseMax(chapter)];
}

- (sword::VerseMgr::Book *)book {
    return swBook;
}

/** we implement this for sorting */
- (NSComparisonResult)compare:(SwordBibleBook *)b {
    return [number compare:[b number]];
}

@end
