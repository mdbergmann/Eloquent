/* MBConfirmationSheetController */

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <globals.h>

enum SheetReturnCode {
	SheetDefaultButtonCode = 0,
	SheetAlternateButtonCode,
	SheetOtherButtonCode
};

// name of the nib
#define CONFIRMATION_SHEET_NIB_NAME @"ConfirmationDialog"

@interface MBConfirmationSheetController : NSWindowController {
    IBOutlet NSTextField *confirmationTitle;
    IBOutlet NSTextField *confirmationText;
    IBOutlet NSButton *askAgainButton;
    IBOutlet NSButton *defaultButton;
    IBOutlet NSButton *alternateButton;
    IBOutlet NSButton *otherButton;
	IBOutlet NSImageView *imageView;
	
	// delegate
	id delegate;
    
	// the window the sheet will be brought up
	NSWindow *sheetWindow;
    
	// return code of sheet
	int sheetReturnCode;
    
	// contextInfo
	id contextInfo;
    
    // the UserDefaults key for ask again functionality
    NSString *defaultsAskAgainKey;
}

@property (retain, readwrite) id contextInfo;
@property (readonly) int sheetReturnCode;
@property (readwrite) id delegate;
@property (retain, readwrite) NSString *defaultsAskAgainKey;
@property (retain, readwrite) NSWindow *sheetWindow;

// window title
- (void)setSheetTitle:(NSString *)aTitle;
- (NSString *)sheetTitle;
// sheet return code
- (int)sheetReturnCode;
// confirmation message
- (void)setConfirmationMessage:(NSString *)aMessage;
// confirmation title
- (void)setConfirmationTitle:(NSString *)aMessage;

// begin sheet
- (void)beginSheetWithTitle:(NSString *)aTitle 
					message:(NSString *)msg 
			  defaultButton:(NSString *)defaultTxt
			alternateButton:(NSString *)alternateTxt
				otherButton:(NSString *)otherTxt
			 askAgainButton:(NSString *)askAgainTxt
        defaultsAskAgainKey:(NSString *)defaultsKey
				contextInfo:(id)aContextInfo
				  docWindow:(NSWindow *)aWindow;
- (void)beginSheet;
- (void)endSheet;

// run modal for window usage
- (int)runModal;

// actions
- (IBAction)otherButton:(id)sender;
- (IBAction)alternateButton:(id)sender;
- (IBAction)defaultButton:(id)sender;

@end
