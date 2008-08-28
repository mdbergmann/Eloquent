/* AppController */

// $Author: $
// $HeadURL: $
// $LastChangedBy: $
// $LastChangedDate: $
// $Rev: $

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <ModuleManager.h>

typedef enum AppErrorCodes {
    INIT_SUCCESS = 0,
    UNABLE_TO_FIND_APPSUPPORT,
    UNABLE_TO_CREATE_APPSUPPORT_FOLDER,
}AppErrorCode;

@class MBPreferenceController;
@class SwordModule;

@interface AppController : NSObject {
	// our preference controller
	MBPreferenceController *preferenceController;
    ModuleManager *moduleManager;
    
    NSMutableArray *windowHosts;
}

+ (AppController *)defaultAppController;

/** opens a new single host window for the given module */
- (void)openSingleHostWindowForModule:(SwordModule *)mod;

// NSApplication delegate methods
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames;

- (IBAction)openNewSingleBibleHostWindow:(id)sender;
- (IBAction)openNewSingleCommentaryHostWindow:(id)sender;
- (IBAction)openNewSingleDictionaryHostWindow:(id)sender;
- (IBAction)showPreferenceSheet:(id)sender;
- (IBAction)showAboutWindow:(id)sender;
- (IBAction)showModuleManager:(id)sender;

// host delegate method
- (void)hostClosing:(NSWindowController *)aHost;

@end
