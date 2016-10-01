
#import "ConfirmationSheetController.h"

@interface ConfirmationSheetController ()

@property (readwrite) int sheetReturnCode;

@end

@implementation ConfirmationSheetController

// end sheet callback
- (void)sheetDidEnd:(NSWindow *)sSheet returnCode:(int)returnCode contextInfo:(void *)aContextInfo {
    [sSheet orderOut:nil];
    
    _sheetReturnCode = returnCode;
    
    // tell delegate that user has made a confirmation
    if(self.delegate != nil) {
        if([self.delegate respondsToSelector:@selector(confirmationSheetEnded)] == YES) {
            [self.delegate performSelector:@selector(confirmationSheetEnded)];
        } else {
            CocoLog(LEVEL_WARN,@"[ConfirmationSheetController -sheetDidEnd:] delegate does not respond to selector!");
        }
    }
}

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
        self.confirmationTitle = aTitle;
        self.confirmationText = msg;
        self.defaultButtonText = defaultTxt;
        self.alternateButtonText = alternateTxt;
        self.otherButtonText = otherTxt;
        self.askAgainButtonText = askAgainTxt;
        self.defaultsAskAgainKey = defaultsKey;
        self.contextInfo = aContextInfo;
        self.sheetWindow = aWindow;
        
		[[NSBundle mainBundle] loadNibNamed:CONFIRMATION_SHEET_NIB_NAME owner:self topLevelObjects:nil];
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
	if(self.defaultButtonText == nil) {
		[defaultButton setHidden:YES];
	} else {
		[defaultButton setHidden:NO];
		// and set text
		[defaultButton setTitle:self.defaultButtonText];
	}
	// alternate button
	if(self.alternateButtonText == nil) {
		[alternateButton setHidden:YES];
	} else {
		[alternateButton setHidden:NO];
		// and set text
		[alternateButton setTitle:self.alternateButtonText];
	}
	// other button
	if(self.otherButtonText == nil) {
		[otherButton setHidden:YES];
	} else {
		[otherButton setHidden:NO];
		// and set text
		[otherButton setTitle:self.otherButtonText];
	}
	// ask again button
	if(self.askAgainButtonText != nil && self.defaultsAskAgainKey != nil) {
		[askAgainButton setHidden:NO];
		// and set text
		[askAgainButton setTitle:self.askAgainButtonText];
        
        // check if we have to store the askagain result
        // if yes, bind the button to the defaults value
        [askAgainButton bind:@"value"
                    toObject:[NSUserDefaultsController sharedUserDefaultsController]
                 withKeyPath:[NSString stringWithFormat:@"values.%@", self.defaultsAskAgainKey] options:nil];
 	} else {
		[askAgainButton setHidden:YES];
	}
}



// window title
- (void)setSheetTitle:(NSString *)aTitle {
	[self.sheetWindow setTitle:aTitle];
}

- (NSString *)sheetTitle {
	return [self.sheetWindow title];
}

/**
 begin sheet
*/
- (void)beginSheet {
	// reset switch
	[askAgainButton setState:0];

	[NSApp beginSheet:[self window]
	   modalForWindow:self.sheetWindow
		modalDelegate:self 
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:(__bridge void *)(self.contextInfo)];
}

// end sheet
- (void)endSheet {
	[NSApp endSheet:[self window] returnCode:0];
}

/**
 run modal as window
*/
- (NSInteger)runModal {
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
