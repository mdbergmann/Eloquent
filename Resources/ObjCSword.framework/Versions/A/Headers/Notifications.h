/*
 *  globals.h
 *  ObjCSword
 *
 *  Created by Manfred Bergmann on 03.06.05.
 *  Copyright 2007 mabe. All rights reserved.
 *
 */

// Notification identifiers

/**
\brief this notification is send, when the modules have changed (updated, added, removed)
 */
#define NotificationModulesChanged @"NotificationModulesChanged"
#define SendNotifyModulesChanged(X) [[NSNotificationCenter defaultCenter] postNotificationName:NotificationModulesChanged object:X];
