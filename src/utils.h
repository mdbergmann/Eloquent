/*
 *  utils.h
 *  Eloquent
 *
 *  Created by Manfred Bergmann on 20.08.07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>

// some string converting macros
#define fromUTF8(x) [NSString stringWithUTF8String:x]
#define fromC(x) [NSString stringWithCString:x]
#define toUTF8(x) [x UTF8String]
#define toC(x) [x cString]
#define fromLatin1(x) [NSString stringWithCString:x encoding:NSISOLatin1StringEncoding]
#define toLatin1(x) [x cStringUsingEncoding:NSISOLatin1StringEncoding]
