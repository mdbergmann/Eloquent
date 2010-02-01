//
//  SwordTreeEntry.h
//  MacSword2
//
//  Created by Manfred Bergmann on 29.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SwordModuleTreeEntry : NSObject {
    NSString *key;
    NSArray *content;
}

@property (retain, readwrite) NSString *key;
@property (retain, readwrite) NSArray *content;

- (id)initWithKey:(NSString *)aKey content:(NSArray *)aContent;

@end
