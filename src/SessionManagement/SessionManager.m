//
// Created by mbergmann on 28.07.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CocoLogger/CocoLogger.h>
#import "SessionManager.h"
#import "ProtocolHelper.h"
#import "HostableViewController.h"
#import "WindowHostController.h"
#import "Session.h"
#import "globals.h"
#import "MBPreferenceController.h"

@interface SessionManager ()

@property (strong, nonatomic) Session *session;

@end

@implementation SessionManager

+ (SessionManager *)defaultManager {
    static SessionManager *instance = nil;
    if (instance == nil) {
        instance = [[SessionManager alloc] init];
    }
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.session = [[[Session alloc] init] autorelease];

        // load session path from defaults
        if([userDefaults objectForKey:DefaultsSessionPath] == nil) {
            self.session.url = [NSURL fileURLWithPath:DEFAULT_SESSION_PATH];
        } else {
            self.session.url = [NSURL URLWithString:[userDefaults objectForKey:DefaultsSessionPath]];
        }
    }

    return self;
}

- (void)dealloc {
    [_session release];

    [super dealloc];
}


- (bool)hasWindows {
    return self.session.windows != nil && self.session.windows.count > 0;
}

- (bool)hasUnsavedContent {
    BOOL unsavedContent = NO;
    for(WindowHostController *hc in self.session.windows) {
        if([hc hasUnsavedContent]) {
            unsavedContent = YES;
            break;
        }
    }
    return unsavedContent;
}

/**
* Saves session to url as in session.url
*/
- (void)saveSession {
    // encode all windows
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
    [archiver encodeObject:self.session.windows forKey:@"WindowsEncoded"];
    [archiver finishEncoding];
    // write data object
    [data writeToURL:self.session.url atomically:NO];
}

/**
* Saves session to user defined file. As via file requester.
* The defined url is then taken as default session url.
*/
- (void)saveSessionAs {
    NSSavePanel *sp = [NSSavePanel savePanel];
    [sp setTitle:NSLocalizedString(@"SaveMSSession", @"")];
    [sp setCanCreateDirectories:YES];
    [sp setAllowedFileTypes:[NSArray arrayWithObject:@"mssess"]];
    if([sp runModal] == NSFileHandlingPanelOKButton) {
        self.session.url = [sp URL];
        [self saveSession];
        // this session we have loaded
        [userDefaults setObject:[self.session.url absoluteString] forKey:DefaultsSessionPath];
    }
}

/**
* Saves session as default session to default session url.
*/
- (void)saveAsDefaultSession {
    self.session.url = [NSURL fileURLWithPath:DEFAULT_SESSION_PATH];
    [self saveSession];

    // mark this as default session
    [userDefaults setObject:[self.session.url absoluteString] forKey:DefaultsSessionPath];
}

/**
* Loads session from default session url.
*/
- (void)loadDefaultSession {
    [self checkSessionSaveOnLoad];
    [self closeAllWindows];

    self.session.url = [NSURL fileURLWithPath:DEFAULT_SESSION_PATH];
    // mark as default session
    [userDefaults setObject:[self.session.url absoluteString] forKey:DefaultsSessionPath];

    [self loadSession];
    [self showAllWindows];
}

/**
* Loads session from user defined file. Ask user via file requester.
* Sets the defined url as default session.
*/
- (void)loadSessionFrom {
    [self checkSessionSaveOnLoad];
    [self closeAllWindows];

    // open load panel
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setCanCreateDirectories:NO];
    [op setAllowedFileTypes:[NSArray arrayWithObject:@"mssess"]];
    [op setTitle:NSLocalizedString(@"LoadMSSession", @"")];
    [op setAllowsMultipleSelection:NO];
    [op setCanChooseDirectories:NO];
    [op setAllowsOtherFileTypes:NO];
    if([op runModal] == NSFileHandlingPanelOKButton) {
        // close all existing windows
        for(NSWindowController *wc in self.session.windows) {
            [wc close];
        }

        // get file
        self.session.url = [op URL];
        // this session we will loaded
        [userDefaults setObject:[self.session.url absoluteString] forKey:DefaultsSessionPath];
        // load session
        [self loadSession];
        [self showAllWindows];
    }
}

/**
* Loads the session as is defined in session.url.
*/
- (void)loadSession {
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:[self.session.url path]]) {
        CocoLog(LEVEL_INFO, @"No such session file at: %@", [self.session.url absoluteString]);
        return;
    }

    @try {
        NSData *data = [NSData dataWithContentsOfURL:self.session.url];
        if (data == nil) @throw [NSException exceptionWithName:@"SessionLoadError" reason:@"Unable to load session!" userInfo:nil];

        NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
        NSArray *windows = [unarchiver decodeObjectForKey:@"WindowsEncoded"];

        self.session.windows = windows;

    } @catch (NSException *e) {
        CocoLog(LEVEL_ERR, @"Unable to load session: %@", [self.session.url absoluteString]);
        CocoLog(LEVEL_ERR, @"Error reason: %@", [e reason]);
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"SessionLoadError", @"")
                                         defaultButton:NSLocalizedString(@"OK", @"")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"SessionLoadErrorText", @"")];
        [alert runModal];
    }
}

- (void)checkSessionSaveOnLoad {
    // if there are any open windows, a session is currently open
    // ask the user if we wants to save the open session first
    if([self.session.windows count] > 0) {
        // show Alert
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"SessionStillOpen", @"")
                                         defaultButton:NSLocalizedString(@"Yes", @"")
                                       alternateButton:NSLocalizedString(@"No", @"")
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"WantToSaveTheSessionBeforeClosing", @"")];
        if([alert runModal] == NSAlertDefaultReturn) {
            // save session
            [self saveSession];
        }
    }
}

- (void)addDelegateToHosts:(id)aDelegate {
    for(NSWindowController *wc in self.session.windows) {
        if([wc isKindOfClass:[WindowHostController class]]) {
            [(WindowHostController *)wc setDelegate:aDelegate];
        }
    }
}

- (void)showAllWindows {
    for(id entry in self.session.windows) {
        if([entry isKindOfClass:[WindowHostController class]]) {
            [(WindowHostController *)entry showWindow:self];
        }
    }
}

- (void)closeAllWindows {
    for(id entry in self.session.windows) {
        if([entry isKindOfClass:[WindowHostController class]]) {
            [(WindowHostController *)entry close];
        }
    }
}

- (void)addWindow:(WindowHostController *)aWindow {
    self.session.windows = [self.session.windows arrayByAddingObject:aWindow];
}

- (void)removeWindow:(WindowHostController *)aWindow {
    NSMutableArray *windows = [[self.session.windows mutableCopy] autorelease];
    [windows removeObject:aWindow];

    self.session.windows = [NSArray arrayWithArray:windows];
}

- (void)saveContent {
    for(WindowHostController *hc in self.session.windows) {
        if([hc hasUnsavedContent]) {
            [hc saveContent];
        }
    }
}

@end