//
// Created by mbergmann on 28.07.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CocoLogger/CocoLogger.h>
#import "SessionManager.h"
#import "WindowHostController.h"


@implementation SessionManager {

}

- (void)saveSessionToFile:(NSURL *)sessionFile {
    // encode all windows
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeObject:windowHosts forKey:@"WindowsEncoded"];
    [archiver finishEncoding];
    // write data object
    [data writeToURL:sessionFile atomically:NO];
}

- (void)loadSessionFromFile:(NSURL *)sessionFile {
    NSData *data = [NSData dataWithContentsOfURL:sessionFile];
    @try {
        if (data == nil) @throw [NSException exceptionWithName:@"SessionLoadError" reason:@"Unable to load session!" userInfo:nil];

        NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
        windowHosts = [unarchiver decodeObjectForKey:@"WindowsEncoded"];
        for(NSWindowController *wc in windowHosts) {
            if([wc isKindOfClass:[WindowHostController class]]) {
                [(WindowHostController *)wc setDelegate:self];
            }
        }

        // show svh
        for(id entry in windowHosts) {
            if([entry isKindOfClass:[WindowHostController class]]) {
                [(WindowHostController *)entry showWindow:self];
            }
        }
    } @catch (NSException *e) {
        CocoLog(LEVEL_ERR, @"Unable to load session: %@", [sessionFile absoluteString]);
        CocoLog(LEVEL_ERR, @"Error reason: %@", [e reason]);
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"SessionLoadError", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"SessionLoadErrorText", @"")];
        [alert runModal];
    }
}

@end