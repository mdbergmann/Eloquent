//
//  SwordTreeEntry.h
//  MacSword2
//
//  Created by Manfred Bergmann on 29.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SwordModuleTreeEntry : NSObject {
    NSString *key;
    NSArray *content;
}

@property (strong, readwrite) NSString *key;
@property (strong, readwrite) NSArray *content;

- (id)initWithKey:(NSString *)aKey content:(NSArray *)aContent;

@end
