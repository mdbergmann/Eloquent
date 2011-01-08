//
//  SwordUrlProtocol.h
//  Eloquent
//
//  Created by Manfred Bergmann on 28.11.10.
//  Copyright 2010 CrossWire. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>


#define SwordUrlScheme @"sword"

@interface SwordUrlProtocol : NSURLProtocol {

}

+ (void)setup;

@end
