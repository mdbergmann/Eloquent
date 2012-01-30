//
//  SwordUrlProtocol.m
//  Eloquent
//
//  Created by Manfred Bergmann on 28.11.10.
//  Copyright 2010 CrossWire. All rights reserved.
//

#import "SwordUrlProtocol.h"


@implementation SwordUrlProtocol

+ (void)setup {
    [NSURLProtocol registerClass:[SwordUrlProtocol class]];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    CocoLog(LEVEL_INFO, @"Asked for handling %@ scheme", [[request URL] scheme]);
    return ([[[request URL] scheme] caseInsensitiveCompare:SwordUrlScheme] == NSOrderedSame);
}

- (void)startLoading {
    CocoLog(LEVEL_DEBUG, @"start loading for request: %@", [[[self request] URL] absoluteString]);
}

- (void)stopLoading {
    CocoLog(LEVEL_DEBUG, @"stop loading for request: %@", [[[self request] URL] absoluteString]);    
}


@end
