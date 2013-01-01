
#import <Cocoa/Cocoa.h>
#import <CocoPCRE/CocoPCRE.h>
#import <CocoLogger/CocoLogger.h>
#import <ObjCSword/SwordInstallSource.h>
#import <ObjCSword/SwordModule.h>

@interface ModuleListViewController : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate> {
    
    IBOutlet NSOutlineView *moduleOutlineView;
    IBOutlet NSSearchField *searchTextField;
    
    // menu
    IBOutlet NSMenu *moduleMenu;
    IBOutlet NSPopUpButton *languagesButton;
}

@property (readwrite) NSString *langFilter;

/** we store a retained copy of the selected install sources */
@property (readwrite) NSArray *installSources;

@property (readwrite, assign) IBOutlet id delegate;

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
