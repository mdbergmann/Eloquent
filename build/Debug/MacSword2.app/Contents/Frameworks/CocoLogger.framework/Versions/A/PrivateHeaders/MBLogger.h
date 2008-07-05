//
//  MBLogger.h
//  CocoLogger
//
//  Created by Manfred Bergmann on 02.06.05.
//  Copyright 2005 mabe. All rights reserved.
//

// $Author: mbergmann $
// $HeadURL: file:///REPOSITORY/private/cocoa/CocoLogger/trunk/src/MBLogger.h $
// $LastChangedBy: mbergmann $
// $LastChangedDate: 2006-12-01 19:13:49 +0100 (Fri, 01 Dec 2006) $
// $Rev: 578 $

#import <Cocoa/Cocoa.h>

// define for logging
#define MBLOG(LEVEL,MSG)			[MBLogger log:MSG level:LEVEL]
#define MBLOGV(LEVEL,MSG,ARGS...)	[MBLogger log:[NSString stringWithFormat:MSG,ARGS] level:LEVEL]

@interface MBLogger : NSObject 
{
	
}

// init or close the logger
+ (int)initLogger:(NSString *)logPath
		logPrefix:(NSString *)aPrefix
   logFilterLevel:(int)aLevel
	 appendToFile:(BOOL)fileAppend
	 logToConsole:(BOOL)consoleLogging;

+ (int)closeLogger;

// set or get the logfilter level
+ (void)setLogFilterLevel:(int)aLevel;
+ (int)logFilterLevel;

// set or get logPrefix
+ (void)setLogPrefix:(NSString *)aPrefix;
+ (NSString *)logPrefix;

// make logoutput
+ (int)log:(NSString *)message level:(int)aLevel;

@end
