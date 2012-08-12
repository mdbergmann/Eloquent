//
// Created by mbergmann on 28.07.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CocoLogger/CocoLogger.h>
#import "Session.h"
#import "WindowHostController.h"


@implementation Session

+ (Session *)sessionFromURL:(NSURL *)anUrl {
    return nil;
}

- (id)init {
    return [self initWithURL:nil andWindows:nil];
}

- (id)initWithURL:(NSURL *)anUrl {
    return [self initWithURL:anUrl andWindows:nil];
}

- (id)initWithURL:(NSURL *)anUrl andWindows:(NSArray *)aWindows {
    self = [super init];
    if (self) {
        self.url = anUrl;
        self.windows = aWindows;
    }
    return self;
}

- (void)dealloc {
    [_url release];
    [_windows release];

    [super dealloc];
}


- (void)load {
    if (self.url == nil) {
        @throw [NSException exceptionWithName:@"No Url!" reason:@"Unable to load session data, no url set!" userInfo:nil];
    }

    NSData *data = [NSData dataWithContentsOfURL:self.url];
    @try {
        if (data == nil) @throw [NSException exceptionWithName:@"SessionLoadError" reason:@"Unable to load session!" userInfo:nil];

        NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
        self.windows = [unarchiver decodeObjectForKey:@"WindowsEncoded"];
        for(NSWindowController *wc in self.windows) {
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

- (void)store {
    if (self.windows != nil) {
        // encode data
        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
        [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
        [archiver encodeObject:self.windows forKey:@"WindowsEncoded"];
        [archiver finishEncoding];
        // write data object
        [data writeToURL:self.url atomically:NO];
    } else {
        CocoLog(LEVEL_WARN, @"No data to store!");
    }
}


@end