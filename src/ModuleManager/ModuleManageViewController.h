#import <Cocoa/Cocoa.h>
#import <FooLogger/CocoLogger.h>

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
    IBOutlet NSTextField *editISCaptionCell;
    IBOutlet NSTextField *editISSourceCell;
    IBOutlet NSTextField *editISDirCell;
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
    IBOutlet NSWindow *__strong parentWindow;
    
    // menus
    IBOutlet NSMenu *installSourceMenu;
    
    // the module list view controller
    IBOutlet ModuleListViewController *modListViewController;
}

@property (strong, readwrite) IBOutlet id delegate;
@property (strong, readwrite) IBOutlet NSWindow *parentWindow;

@property (strong, nonatomic) NSArray *installSourceListObjects;
@property (strong, nonatomic) NSArray *selectedInstallSources;

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
