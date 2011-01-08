//
//  CacheObject.h
//  Eloquent
//
//  Created by Manfred Bergmann on 17.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CacheObject : NSObject {
    NSString *reference;
    id content;
    NSInteger count;
}

@property (retain, readwrite) NSString *reference;
@property (retain, readwrite) id content;
@property (readwrite) NSInteger count;

@end
