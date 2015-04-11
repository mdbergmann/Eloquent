//
//  SwordBibleTextEntry.h
//  MacSword2
//
//  Created by Manfred Bergmann on 01.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwordModuleTextEntry.h"

@interface SwordBibleTextEntry : SwordModuleTextEntry {
    NSString *preVerseHeading;
}

@property (readwrite, strong) NSString *preVerseHeading;

+ (id)textEntryForKey:(NSString *)aKey andText:(NSString *)aText;
- (id)initWithKey:(NSString *)aKey andText:(NSString *)aText;

@end
