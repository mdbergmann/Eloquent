//
//  SwordTreeEntry.h
//  MacSword2
//
//  Created by Manfred Bergmann on 29.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SwordTreeEntry : NSObject {
    NSString *key;
    id content;
}

@property (retain, readwrite) NSString *key;
@property (retain, readwrite) id content;

- (id)initWithKey:(NSString *)aKey content:(id)aContent;

@end
