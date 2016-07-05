//
//  WorkspaceViewHostController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 06.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HostableViewController.h"
#import "WorkspaceViewHostController.h"
#import "SingleViewHostController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "AppController.h"
#import "ModuleCommonsViewController.h"
#import "BibleCombiViewController.h"
#import "ModuleViewController.h"
#import "SearchTextObject.h"
#import "NotesViewController.h"
#import "WindowHostController+SideBars.h"
#import "ContentDisplayingViewControllerFactory.h"
#import "InitialInfoViewController.h"
#import "RightSideBarViewController.h"
#import "PSMYosemiteTabStyle.h"

@interface PSMTabBarControl (mystuff)

- (PSMRolloverButton *)addTabButton;

@end

@interface WorkspaceViewHostController ()

@property (strong, readwrite) NSMutableArray *viewControllers;
@property (strong, readwrite) NSMutableArray *searchTextObjs;

- (void)commonInit;
- (NSString *)tabViewItemLabelForText:(NSString *)aText;
- (NSString *)computeTabTitleForTabIndex:(NSInteger)index;
- (void)_addContentViewController:(ContentDisplayingViewController *)aViewController;

@end


@implementation WorkspaceViewHostController

@synthesize viewControllers;
@synthesize searchTextObjs;

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        lsbShowing = [userDefaults boolForKey:DefaultsShowLSBWorkspace];
        rsbShowing = [userDefaults boolForKey:DefaultsShowRSBWorkspace];

        [self setViewControllers:[NSMutableArray array]];
        [self setSearchTextObjs:[NSMutableArray array]];
        
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    BOOL stat = [NSBundle loadNibNamed:@"WorkspaceViewHost" owner:self];
    if(!stat) {
        CocoLog(LEVEL_ERR, @"unable to load nib!");
    }    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    // tab control stuff
    [tabControl setHideForSingleTab:NO];
    [tabControl setOrientation:PSMTabBarHorizontalOrientation];
    [tabControl setStyle:[[PSMYosemiteTabStyle alloc] init]];
    PSMRolloverButton *button = [tabControl addTabButton];
    [(NSButton *)button setTarget:self];
    [(NSButton *)button setAction:@selector(addTab:)];
    [tabControl setShowAddTabButton:YES];
    [tabControl setTabsHaveCloseButtons:YES];
    
    // for a clean new workspace we display the initialMainView
    if([viewControllers count] == 0) {
        [contentPlaceHolderView setContentView:[initialViewController view]];
    } else {
        [contentPlaceHolderView setContentView:defaultMainView];
    }

    // TODO: put initial view
    //[contentPlaceHolderView setContentView:defaultMainView];

    [self removeAndAddTabsWithSelectedIndex:0];

    // Fix: this will select the first element of the search texts objects as the current one
    if([[self searchTextObjs] count] > 0) {
        currentSearchText = [[self searchTextObjs] objectAtIndex:0];
    }
        
    if(contentViewController != nil) {
        [self setupForContentViewController];
    }
    
    hostLoaded = YES;
}

#pragma mark - Methods

- (NSView *)contentView {
    return [placeHolderView contentView];
}

- (void)setContentView:(NSView *)aView {
    [placeHolderView setContentView:aView];
}


- (NSString *)tabViewItemLabelForText:(NSString *)aText {
    return [NSString stringWithFormat:@"%@ - %ld", aText, [[[tabControl tabView] tabViewItems] count]];
}

- (NSString *)computeTabTitle {
    return [self computeTabTitleForTabIndex:-1];
}

- (NSString *)computeTabTitleForTabIndex:(NSInteger)index {
    NSMutableString *ret = [NSMutableString string];
    
    ContentDisplayingViewController *vc;
    if(index >= 0) {
        vc = [viewControllers objectAtIndex:index];
    } else {
        vc = contentViewController;
    }
    
    if(vc != nil) {
        if([vc isSwordModuleContentType]) {
            SwordModule *mod = [(ModuleViewController *)vc module];
            if(mod != nil) {
                SearchTextObject *sto;
                if(index == -1) {
                    sto = currentSearchText;
                } else {
                    sto = [searchTextObjs objectAtIndex:(NSUInteger)index];
                }
                [ret appendFormat:@"%@ - %@", [mod name], [sto searchTextForType:[self searchType]]];                    
            }
        } else if([vc isNoteContentType]) {
            [ret appendString:[(NotesViewController *)vc title]];
        }
    }    
    
    return ret;    
}

- (void)updateTabTitles {
    int i = 0;
    for(NSTabViewItem *item in [tabView tabViewItems]) {
        NSString *tabTitle = [self computeTabTitleForTabIndex:i];
        [item setLabel:tabTitle];
        i++;
    }
}

- (void)removeAndAddTabsWithSelectedIndex:(NSInteger)index {
    for(NSTabViewItem *item in [tabView tabViewItems]) {
        [tabView removeTabViewItem:item];
    }

    int i = 0;
    for(ContentDisplayingViewController *vc in viewControllers) {
        if([vc viewLoaded]) {
            NSTabViewItem *item = [[NSTabViewItem alloc] init];
            [item setView:[vc view]];
            [tabView addTabViewItem:item];
            [item setLabel:[self computeTabTitle]];
            
            if(i == index) {
                contentViewController = vc;
                [tabView selectTabViewItem:item];
            }
        }
        i++;
    }
}

- (void)restoreRightSideBarWithWidth:(float)width {
    NSView *rv = [rsbViewController view];
    NSRect rvRect = [rv frame];
    rvRect.size.width = width;
    [rv setFrameSize:rvRect.size];
    
    NSRect lvRect = [tabView frame];
    lvRect.size.width = [contentSplitView frame].size.width - (rvRect.size.width + [contentSplitView dividerThickness]);
    [tabView setFrameSize:lvRect.size];
}

- (void)readaptHostUI {
    [super readaptHostUI];

    [[tabView selectedTabViewItem] setLabel:[self computeTabTitle]];
}

- (void)setSearchText:(NSString *)aString {
    [super setSearchText:aString];
    [[tabView selectedTabViewItem] setLabel:[self computeTabTitle]];
}

#pragma mark - Actions

- (IBAction)performClose:(id)sender {
    if([[tabView tabViewItems] count] == 0) {
        [self close];
    } else {
        NSTabViewItem *item = [tabView selectedTabViewItem];
        if(item != nil) {
            // find view controller
            NSUInteger index = (NSUInteger)[tabView indexOfTabViewItem:item];
            HostableViewController *vc = [viewControllers objectAtIndex:index];
            [tabView removeTabViewItem:item];
            
            if(vc != nil) {
                [searchTextObjs removeObjectAtIndex:index];
                [viewControllers removeObjectAtIndex:index];
            }
        }
    }
}

- (IBAction)addTab:(id)sender {
    // adding a tab adds a default bible view
    NSString *sBible = [userDefaults stringForKey:DefaultsBibleModule];
    SwordModule *mod = nil;
    if(sBible != nil) {
        mod = [[SwordManager defaultManager] moduleWithName:sBible];
    }
    if(mod) {
        ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:mod];
        [hc setDelegate:self];
        [self addContentViewController:hc];
    }
}

- (IBAction)openModuleInstaller:(id)sender {
    [[AppController defaultAppController] showModuleManager:sender];
}

- (IBAction)menuItemSelected:(id)sender {
    int tag = [(NSMenuItem *)sender tag];
    
    NSUInteger index = [[tabView tabViewItems] indexOfObject:[tabView selectedTabViewItem]];
    ContentDisplayingViewController *vc = [viewControllers objectAtIndex:index];

    // found view controller?
    if(vc != nil) {
        if(tag == 1) {
            // open in single window

            // save search reference
            NSString *searchRef = [self searchText];

            NSTabViewItem *tvi = [[tabView tabViewItems] objectAtIndex:index];
            [searchTextObjs removeObjectAtIndex:index];
            [viewControllers removeObject:vc];
            [tabView removeTabViewItem:tvi];

            // if there are more tabviews, select the next one
            if([[tabView tabViewItems] count] > 0) {
                [tabView selectTabViewItemAtIndex:0];
            } else {
                [self setView:nil];
                [scopebarViewPlaceholder setContentView:nil];
                [self showRightSideBar:NO];
            }

            SingleViewHostController *svc = nil;
            if([vc isKindOfClass:[ModuleViewController class]]) {
                // get module of vc and use it to open a single view
                SwordModule *mod = [(ModuleViewController *)vc module];
                svc = [[AppController defaultAppController] openSingleHostWindowForModule:mod];
            } else if([vc isKindOfClass:[BibleCombiViewController class]]) {
                // open single host window
                svc = [[AppController defaultAppController] openSingleHostWindowForModule:nil];
                [vc setDelegate:svc];
                [vc setHostingDelegate:svc];
                [svc addContentViewController:vc];
            }
            [vc setHostingDelegate:svc];
            [svc setSearchText:searchRef];
        }
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)item {
    if([item tag] == 0) {
        // close
        if([viewControllers count] == 1) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - PSMTabBarControlDelegate

- (BOOL)tabView:(NSTabView *)aTabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    CocoLog(LEVEL_DEBUG, @"Close tab?");
    
    // find view controller
    NSUInteger index = [[tabControl representedTabViewItems] indexOfObject:tabViewItem];
    ContentDisplayingViewController *vc = [viewControllers objectAtIndex:index];
    if(vc != nil) {
        if([vc hasUnsavedContent]) {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", @"")
                                             defaultButton:NSLocalizedString(@"Yes", @"")
                                           alternateButton:NSLocalizedString(@"Cancel", @"")
                                               otherButton:NSLocalizedString(@"No", @"")
                                 informativeTextWithFormat:NSLocalizedString(@"UnsavedContent", @"")];
            NSInteger modalResult = [alert runModal];
            if(modalResult == NSAlertDefaultReturn) {
                [vc saveContent];
            } else if(modalResult == NSAlertAlternateReturn) {
                return NO;
            }
        }
    }

    return YES;
}

- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    CocoLog(LEVEL_DEBUG, @"Tab closed!");
    
    // select the previous tab
    NSUInteger index = [[tabControl representedTabViewItems] indexOfObject:tabViewItem];
    if(index > 0 && index < [viewControllers count]) {
        // also remove search text obj
        [searchTextObjs removeObjectAtIndex:index];
        // remove this view controller from our list
        [viewControllers removeObjectAtIndex:index];
    }
}

- (NSMenu *)tabView:(NSTabView *)aTabView menuForTabViewItem:(NSTabViewItem *)tabViewItem {
    return tabItemMenu;
}

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    CocoLog(LEVEL_DEBUG, @"Tab selected");
    if(hostLoaded) {
        if([[tabControl representedTabViewItems] containsObject:tabViewItem]) {
            NSUInteger index = [[tabControl representedTabViewItems] indexOfObject:tabViewItem];
            contentViewController = [viewControllers objectAtIndex:index];
            
            [self setCurrentSearchText:[searchTextObjs objectAtIndex:index]];
            [self setupForContentViewController];
        }
    }
}

- (void)tabView:(NSTabView *)tabView updateStateForTabViewItem:(NSTabViewItem *)tabViewItem {
    CocoLog(LEVEL_DEBUG, @"Tab updatedState!");
}

#pragma mark - SubviewHosting protocol

- (void)addContentViewController:(ContentDisplayingViewController *)aViewController {
    if(![viewControllers containsObject:aViewController]) {
        // only add controllers we don't show yet
        [viewControllers addObject:aViewController];
        [aViewController setShowingRSBPreferred:[userDefaults boolForKey:DefaultsShowRSBWorkspace]];

        [self _addContentViewController:aViewController];
        [super addContentViewController:aViewController];
    }
}

- (void)contentViewInitFinished:(HostableViewController *)aViewController {    
    [super contentViewInitFinished:aViewController];
    
    // if we don't know this view controller yet and it is a ContentDisplayingViewController, add it to our view controllers
    if(![viewControllers containsObject:aViewController] && [aViewController isKindOfClass:[ContentDisplayingViewController class]]) {
        [self addContentViewController:(ContentDisplayingViewController *)aViewController];
    } else {
        [self _addContentViewController:(ContentDisplayingViewController *)aViewController];
    }
}

- (void)_addContentViewController:(ContentDisplayingViewController *)aViewController {
    // we are only interessted in view controllers that show information
    if([aViewController isKindOfClass:[ContentDisplayingViewController class]]) {
        // remove initialMainView if present
        if([contentPlaceHolderView contentView] == [initialViewController view]) {
            [[initialViewController view] removeFromSuperview];

            // TODO: adding defaultMainView later raises an exception and makes the view unresizable
            [contentPlaceHolderView setContentView:defaultMainView];
        }
        
        // extend searchTexts
        SearchType stype = [currentSearchText searchType];
        SearchTextObject *sto = [[SearchTextObject alloc] init];
        [sto setSearchText:@"" forSearchType:stype];
        [sto setRecentSearches:[NSMutableArray array] forSearchType:stype];
        [sto setSearchType:stype];
        [searchTextObjs addObject:sto];
        [self setCurrentSearchText:sto];
        
        // add tab item
        NSTabViewItem *newItem = [[NSTabViewItem alloc] init];
        [tabView addTabViewItem:newItem];
        [tabView selectTabViewItem:newItem];
        [newItem setView:[aViewController view]];
        [newItem setLabel:[self computeTabTitle]];
    }    
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [super removeSubview:aViewController];

    // get index for if this is a module based controller
    NSUInteger index = [viewControllers indexOfObject:aViewController];
    if(index > 0) {
        [searchTextObjs removeObjectAtIndex:index];
    }
}

#pragma mark - ContentSaving

- (BOOL)hasUnsavedContent {
    for(ContentDisplayingViewController *vc in viewControllers) {
        if([vc hasUnsavedContent]) {
            return YES;
        }
    }
    return NO;
}

- (void)saveContent {
    for(ContentDisplayingViewController *vc in viewControllers) {
        if([vc hasUnsavedContent]) {
            [vc saveContent];
        }
    }
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        if (!(self = [super initWithCoder:decoder])) return nil;

        self.searchTextObjs = [decoder decodeObjectForKey:@"SearchTextObjects"];

        self.viewControllers = [decoder decodeObjectForKey:@"HostableViewControllerListEncoded"];
        for(ContentDisplayingViewController *vc in viewControllers) {
            [vc setDelegate:self];
            [vc adaptUIToHost];
        }

        [self commonInit];

        // set window frame
        NSRect frame;
        frame.origin = [decoder decodePointForKey:@"WindowOriginEncoded"];
        frame.size = [decoder decodeSizeForKey:@"WindowSizeEncoded"];
        if(frame.size.width > 0 && frame.size.height > 0) {
            [[self window] setFrame:frame display:YES];
        }

        // set tab labels
        for(NSInteger i = [viewControllers count]-1;i >= 0;--i) {
            ContentDisplayingViewController *vc = [viewControllers objectAtIndex:(NSUInteger)i];
            contentViewController = vc;
            if([vc viewLoaded]) {
                NSTabViewItem *item = [[tabView tabViewItems] objectAtIndex:(NSUInteger)i];
                [item setLabel:[self computeTabTitleForTabIndex:i]];
            }
        }
        
        // restore sidebar widths
        if(lsbShowing) {
            [self restoreLeftSideBarWithWidth:loadedLSBWidth];
        }
        if([self showingRSB]) {
            [self restoreRightSideBarWithWidth:loadedRSBWidth];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:viewControllers forKey:@"HostableViewControllerListEncoded"];
    [encoder encodeObject:searchTextObjs forKey:@"SearchTextObjects"];
    
    [super encodeWithCoder:encoder];
}

@end
