//
// Created by mbergmann on 28.07.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class Session;
@class WindowHostController;


@interface SessionManager : NSObject

+ (SessionManager *)defaultManager;

- (bool)hasWindows;
- (bool)hasUnsavedContent;

- (void)saveSession;
- (void)saveSessionAs;
- (void)saveAsDefaultSession;

- (void)loadSession;
- (void)loadSessionFrom;
- (void)loadDefaultSession;

- (void)addDelegateToHosts:(id)aDelegate;
- (void)showAllWindows;

- (void)addWindow:(WindowHostController *)aWindow;
- (void)removeWindow:(WindowHostController *)aWindow;

- (void)saveContent;

@end
