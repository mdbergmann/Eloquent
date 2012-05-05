//
//  MBThreadedProgressSheetController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 26.12.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

/* MBThreadedProgressSheetController */

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

// the progress actions
enum ThreadedProgressAction {
	NONE_PROGRESS_ACTION = 0,
	INDEXING_PROGRESS_ACTION,
	SEARCHING_PROGRESS_ACTION,
};

enum ThreadedeProgressReturnCode {
    NORMAL_END,
    CANCELED_END
};

// name of the nib
#define THREADED_PROGRESS_SHEET_NIB_NAME @"ThreadedProgressSheet"

@interface MBThreadedProgressSheetController : NSWindowController {

    IBOutlet NSTextField *actionLabel;
	IBOutlet NSTextField *currentStepLabel;
    IBOutlet NSButton *cancelButton;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSWindow *sheet;
	
	// delegate
	id delegate;
	// the window the sheet will be brought up
	NSWindow *sheetWindow;
	// return code of sheet
	int sheetReturnCode;
	// should keep track of progress
	BOOL shouldKeepTrackOfProgress;
	// the action
	int progressAction;
}

+ (MBThreadedProgressSheetController *) standardProgressSheetController;

// delegate
- (void)setDelegate:(id)anObject;
- (id)delegate;
// threaded
- (void)setIsThreaded:(NSNumber *)aSetting;
- (BOOL)isThreaded;
// window title
- (void)setSheetTitle:(NSString *)aTitle;
- (NSString *)sheetTitle;
// sheet Window
- (void)setSheetWindow:(NSWindow *)aWindow;
- (NSWindow *)sheetWindow;
// action message
- (void)setActionMessage:(NSString *)aMessage;
// action message
- (void)setCurrentStepMessage:(NSString *)aMessage;
// sheet return code
- (int)sheetReturnCode;
// keep track of progress
- (void)setShouldKeepTrackOfProgress:(NSNumber *)aSetting;
- (BOOL)shouldKeepTrackOfProgress;
// set and get action
- (void)setProgressAction:(NSNumber *)aAction;
- (int)progressAction;
// reset progressValue
- (void)reset;
// reset returnCode
- (void)resetReturnCode;

// dealing with progress
- (void)setIsIndeterminateProgress:(NSNumber *)aSetting;
- (BOOL)isIndeterminateProgress;
- (void)setIsDisplayedWhenStopped:(NSNumber *)aSetting;
- (BOOL)isDisplayedWhenStopped;
- (void)setMaxProgressValue:(NSNumber *)aValue;
- (double)maxProgressValue;
- (void)setMinProgressValue:(NSNumber *)aValue;
- (double)minProgressValue;
- (void)setProgressValue:(NSNumber *)aValue;
- (double)progressValue;
- (void)incrementProgressBy:(NSNumber *)aValue;
- (void)startProgressAnimation;
- (void)stopProgressAnimation;

// begin sheet
- (void)beginSheetForWindow:(NSWindow *)docWindow;
- (void)beginSheet;
- (void)endSheet;

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

// actions
- (IBAction)cancelButton:(id)sender;

@end
