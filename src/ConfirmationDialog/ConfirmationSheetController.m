
#import "ConfirmationSheetController.h"

@interface ConfirmationSheetController (privateAPI)

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)aContextInfo;

@end

@implementation ConfirmationSheetController (privateAPI)

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)aContextInfo {
	// hide sheet
	[sSheet orderOut:nil];
	
	sheetReturnCode = returnCode;
	
	// tell delegate that user has made a confirmation
	if(delegate != nil) {
		if([delegate respondsToSelector:@selector(confirmationSheetEnded)] == YES) {
			[delegate performSelector:@selector(confirmationSheetEnded)];
		} else {
			CocoLog(LEVEL_WARN,@"[ConfirmationSheetController -sheetDidEnd:] delegate does not respond to selector!");
		}
	}
}

@end

@implementation ConfirmationSheetController

@synthesize delegate;
@synthesize sheetReturnCode;
@synthesize confirmationTitle;
@synthesize confirmationText;
@synthesize defaultButtonText;
@synthesize alternateButtonText;
@synthesize otherButtonText;
@synthesize askAgainButtonText;
@synthesize defaultsAskAgainKey;
@synthesize contextInfo;
@synthesize sheetWindow;

- (id)initWithSheetTitle:(NSString *)aTitle 
                 message:(NSString *)msg 
           defaultButton:(NSString *)defaultTxt
         alternateButton:(NSString *)alternateTxt
             otherButton:(NSString *)otherTxt
          askAgainButton:(NSString *)askAgainTxt
     defaultsAskAgainKey:(NSString *)defaultsKey
             contextInfo:(id)aContextInfo
               docWindow:(NSWindow *)aWindow {
	self = [super init];
	if(self) {
        
        // set properties
        self.confirmationTitle = aTitle;
        self.confirmationText = msg;
        self.defaultButtonText = defaultTxt;
        self.alternateButtonText = alternateTxt;
        self.otherButtonText = otherTxt;
        self.askAgainButtonText = askAgainTxt;
        self.defaultsAskAgainKey = defaultsKey;
        self.contextInfo = contextInfo;
        self.sheetWindow = aWindow;
        
		BOOL success = [NSBundle loadNibNamed:CONFIRMATION_SHEET_NIB_NAME owner:self];
		if(success) {
		} else {
			CocoLog(LEVEL_ERR,@"[ConfirmationSheetController]: cannot load ConfirmationSheetControllerNib!");
		}
	}
	
	return self;
}

- (void)awakeFromNib {
    // set bold font to confirmation title text field
    NSFont *boldface = [NSFont boldSystemFontOfSize:14.0];
    [titleTextField setFont:boldface];
    [titleTextField setStringValue:self.confirmationTitle];
    [textTextField setStringValue:self.confirmationText];
    
	// checkbuttons
	
	// default button
	if(defaultButtonText == nil) {
		[defaultButton setHidden:YES];
	} else {
		[defaultButton setHidden:NO];
		// and set text
		[defaultButton setTitle:defaultButtonText];
	}
	// alternate button
	if(alternateButtonText == nil) {
		[alternateButton setHidden:YES];
	} else {
		[alternateButton setHidden:NO];
		// and set text
		[alternateButton setTitle:alternateButtonText];
	}
	// other button
	if(otherButtonText == nil) {
		[otherButton setHidden:YES];
	} else {
		[otherButton setHidden:NO];
		// and set text
		[otherButton setTitle:otherButtonText];
	}
	// ask again button
	if(askAgainButtonText != nil && defaultsAskAgainKey != nil) {
		[askAgainButton setHidden:NO];
		// and set text
		[askAgainButton setTitle:askAgainButtonText];
        
        // check if we have to store the askagain result
        // if yes, bind the button to the defaults value
        [askAgainButton bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[NSString stringWithFormat:@"values.%@", defaultsAskAgainKey] options:nil];
 	} else {
		[askAgainButton setHidden:YES];
	}
    
	// set contextInfo
	[self setContextInfo:contextInfo];
	// set window
	[self setSheetWindow:sheetWindow];    
}

- (void)finalize {
	[super finalize];
}

- (void)dealloc {
    [confirmationTitle release];
    [confirmationText release];
    [defaultButtonText release];
    [alternateButtonText release];
    [otherButtonText release];
    [askAgainButtonText release];
    [defaultsAskAgainKey release];
    [contextInfo release];
    [sheetWindow release];
    [super dealloc];
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

/**
 begin sheet
*/
- (void)beginSheet {
	// reset switch
	[askAgainButton setState:0];
	
	[NSApp beginSheet:[self window]
	   modalForWindow:sheetWindow
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:contextInfo];
}

// end sheet
- (void)endSheet {
	[NSApp endSheet:[self window] returnCode:0];
}

/**
 run modal as window
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
