
#import "MBConfirmationSheetController.h"

@interface MBConfirmationSheetController (privateAPI)

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end

@implementation MBConfirmationSheetController (privateAPI)

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	// hide sheet
	[sSheet orderOut:nil];
	
	sheetReturnCode = returnCode;
	
	// tell delegate that user has made a confirmation
	if(delegate != nil) {
		if([delegate respondsToSelector:@selector(confirmationSheetEnded)] == YES) {
			[delegate performSelector:@selector(confirmationSheetEnded)];
		} else {
			MBLOG(MBLOG_WARN,@"[MBConfirmationSheetController -sheetDidEnd:] delegate does not respond to selector!");
		}
	}
}

@end

@implementation MBConfirmationSheetController

@synthesize delegate;
@synthesize sheetReturnCode;
@synthesize defaultsAskAgainKey;
@synthesize contextInfo;
@synthesize sheetWindow;

- (id)init {
	MBLOG(MBLOG_DEBUG,@"init of MBConfirmationSheetController");
	
	self = [super init];
	if(self == nil) {
		MBLOG(MBLOG_ERR,@"cannot alloc MBConfirmationSheetController!");		
	} else {
		BOOL success = [NSBundle loadNibNamed:CONFIRMATION_SHEET_NIB_NAME owner:self];
		if(success) {
		} else {
			MBLOG(MBLOG_ERR,@"[MBConfirmationSheetController]: cannot load MBConfirmationSheetControllerNib!");
		}
	}
	
	return self;
}

- (void)awakeFromNib {
    // set bold font to confirmation title text field
    NSFont *boldface = [NSFont boldSystemFontOfSize:14.0];
    // set to textfield
    [confirmationTitle setFont:boldface];
    
    // set ImageView to no Frame
    [imageView setImageFrameStyle:NSImageFrameNone];
}

- (void)finalize {
	[super finalize];
}

// window title
- (void)setSheetTitle:(NSString *)aTitle {
	[sheetWindow setTitle:aTitle];
}

- (NSString *)sheetTitle {
	return [sheetWindow title];
}

// sheet return code
- (int)sheetReturnCode {
	return sheetReturnCode;
}

// confirmation message
- (void)setConfirmationMessage:(NSString *)aMessage {
	[confirmationText setStringValue:aMessage];
}

// confirmation title
- (void)setConfirmationTitle:(NSString *)aMessage {
	// set it
	[confirmationTitle setStringValue:aMessage];
}

/**
 \brief begin sheet
*/
- (void)beginSheet {
	// reset switch
	[askAgainButton setState:0];
	
	[NSApp beginSheet:[self window]
	   modalForWindow:sheetWindow
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:nil];
}

/**
 \brief begoin sheet with lots of paranmeters to set
*/
- (void)beginSheetWithTitle:(NSString *)aTitle 
					message:(NSString *)msg 
			  defaultButton:(NSString *)defaultTxt
			alternateButton:(NSString *)alternateTxt
				otherButton:(NSString *)otherTxt
			 askAgainButton:(NSString *)askAgainTxt
        defaultsAskAgainKey:(NSString *)defaultsKey
				contextInfo:(id)aContextInfo
				  docWindow:(NSWindow *)aWindow
{
	[self setConfirmationTitle:aTitle];
	[self setConfirmationMessage:msg];
    
	// checkbuttons
	
	// default button
	if(defaultTxt == nil) {
		[defaultButton setHidden:YES];
	} else {
		[defaultButton setHidden:NO];
		// and set text
		[defaultButton setTitle:defaultTxt];
	}
	// alternate button
	if(alternateTxt == nil) {
		[alternateButton setHidden:YES];
	} else {
		[alternateButton setHidden:NO];
		// and set text
		[alternateButton setTitle:alternateTxt];
	}
	// other button
	if(otherTxt == nil) {
		[otherButton setHidden:YES];
	} else {
		[otherButton setHidden:NO];
		// and set text
		[otherButton setTitle:otherTxt];
	}
	// ask again button
	if(askAgainTxt != nil && defaultsKey != nil) {
		[askAgainButton setHidden:NO];
		// and set text
		[askAgainButton setTitle:askAgainTxt];
        
        // check if we have to store the askagain result
        // if yes, bind the button to the defaults value
        [askAgainButton bind:@"value" toObject:[NSUserDefaults standardUserDefaults] withKeyPath:[NSString stringWithFormat:@"values.%@", defaultsKey] options:nil];
 	} else {
		[askAgainButton setHidden:YES];
	}
    	
	// set contextInfo
	[self setContextInfo:aContextInfo];
	// set window
	[self setSheetWindow:aWindow];
	
	[NSApp beginSheet:[self window] 
	   modalForWindow:sheetWindow 
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:aContextInfo];	
}

// end sheet
- (void)endSheet {
	[NSApp endSheet:[self window] returnCode:0];
}

/**
 \briefd run modal as window
*/
- (int)runModal {
	return [NSApp runModalForWindow:[self window]];
}

- (IBAction)defaultButton:(id)sender {
	[NSApp endSheet:[self window] returnCode:SheetDefaultButtonCode];	
}

- (IBAction)alternateButton:(id)sender {
	[NSApp endSheet:[self window] returnCode:SheetAlternateButtonCode];
}

- (IBAction)otherButton:(id)sender {
	[NSApp endSheet:[self window] returnCode:SheetOtherButtonCode];
}

@end
