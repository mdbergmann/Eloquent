/* AppController */

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <ObjCSword/ObjCSword.h>

#ifndef APPSTORE
#import <Sparkle/Sparkle.h>
#endif

@class SingleViewHostController;
@class WorkspaceViewHostController;
@class HUDPreviewController;
@class DailyDevotionPanelController;
@class MBAboutWindowController;
@class FileRepresentation;
@class MBPreferenceController;
@class SwordModule;

@interface AppController : NSObject <NSApplicationDelegate> {

    IBOutlet HUDPreviewController *previewController;
    IBOutlet DailyDevotionPanelController *dailyDevotionController;
    IBOutlet NSWindow *createModuleWindow;
    IBOutlet NSTextField *createModuleNameTextField;
    IBOutlet NSButton *createModuleOKButton;
    
    // the help menu. we'll ad this reference here to be able to add the Sparkle updater menu item dynamically
    IBOutlet NSMenu *helpMenu;

    MBAboutWindowController *aboutWindowController;
    MBPreferenceController *preferenceController;
    
    BOOL isPreferencesShowing;
    BOOL isPreviewShowing;
    BOOL isDailyDevotionShowing;
    
#ifndef APPSTORE
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
- (IBAction)openEloquentWikiPage:(id)sender;
- (IBAction)openEloquentHomePage:(id)sender;
- (IBAction)openMacSwordForumPage:(id)sender;

#ifndef APPSTORE
// linking SWORD utils
- (IBAction)linkSwordUtils:(id)sender;
- (IBAction)unlinkSwordUtils:(id)sender;
#endif

// module creation
- (IBAction)createCommentaryOk:(id)sender;
- (IBAction)createCommentaryCancel:(id)sender;

// host delegate method
- (void)hostClosing:(NSWindowController *)aHost;
- (void)auxWindowClosing:(NSWindowController *)aController;

#ifndef APPSTORE
- (IBAction)checkForUpdates:(id)sender;
#endif

@end
