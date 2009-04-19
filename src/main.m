//
//  main.m
//  Eloquent
//
//  Created by Manfred Bergmann on 10.08.07.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Application.h>
#import <globals.h>

int main(int argc, char *argv[]) {
        
	// start application
	return NSApplicationMain(argc,  (const char **) argv);
    
    /*
	// create application
	Application *app = (Application *)[Application sharedApplication];
    
	// init logging
	[app initLogging];	
	
	// load the main nib file
	[NSBundle loadNibNamed:@"MainMenu" owner:app];
	// run app - Main Eventloop
    [NSApp run];
	
	// deinit logging
	[app deinitLogging];
    
    return 0;
     */
}
