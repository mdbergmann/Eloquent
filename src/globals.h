/*
 *  globals.h
 *  Eloquent
 *
 *  Created by Manfred Bergmann on 03.06.05.
 *  Copyright 2007 mabe. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>

#define BUNDLEVERSION               CFBundleGetVersionNumber(CFBundleGetMainBundle())
#define BUNDLEVERSIONSTRING         CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey)
#define APPNAME                     @"Eloquent"
#define DEFAULT_APPSUPPORT_PATH     [@"~/Library/Application Support/Eloquent" stringByExpandingTildeInPath]
#define OLD_BOOKMARK_PATH           [@"~/Library/Application Support/Eloquent/Bookmarks.plist" stringByExpandingTildeInPath]
#define DEFAULT_NOTES_PATH          [@"~/Library/Application Support/Eloquent/Notes" stringByExpandingTildeInPath]
#define DEFAULT_BOOKMARK_PATH       [@"~/Library/Application Support/Eloquent/Bookmarklist.plist" stringByExpandingTildeInPath]
#define DEFAULT_MODULE_PATH         [@"~/Library/Application Support/Sword" stringByExpandingTildeInPath]
#define DEFAULT_SESSION_PATH        [@"~/Library/Application Support/Eloquent/DefaultSession.mssess" stringByExpandingTildeInPath]
#define DEFAULT_SEARCHBOOKSET_PATH  [@"~/Library/Application Support/Eloquent/DefaultSearchBookSets.plist" stringByExpandingTildeInPath]
#define SWINSTALLMGR_NAME           @"InstallMgr"
#define LOGFILE                     [@"~/Library/Logs/Eloquent.log" stringByExpandingTildeInPath]
#define TMPFOLDER                   [@"~/Library/Caches/Eloquent" stringByExpandingTildeInPath]

// OS version
#define OSVERSION [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"]

// table and outlineview fonts
#define FontTiny [NSFont fontWithName: @"Lucida Grande" size:9]
#define FontSmall [NSFont fontWithName: @"Lucida Grande" size:10]
#define FontStd [NSFont fontWithName: @"Lucida Grande" size: 11]
#define FontStdBold [NSFont fontWithName: @"Lucida Grande Bold" size: 11]
#define FontLarge [NSFont fontWithName: @"Lucida Grande" size: 12]
#define FontLargeBold [NSFont fontWithName: @"Lucida Grande Bold" size: 12]
#define FontMoreLarge [NSFont fontWithName: @"Lucida Grande" size: 14]
#define FontMoreLargeBold [NSFont fontWithName: @"Lucida Grande Bold" size: 14]

// define for userdefaults
#define userDefaults [NSUserDefaults standardUserDefaults]
// define for default SwordManager
#define defSwordManager [SwordManager defaultManager]

// Notification identifiers

/**
 \brief this notification is send when the user clicks on a link in ExtTextView or the tooltip sows up
 */
#define NotificationShowPreviewData @"NotificationShowPreviewData"
#define SendNotifyShowPreviewData(X) [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowPreviewData object:X];

/**
 \brief this notification is send when among the currently displayed and active modules is a dictionary or genbook
 */
#define NotificationSetHUDContentView @"NotificationSetHUDContentView"
#define SendNotifySetHUDContentView(X) [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSetHUDContentView object:X];
