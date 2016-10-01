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
}

@property (strong, readwrite) id contextInfo;
@property (readonly) int sheetReturnCode;
@property (strong, readwrite) id delegate;
@property (strong, readwrite) NSString *defaultsAskAgainKey;
@property (strong, readwrite) NSString *confirmationTitle;
@property (strong, readwrite) NSString *confirmationText;
@property (strong, readwrite) NSString *defaultButtonText;
@property (strong, readwrite) NSString *alternateButtonText;
@property (strong, readwrite) NSString *otherButtonText;
@property (strong, readwrite) NSString *askAgainButtonText;
@property (strong, readwrite) NSWindow *sheetWindow;

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
- (NSInteger)runModal;

// actions
- (IBAction)defaultButton:(id)sender;
- (IBAction)alternateButton:(id)sender;
- (IBAction)otherButton:(id)sender;

@end
