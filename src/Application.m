//
//  Application.m
//  Eloquent
//
//  Created by Manfred Bergmann on 20.06.05.
//  Copyright 2007 mabe. All rights reserved.
//

// $Author: $
// $HeadURL: $
// $LastChangedBy: $
// $LastChangedDate: $
// $Rev: $

#import "Application.h"

@implementation Application

/**
\brief initialized logging, creates a ARP for logging
*/
- (void)initLogging {
	// init our ARP
	gpPool = [[NSAutoreleasePool alloc] init];
	
	// get path to "Logs" folder of current user
	NSString *logPath = LOGFILE;
	
#ifdef DEBUG
	// init the logging facility in first place
	[MBLogger initLogger:logPath 
			   logPrefix:@"[Eloquent]" 
		  logFilterLevel:MBLOG_DEBUG 
			appendToFile:YES 
			logToConsole:YES];
#endif
#ifdef RELEASE
	// init the logging facility in first place
	[MBLogger initLogger:logPath 
			   logPrefix:@"[Eloquent]" 
		  logFilterLevel:MBLOG_WARN 
			appendToFile:NO 
			logToConsole:NO];	
#endif
	MBLOG(MBLOG_DEBUG,@"initLogging: logging initialized");
}

/**
\brief releases the created ARP
*/
- (void)deinitLogging {
	// release logger pool in the end
	[gpPool release];
}

@end
