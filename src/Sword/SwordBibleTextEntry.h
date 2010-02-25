//
//  SwordBibleTextEntry.h
//  MacSword2
//
//  Created by Manfred Bergmann on 01.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SwordModuleTextEntry.h>

@interface SwordBibleTextEntry : SwordModuleTextEntry {
    NSString *preverseHeading;
}

@property (readwrite, retain) NSString *preverseHeading;

+ (id)textEntryForKey:(NSString *)aKey andText:(NSString *)aText;
- (id)initWithKey:(NSString *)aKey andText:(NSString *)aText;

@end
