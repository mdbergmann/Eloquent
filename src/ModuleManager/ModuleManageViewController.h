#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@class ModuleListObject;
@class InstallSourceListObject;
@class ModuleListViewController;

#define EDITING_MODE_ADD    1
#define EDITING_MODE_EDIT   2

#define TYPE_TAG_REMOTE 0
#define TYPE_TAG_LOCAL  1

@interface ModuleManageViewController : NSObject <NSOutlineViewDelegate, NSOutlineViewDataSource> {
    
    // the views
    IBOutlet NSOutlineView *categoryOutlineView;
    IBOutlet NSSplitView *splitView;
    IBOutlet NSPopUpButton *actionButton;
    
    // add/edit Install Source window
    IBOutlet NSWindow *editISWindow;
    IBOutlet NSButton *editISOKButton;
    IBOutlet NSButton *editISCancelButton;    
    IBOutlet NSButton *editISTestButton;
    IBOutlet NSFormCell *editISCaptionCell;
    IBOutlet NSFormCell *editISSourceCell;
    IBOutlet NSFormCell *editISDirCell;    
    // the type popup
    IBOutlet NSPopUpButton *editISType;
    IBOutlet NSButton *editISDirSelect;
    // disclaimer window
    IBOutlet NSWindow *disclaimerWindow;
    // tasks preview window
    IBOutlet NSWindow *tasksPreviewWindow;
    
    // The preview text field
    IBOutlet NSTextField *tasksPreviewTextField;
    IBOutlet NSButton *processTasksButton;

    // the hosting window
    IBOutlet NSWindow *parentWindow;
    
    // menus
    IBOutlet NSMenu *installSourceMenu;
    
    // the module list view controller
    IBOutlet ModuleListViewController *modListViewController;
    
    // any delegate
    IBOutlet id delegate;
    
    /** the selected install sources */
    NSArray *selectedInstallSources;
    
    /** dictionaries that hold things to be installed/removed/updated (first remove, then update) */
    NSMutableDictionary *installDict;
    NSMutableDictionary *removeDict;
    
    /** the array used for display in outline view */
    NSMutableArray *installSourceListObjects;
    
    int editingMode;
    
    // initialized?
    BOOL initialized;
}

@property (assign, readwrite) IBOutlet id delegate;
@property (assign, readwrite) IBOutlet NSWindow *parentWindow;
@property (retain, readwrite) NSArray *selectedInstallSources;

+ (NSURL *)fileOpenDialog;

- (BOOL)initialized;

// --------------- methods ----------------
- (id)initWithDelegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate parent:(NSWindow *)aParent;

- (NSView *)contentView;

/** delegate methods */
- (void)unregister:(ModuleListObject *)modObj;
- (void)registerForInstall:(ModuleListObject *)modObj;
- (void)registerForRemove:(ModuleListObject *)modObj;
- (void)registerForUpdate:(ModuleListObject *)modObj;

/** process all the tasks */
- (void)processTasks;
- (NSInteger)numberOfTasks;
- (BOOL)hasTasks;

/** show tasks preview */
- (void)showTasksPreview;
- (void)tasksPreviewSheetEnd;

// tasks preview window actions
- (IBAction)closePreview:(id)sender;
- (IBAction)processTasks:(id)sender;
/** serialize tasks for previews */
- (NSString *)tasksPreviewDescription;

// disclaimer
- (IBAction)showDisclaimer;
- (void)disclaimerSheetEnd;
// disclaimer window actions
- (IBAction)confirmNo:(id)sender;
- (IBAction)confirmYes:(id)sender;

- (IBAction)syncInstallSourcesFromMasterList:(id)sender;
- (IBAction)addInstallSource:(id)sender;
- (IBAction)deleteInstallSource:(id)sender;
- (IBAction)editInstallSource:(id)sender;
- (IBAction)refreshInstallSource:(id)sender;

// add/edit IS actions
- (IBAction)editISOKButton:(id)sender;
- (IBAction)editISCancelButton:(id)sender;
- (IBAction)editISTestButton:(id)sender;
- (IBAction)editISDirSelectButton:(id)sender;
- (IBAction)editISTypeSelect:(id)sender;

@end
