//
// Created by mbergmann on 28.07.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface SessionManager : NSObject

- (void)saveSessionToFile:(NSURL *)sessionFile;

/** loads a session from the given file */
- (void)loadSessionFromFile:(NSURL *)sessionURL;

@end
