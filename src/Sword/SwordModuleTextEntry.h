//
//  SwordModuleTextEntry.h
//  MacSword2
//
//  Created by Manfred Bergmann on 03.10.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SwordModuleTextEntry : NSObject {
    NSString *key;
    NSString *text;
    NSString *preverseHeading;
}

@property (readwrite, retain) NSString *key;
@property (readwrite, retain) NSString *text;
@property (readwrite, retain) NSString *preverseHeading;

+ (SwordModuleTextEntry *)textEntryForKey:(NSString *)aKey andText:(NSString *)aText;
- (id)initWithKey:(NSString *)aKey andText:(NSString *)aText;

@end
