/*
 *  globals.h
 *  MacSword2
 *
 *  Created by Manfred Bergmann on 03.06.05.
 *  Copyright 2007 mabe. All rights reserved.
 *
 */

// $Author: $
// $HeadURL: $
// $LastChangedBy: $
// $LastChangedDate: $
// $Rev: $

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>

#define BUNDLEVERSION			CFBundleGetVersionNumber(CFBundleGetMainBundle())
#define BUNDLEVERSIONSTRING		CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey)
#define APPNAME					@"MacSword2"
#define DEFAULT_APPSUPPORT_PATH	[@"~/Library/Application Support/MacSword2" stringByExpandingTildeInPath]
#define DEFAULT_MODULE_PATH     [@"~/Library/Application Support/Sword" stringByExpandingTildeInPath]
#define SWINSTALLMGR_NAME       @"InstallMgr"
#define LOGFILE					[@"~/Library/Logs/MacSword2.log" stringByExpandingTildeInPath]
#define TMPFOLDER				[@"~/Library/Caches/MacSword2" stringByExpandingTildeInPath]

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
\brief this notification is send, when in one of the views the DELETE key has been pressed
 */
//#define MBDeleteKeyPressedNotification @"MBDeleteKeyPressedNotification"
//#define MBSendNotifyDeleteKeyPressed(X) [[NSNotificationCenter defaultCenter] postNotificationName:MBDeleteKeyPressedNotification object:X];

