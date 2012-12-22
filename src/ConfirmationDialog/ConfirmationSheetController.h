/* MBConfirmationSheetController */

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

enum SheetReturnCode {
	SheetDefaultButtonCode = 0,
	SheetAlternateButtonCode,
	SheetOtherButtonCode
};

// name of the nib
#define CONFIRMATION_SHEET_NIB_NAME     @"ConfirmationDialog"

@interface ConfirmationSheetController : NSWindowController {
    IBOutlet NSTextField *titleTextField;
    IBOutlet NSTextField *textTextField;
    IBOutlet NSButton *askAgainButton;
    IBOutlet NSButton *defaultButton;
    IBOutlet NSButton *alternateButton;
    IBOutlet NSButton *otherButton;
	
    // properties
    NSString *confirmationTitle;
    NSString *confirmationText;
    NSString *defaultButtonText;
    NSString *alternateButtonText;
    NSString *otherButtonText;
    NSString *askAgainButtonText;
    // the UserDefaults key for ask again functionality
    NSString *defaultsAskAgainKey;
    
	// delegate
	id delegate;
    
	// the window the sheet will be brought up
	NSWindow *sheetWindow;
    
	// return code of sheet
	int sheetReturnCode;
    
	// contextInfo
	id contextInfo;    
}

@property (retain, readwrite) id contextInfo;
@property (readonly) int sheetReturnCode;
@property (assign, readwrite) id delegate;
@property (retain, readwrite) NSString *defaultsAskAgainKey;
@property (retain, readwrite) NSString *confirmationTitle;
@property (retain, readwrite) NSString *confirmationText;
@property (retain, readwrite) NSString *defaultButtonText;
@property (retain, readwrite) NSString *alternateButtonText;
@property (retain, readwrite) NSString *otherButtonText;
@property (retain, readwrite) NSString *askAgainButtonText;
@property (retain, readwrite) NSWindow *sheetWindow;

- (id)initWithSheetTitle:(NSString *)aTitle 
                 message:(NSString *)msg 
           defaultButton:(NSString *)defaultTxt
         alternateButton:(NSString *)alternateTxt
             otherButton:(NSString *)otherTxt
          askAgainButton:(NSString *)askAgainTxt
     defaultsAskAgainKey:(NSString *)defaultsKey
             contextInfo:(id)aContextInfo
               docWindow:(NSWindow *)aWindow;

// window title
- (void)setSheetTitle:(NSString *)aTitle;
- (NSString *)sheetTitle;
// sheet return code
- (int)sheetReturnCode;

- (void)beginSheet;
- (void)endSheet;

// run modal for window usage
- (int)runModal;

// actions
- (IBAction)defaultButton:(id)sender;
- (IBAction)alternateButton:(id)sender;
- (IBAction)otherButton:(id)sender;

@end
