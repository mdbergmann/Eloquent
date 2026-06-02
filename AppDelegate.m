//
//  AppDelegate.m
//  Eloquent
//
//  Created by Mark Clayton on 5/21/26.
//  Copyright © 2026 Crosswire. All rights reserved.
//

// AppDelegate.m
#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import "AppController.h"
#import "WorkspaceViewHostController.h"
#import "ContentDisplayingViewController.h"
#import "ContentDisplayingViewControllerFactory.h"
#import "ObjCSword/SwordManager.h"
#import "globals.h"
#import "SessionManager.h"

@interface AppDelegate : NSResponder <NSApplicationDelegate>

@end

@implementation AppDelegate

// Defaults key for the user's preferred Bible module. If this is already
// defined elsewhere, you can remove this local definition.
static inline NSString *EloquentDefaultsBibleModuleKey(void) {
    return @"DefaultsBibleModule";
}

- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls {
    CocoLog(LEVEL_DEBUG, @"GOT HERE: openURLs %@", nil);
    for (NSURL *url in urls) {
        if ([[url.scheme lowercaseString] isEqualToString:@"eloquent"]) {
            [self routeDeepLinkURL:url];
        }
    }
}

- (void)routeDeepLinkURL:(NSURL *)url {
    CocoLog(LEVEL_DEBUG, @"GOT HERE: routeDeepLinkURL %@", url);
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

    NSMutableArray<NSString *> *cleanSegments = [NSMutableArray array];
    for (NSString *s in url.pathComponents) {
        if (![s isEqualToString:@"/"]) { [cleanSegments addObject:s]; }
    }

    NSMutableDictionary<NSString *, NSString *> *query = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *item in components.queryItems ?: @[]) {
        if (item.name && item.value) { query[item.name] = item.value; }
    }

    NSString *first = cleanSegments.firstObject.lowercaseString;
    if ([first isEqualToString:@"passage"]) {
        NSString *reference = cleanSegments.count > 1 ? cleanSegments[1] : @"";
        NSString *version = query[@"version"];
        [self openPassage:reference version:version];
    } else if ([first isEqualToString:@"module"]) {
        NSString *name = cleanSegments.count > 1 ? cleanSegments[1] : @"";
        [self openModule:name];
    } else if ([first isEqualToString:@"search"]) {
        NSString *q = query[@"q"] ?: @"";
        NSString *inVersion = query[@"in"];
        [self openSearch:q inVersion:inVersion];
    } else {
        // Unknown route
    }
}

#pragma mark - Navigation helpers

- (void)openPassage:(NSString *)reference version:(NSString *)version {
    CocoLog(LEVEL_DEBUG, @"GOT HERE: MopenPassage %@", reference);
    // Resolve module to use: version param or default bible
    SwordModule *mod = nil;
    if (version.length > 0) {
        mod = [[SwordManager defaultManager] moduleWithName:version];
    }
    if (!mod) {
        NSString *defBible = [[NSUserDefaults standardUserDefaults] stringForKey:EloquentDefaultsBibleModuleKey()];
        if (defBible.length > 0) {
            mod = [[SwordManager defaultManager] moduleWithName:defBible];
        }
    }
    CocoLog(LEVEL_DEBUG, @"Module %@", mod);

    // Ensure a workspace window exists
    WorkspaceViewHostController *workspace = [[WorkspaceViewHostController alloc] init];
    [[SessionManager defaultManager] addWindow:workspace];
    [workspace setDelegate:[AppController defaultAppController]];
    [workspace showWindow:self];

    // Create a suitable content controller for the module (Bible by default)
    ContentDisplayingViewController *vc = nil;
    if (mod) {
        vc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:mod];
    } else {
        // Fall back to a Bible-type controller if no module resolved
        vc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModuleType:Bible];
    }

    // Add to workspace and set the verse reference
    [vc setDelegate:workspace];
    [workspace addContentViewController:vc];
    [workspace setSearchTypeUI:ReferenceSearchType];
    [workspace setSearchText:(reference ?: @"")];
}

- (void)openModule:(NSString *)name {
    CocoLog(LEVEL_DEBUG, @"GOT HERE: openModule %@", name);
    // Resolve the module by name
    SwordModule *mod = nil;
    if (name.length > 0) {
        mod = [[SwordManager defaultManager] moduleWithName:name];
    }

    // Create or open a workspace
    WorkspaceViewHostController *workspace = [[WorkspaceViewHostController alloc] init];
    [[SessionManager defaultManager] addWindow:workspace];
    [workspace setDelegate:[AppController defaultAppController]];
    [workspace showWindow:self];

    // Build content controller for the module (or default bible if nil)
    ContentDisplayingViewController *vc = nil;
    if (mod) {
        vc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:mod];
    } else {
        vc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModuleType:Bible];
    }

    [vc setDelegate:workspace];
    [workspace addContentViewController:vc];
    // Keep current search text unchanged; user can type or deep link may follow with a passage
}

- (void)openSearch:(NSString *)query inVersion:(NSString *)version {
    CocoLog(LEVEL_DEBUG, @"GOT HERE: MopenSearch %@", version);
    // Resolve module for search context (prefer version, fallback to default bible)
    SwordModule *mod = nil;
    if (version.length > 0) {
        mod = [[SwordManager defaultManager] moduleWithName:version];
    }
    if (!mod) {
        NSString *defBible = [[NSUserDefaults standardUserDefaults] stringForKey:EloquentDefaultsBibleModuleKey()];
        if (defBible.length > 0) {
            mod = [[SwordManager defaultManager] moduleWithName:defBible];
        }
    }

    // Ensure a workspace exists
    WorkspaceViewHostController *workspace = [[WorkspaceViewHostController alloc] init];
    [[SessionManager defaultManager] addWindow:workspace];
    [workspace setDelegate:[AppController defaultAppController]];
    [workspace showWindow:self];

    // Create a content controller and switch to index search
    ContentDisplayingViewController *vc = nil;
    if (mod) {
        vc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:mod];
    } else {
        vc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModuleType:Bible];
    }

    [vc setDelegate:workspace];
    [workspace addContentViewController:vc];
    [workspace setSearchTypeUI:IndexSearchType];
    [workspace setSearchText:(query ?: @"")];
}

@end

