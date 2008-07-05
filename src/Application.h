//
//  Application.h
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

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <globals.h>

@interface Application : NSApplication {
	/**
	\brief Seperate ARP for logging
	 */
	NSAutoreleasePool *gpPool;
}

// I need a special subclass of NSApplication to init the logging service on startup
- (void)initLogging;
- (void)deinitLogging;

@end
