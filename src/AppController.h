/* AppController */

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <ObjCSword/ObjCSword.h>
#import <Sparkle/Sparkle.h>

@class SingleViewHostController;
@class WorkspaceViewHostController;
@class HUDPreviewController;
@class DailyDevotionPanelController;
@class MBAboutWindowController;
@class FileRepresentation;
@class MBPreferenceController;
@class SwordModule;

@interface AppController : NSObject <NSApplicationDelegate> {
	// our preference controller
	MBPreferenceController *preferenceController;
    BOOL isPreferencesShowing;
    
    // HUD preview
    IBOutlet HUDPreviewController *previewController;
    BOOL isPreviewShowing;
    
    // DailyDevotion
    IBOutlet DailyDevotionPanelController *dailyDevotionController;
    BOOL isDailyDevotionShowing;

    // About window
    MBAboutWindowController *aboutWindowController;
        
    // Create module
    IBOutlet NSWindow *createModuleWindow;
    IBOutlet NSTextField *createModuleNameTextField;
    IBOutlet NSButton *createModuleOKButton;
    
    // the help menu. we'll ad this reference here to be able to add the Sparkle updater menu item dynamically
    IBOutlet NSMenu *helpMenu;
    
#ifndef APPSTORE
    // Sparkle updater
    SUUpdater *sparkleUpdater;
#endif
}

+ (AppController *)defaultAppController;

- (SingleViewHostController *)openSingleHostWindowForModuleType:(ModuleType)aModuleType;
- (SingleViewHostController *)openSingleHostWindowForModule:(SwordModule *)mod;
- (SingleViewHostController *)openSingleHostWindowForNote:(FileRepresentation *)fileRep;

/** stores the session to file */
- (IBAction)saveSessionAs:(id)sender;
/** stores as default session */
- (IBAction)saveAsDefaultSession:(id)sender;
/** loads session from file */
- (IBAction)openSession:(id)sender;
/** open the default session */
- (IBAction)openDefaultSession:(id)sender;

// NSApplication delegate methods
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames;

- (IBAction)openNewSingleBibleHostWindow:(id)sender;
- (IBAction)openNewSingleCommentaryHostWindow:(id)sender;
- (IBAction)openNewSingleDictionaryHostWindow:(id)sender;
- (IBAction)openNewSingleGenBookHostWindow:(id)sender;
- (IBAction)openNewWorkspaceHostWindow:(id)sender;
- (IBAction)createAndOpenNewStudyNote:(id)sender;
- (IBAction)showPreferenceSheet:(id)sender;
- (IBAction)showAboutWindow:(id)sender;
- (IBAction)showModuleManager:(id)sender;
- (IBAction)showPreviewPanel:(id)sender;
- (IBAction)showDailyDevotionPanel:(id)sender;
- (IBAction)showCreateModuleWindow:(id)sender;
- (IBAction)openMacSwordWikiPage:(id)sender;
- (IBAction)openMacSwordHomePage:(id)sender;
- (IBAction)openMacSwordForumPage:(id)sender;

// linking SWORD utils
- (IBAction)linkSwordUtils:(id)sender;
- (IBAction)unlinkSwordUtils:(id)sender;

// module creation
- (IBAction)createCommentaryOk:(id)sender;
- (IBAction)createCommentaryCancel:(id)sender;

// host delegate method
- (void)hostClosing:(NSWindowController *)aHost;
- (void)auxWindowClosing:(NSWindowController *)aController;

#ifdef USE_SPARKLE
- (IBAction)checkForUpdates:(id)sender;
#endif

@end
