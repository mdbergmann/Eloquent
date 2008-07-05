//
//  MBGeneralPrefsViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.09.05.
//  Copyright 2005 mabe. All rights reserved.
//

#import "MBGeneralPrefsViewController.h"

@implementation MBGeneralPrefsViewController

- (id)init {
	MBLOG(MBLOG_DEBUG,@"[MBGeneralPrefsViewController -init]");
	
	self = [super init];
	if(self == nil) {
		MBLOG(MBLOG_ERR,@"[MBGeneralPrefsViewController -init] cannot init");		
	} else {
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)finalize {
	MBLOG(MBLOG_DEBUG,@"dealloc of MBGeneralPrefsViewController");
	
	// dealloc object
	[super finalize];
}

//--------------------------------------------------------------------
//----------- bundle delegates ---------------------------------------
//--------------------------------------------------------------------
- (void)awakeFromNib {
	MBLOG(MBLOG_DEBUG,@"awakeFromNib of MBGeneralPrefsViewController");
	
	if(self != nil) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// init the viewRect
		viewFrame = [[self view] frame];
	}
}

- (NSRect)viewFrame {
	return viewFrame;
}

@end
