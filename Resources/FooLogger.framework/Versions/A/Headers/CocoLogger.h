/*
 *  CocoLogger.h
 *  CocoLogger
 *
 *  Created by Manfred Bergmann on 10.06.05.
 *  Copyright 2005 mabe. All rights reserved.
 *
 */

#import <FooLogger/Logger.h>

typedef enum {
	LEVEL_OFF = 1,
	LEVEL_CRIT,
	LEVEL_ERR,
	LEVEL_WARN,
	LEVEL_INFO,
	LEVEL_DEBUG
}LoggingLevel;
