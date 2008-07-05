/*
 *  CocoLogger.h
 *  CocoLogger
 *
 *  Created by Manfred Bergmann on 10.06.05.
 *  Copyright 2005 mabe. All rights reserved.
 *
 */

// $Author: mbergmann $
// $HeadURL: file:///REPOSITORY/private/cocoa/CocoLogger/trunk/src/CocoLogger.h $
// $LastChangedBy: mbergmann $
// $LastChangedDate: 2006-12-01 20:04:20 +0100 (Fri, 01 Dec 2006) $
// $Rev: 582 $

#import <CocoLogger/MBLogger.h>

typedef enum
{
	MBLOG_OFF = 1,
	MBLOG_CRIT,
	MBLOG_ERR,
	MBLOG_WARN,
	MBLOG_INFO,
	MBLOG_DEBUG
}MBLoggingLevel;

