
#import <Cocoa/Cocoa.h>
#import <CocoPCRE/CocoPCRE.h>
#import <CocoLogger/CocoLogger.h>
#import "SwordInstallSourceManager.h"
#import <ObjCSword/SwordInstallSource.h>
#import <ObjCSword/SwordModule.h>
#import <globals.h>

@interface ModuleListViewController : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate> {
    
    IBOutlet NSOutlineView *moduleOutlineView;
    IBOutlet NSSearchField *searchTextField;
    
    IBOutlet id delegate;

    // menu
    IBOutlet NSMenu *moduleMenu;
    IBOutlet NSPopUpButton *languagesButton;
    
    /** we store a retained copy of the selected install sources */
    NSArray *installSources;
    
    /** our data for displaying the module data */
    NSMutableArray *moduleData;
    
    /** the selection */
    NSMutableArray *moduleSelection;
    
    /** current sort descriptors */
    NSArray *sortDescriptors;
    
    NSString *langFilter;
}

@property (readwrite, retain) NSString *langFilter;

// ------------- getter / setter -------------------
- (void)setDelegate:(id)aDelegate;
- (id)delegate;

- (void)setInstallSources:(NSArray *)anArray;
- (NSArray *)installSources;

/** update the modules with the modules in the sources list */
- (void)refreshModulesList;

// actions
- (IBAction)search:(id)sender;
- (IBAction)languageFilter:(id)sender;
// menu actions
- (IBAction)noneTask:(id)sender;
- (IBAction)installModule:(id)sender;
- (IBAction)removeModule:(id)sender;
- (IBAction)updateModule:(id)sender;

@end
