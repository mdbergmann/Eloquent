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
#define SWINSTALLMGR_NAME           @"InstallMgr"
#define PREFS_FILE                  [@"~/Library/Preferences/org.crosswire.Eloquent.plist" stringByExpandingTildeInPath]

// OS version
#define OSVERSION [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"]

// table and outlineview fonts
#define FontTiny [NSFont fontWithName: @"Helvetica" size:9]
#define FontSmall [NSFont fontWithName: @"Helvetica" size:10]
#define FontStd [NSFont fontWithName: @"Helvetica" size: 11]
#define FontStdBold [NSFont fontWithName: @"Helvetica Bold" size: 11]
#define FontLarge [NSFont fontWithName: @"Helvetica" size: 12]
#define FontLargeBold [NSFont fontWithName: @"Helvetica Bold" size: 12]
#define FontMoreLarge [NSFont fontWithName: @"Helvetica" size: 14]
#define FontMoreLargeBold [NSFont fontWithName: @"Helvetica Bold" size: 14]

// define for userdefaults
#define UserDefaults [NSUserDefaults standardUserDefaults]
// define for default SwordManager
#define DefaultSwordManager [SwordManager defaultManager]

// Notification identifiers

/**
 \brief this notification is send when the user clicks on a link in ExtTextView or the tooltip sows up
 */
#define NotificationShowPreviewData @"NotificationShowPreviewData"
#define SendNotifyShowPreviewData(X) [[NSNotificationCenter defaultCenter] postNotificationName:NotificationShowPreviewData object:X]

/**
 \brief this notification is send when among the currently displayed and active modules is a dictionary or genbook
 */
#define NotificationSetHUDContentView @"NotificationSetHUDContentView"
#define SendNotifySetHUDContentView(X) [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSetHUDContentView object:X];

/**
 \brief this notification is send, when the modules have changed (updated, added, removed)
 */
#define NotificationModulesChanged @"NotificationModulesChanged"
#define SendNotifyModulesChanged(X) [[NSNotificationCenter defaultCenter] postNotificationName:NotificationModulesChanged object:X]
