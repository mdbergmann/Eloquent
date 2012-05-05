//
//  MBThreadedProgressSheetController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 26.12.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "MBThreadedProgressSheetController.h"

@implementation MBThreadedProgressSheetController

+ (MBThreadedProgressSheetController *)standardProgressSheetController {
	static MBThreadedProgressSheetController *singleton = nil;
	
	if(singleton == nil) {
		singleton = [[MBThreadedProgressSheetController alloc] init];
	}
	
	return singleton;
}

- (id)init {
	CocoLog(LEVEL_DEBUG,@"init of MBThreadedProgressSheetController");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR,@"cannot alloc MBThreadedProgressSheetController!");
	} else {
        // load nib
        BOOL success = [NSBundle loadNibNamed:THREADED_PROGRESS_SHEET_NIB_NAME owner:self];
        if(success == NO) {
            CocoLog(LEVEL_WARN, @"[MBThreadedProgressSheetController init] could not load nib");
        }
	}
	
	return self;
}

- (void)awakeFromNib {
	CocoLog(LEVEL_DEBUG,@"[MBThreadedProgressSheetController awakeFromNib]");    
}

/**
 \brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	CocoLog(LEVEL_DEBUG,@"dealloc of MBThreadedProgressSheetController");
	
	// dealloc object
	[super dealloc];
}

/**
 \brief set value to min
 */
- (void)reset {
	[progressIndicator setDoubleValue:[progressIndicator minValue]];
    [cancelButton setEnabled:YES];
	// display at once
	[progressIndicator display];
}

/**
 \brief set if this ThreadedProgressSheet should keep track of progress
 */
- (void)setShouldKeepTrackOfProgress:(NSNumber *)aSetting {
	shouldKeepTrackOfProgress = [aSetting boolValue];
}

/**
 \brief should this ThreadedProgressSheet keep track of progress?
 */
- (BOOL)shouldKeepTrackOfProgress {
	return shouldKeepTrackOfProgress;
}

/**
 \brief set the progress action before starting progress tracking
 */
- (void)setProgressAction:(NSNumber *)aAction {
	progressAction = [aAction intValue];
}

/**
 \brief the progress action that is taking place
 */
- (int)progressAction {
	return progressAction;
}

// reset returnCode
- (void)resetReturnCode {
    sheetReturnCode = NORMAL_END;
}

// delegate
- (void)setDelegate:(id)anObject {
	delegate = anObject;
}

- (id)delegate {
	return delegate;
}

// threaded
- (void)setIsThreaded:(NSNumber *)aSetting {
	[progressIndicator setUsesThreadedAnimation:[aSetting boolValue]];
}

- (BOOL)isThreaded {
	return [progressIndicator usesThreadedAnimation];
}

// window title
- (void)setSheetTitle:(NSString *)aTitle
{
	[sheetWindow setTitle:aTitle];
}

- (NSString *)sheetTitle
{
	return [sheetWindow title];
}

// sheet Window
- (void)setSheetWindow:(NSWindow *)aWindow
{
	sheetWindow = aWindow;
}

- (NSWindow *)sheetWindow
{
	return sheetWindow;
}

// action message
- (void)setActionMessage:(NSString *)aMessage
{
	[actionLabel setStringValue:aMessage];
    [progressIndicator display];
}

/**
 \brief set the current step message
 */
- (void)setCurrentStepMessage:(NSString *)aMessage
{
	[currentStepLabel setStringValue:aMessage];
    [progressIndicator display];
}

// sheet return code
- (int)sheetReturnCode
{
	return sheetReturnCode;
}

// dealing with progress
- (void)setIsIndeterminateProgress:(NSNumber *)aSetting
{
	[progressIndicator setIndeterminate:[aSetting boolValue]];
}

- (BOOL)isIndeterminateProgress
{
	return [progressIndicator isIndeterminate];
}

- (void)setIsDisplayedWhenStopped:(NSNumber *)aSetting
{
	[progressIndicator setDisplayedWhenStopped:[aSetting boolValue]];
}

- (BOOL)isDisplayedWhenStopped {
	return [progressIndicator isDisplayedWhenStopped];
}

- (void)setMaxProgressValue:(NSNumber *)aValue {
	[progressIndicator setMaxValue:[aValue doubleValue]];
}

- (double)maxProgressValue {
	return [progressIndicator maxValue];
}

- (void)setMinProgressValue:(NSNumber *)aValue {
	[progressIndicator setMinValue:[aValue doubleValue]];
}

- (double)minProgressValue {
	return [progressIndicator minValue];
}

- (void)setProgressValue:(NSNumber *)aValue {
	[progressIndicator setDoubleValue:[aValue doubleValue]];
}

- (double)progressValue {
	return [progressIndicator doubleValue];
}

- (void)incrementProgressBy:(NSNumber *)aValue {
	[progressIndicator incrementBy:[aValue doubleValue]];
	// display at once
	[progressIndicator display];
}

- (void)startProgressAnimation {
	[progressIndicator startAnimation:nil];
}

- (void)stopProgressAnimation {
	[progressIndicator stopAnimation:nil];
}

- (void)beginSheetForWindow:(NSWindow *)docWindow {
	[self setSheetWindow:docWindow];
	
	// call -beginSheet
	[self beginSheet];
}

// begin sheet
- (void)beginSheet {
	[NSApp beginSheet:sheet 
	   modalForWindow:sheetWindow 
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:nil];
	
	// make panel key window and order front
	[sheet makeKeyWindow];
}

// end sheet
- (void)endSheet {
	[NSApp endSheet:sheet returnCode:0];
}

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	// hide sheet
	[sSheet orderOut:nil];
	
	sheetReturnCode = returnCode;
}

- (IBAction)cancelButton:(id)sender {
	// disable button
	[cancelButton setEnabled:NO];
	[NSApp endSheet:sheet returnCode:CANCELED_END];
}

@end
