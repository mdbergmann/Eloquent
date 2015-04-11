//
//  SwordLocaleManager.h
//  ObjCSword
//
//  Created by Manfred Bergmann on 01.08.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwordLocaleManager : NSObject {
}

+ (SwordLocaleManager *)defaultManager;

/**
 Initializes the global locale system.
 Any created instance that needs localized information will use it.
 */
- (void)initLocale;

/**
 Initializes global locale system.
 Loads the locale (locale.d) folder from the specified path.
 */
- (void)initLocaleWithLocaledPath:(NSString *)aPath;

@end
