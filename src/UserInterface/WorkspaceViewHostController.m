//
//  WorkspaceViewHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 06.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WorkspaceViewHostController.h"
#import "SingleViewHostController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "AppController.h"
#import "BibleCombiViewController.h"
#import "CommentaryViewController.h"
#import "DictionaryViewController.h"
#import "GenBookViewController.h"
#import "HostableViewController.h"
#import "BibleSearchOptionsViewController.h"
#import "LeftSideBarViewController.h"
#import "RightSideBarViewController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SearchTextObject.h"
#import "FakeModel.h"

@interface WorkspaceViewHostController ()

@property (retain, readwrite) NSMutableArray *viewControllers;
@property (retain, readwrite) NSMutableArray *searchTextObjs;

- (NSString *)tabViewItemLabelForText:(NSString *)aText;

@end


@implementation WorkspaceViewHostController

@synthesize viewControllers;
@synthesize searchTextObjs;

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -init] nib loaded");
        
        // init view controller array
        [self setViewControllers:[NSMutableArray array]];
        // init search texts
        [self setSearchTextObjs:[NSMutableArray array]];
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:WORKSPACEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[WorkspaceViewHostController -init] unable to load nib!");
        }
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -awakeFromNib]");
    
    // super class has some things to set
    [super awakeFromNib];
    
    // tab control stuff
    [tabControl setHideForSingleTab:NO];
    //[tabControl setFont:FontStdBold];
    [tabControl setOrientation:PSMTabBarHorizontalOrientation];
    [tabControl setStyleNamed:@"Aqua"];
    [[tabControl addTabButton] setTarget:self];
    [[tabControl addTabButton] setAction:@selector(addTab:)];
    [tabControl setShowAddTabButton:YES];
    [tabControl setCanCloseOnlyTab:YES];
    // remove all tabs
    for(NSTabViewItem *item in [tabView tabViewItems]) {
        [tabView removeTabViewItem:item];    
    }
    
    // for a clean new workspace we display the initialMainView
    if([viewControllers count] == 0) {
        [mainSplitView addSubview:[initialViewController view]];
    } else {
        [mainSplitView addSubview:defaultMainView];
    }
    
    // re-set already loaded tabview items
    int i = 0;
    for(HostableViewController *vc in viewControllers) {
        if([vc viewLoaded]) {
            NSTabViewItem *item = [[NSTabViewItem alloc] init];
            [item setLabel:[self computeTabTitle]];
            [item setView:[vc view]];
            [tabView addTabViewItem:item];
            
            // select first
            if(i == 0) {
                contentViewController = vc;
                [tabView selectTabViewItem:item];
            }
        }
        i++;
    }
    
    // set font for bottombar segmented control
    [rightSideBottomSegControl setFont:FontStd];
    [leftSideBottomSegControl setFont:FontStd];
    
    // set currect searchText if available
    if([searchTextObjs count] > 0) {
        currentSearchText = [searchTextObjs objectAtIndex:0];
    }
    
    /*
    // if a reference is stored, we should load it
    NSString *referenceText = [currentSearchText searchTextForType:ReferenceSearchType];
    if([referenceText length] > 0) {
        for(HostableViewController *vc in viewControllers) {
            if([vc isKindOfClass:[BibleCombiViewController class]]) {
                [(BibleCombiViewController *)vc displayTextForReference:referenceText searchType:ReferenceSearchType];
            } else if([vc isKindOfClass:[CommentaryViewController class]]) {
                [(CommentaryViewController *)vc displayTextForReference:referenceText searchType:ReferenceSearchType];
            }
        }
    }
    
    // This is the last selected search type and the text for it
    NSString *searchText = [currentSearchText searchTextForType:self.searchType];
    if([searchText length] > 0) {
        [searchTextField setStringValue:searchText];
        for(HostableViewController *vc in viewControllers) {
            if([vc isKindOfClass:[BibleCombiViewController class]]) {
                [(BibleCombiViewController *)vc displayTextForReference:searchText searchType:self.searchType];
            } else if([vc isKindOfClass:[CommentaryViewController class]]) {
                [(CommentaryViewController *)vc displayTextForReference:searchText searchType:self.searchType];
            }
        }
    }
     */
    
    // show left side bar
    [self showLeftSideBar:[userDefaults boolForKey:DefaultsShowLSB]];
    if(contentViewController != nil) {
        // add content view
        [placeHolderView setContentView:[contentViewController view]];
        // add display options view
        [placeHolderSearchOptionsView setContentView:[(<TextDisplayable>)contentViewController referenceOptionsView]];        
        
        // all booktypes have something to show in the right side bar
        [rsbViewController setContentView:[(GenBookViewController *)contentViewController listContentView]];
        if([contentViewController isKindOfClass:[DictionaryViewController class]] ||
           [contentViewController isKindOfClass:[GenBookViewController class]]) {
            [self showRightSideBar:YES];
        } else {
            [self showRightSideBar:[userDefaults boolForKey:DefaultsShowRSB]];                
        }
        
        [self adaptUIToCurrentlyDisplayingModuleType];
    }
    
    hostLoaded = YES;
}

#pragma mark - Methods

- (ModuleType)moduleType {
    ModuleType moduleType = bible;
    
    if([contentViewController isKindOfClass:[CommentaryViewController class]]) {
        moduleType = commentary;
    } else if([contentViewController isKindOfClass:[BibleCombiViewController class]]) {
        moduleType = bible;
    } else if([contentViewController isKindOfClass:[DictionaryViewController class]]) {
        moduleType = dictionary;
    } else if([contentViewController isKindOfClass:[GenBookViewController class]]) {
        moduleType = genbook;
    }
    
    return moduleType;
}

- (HostableViewController *)contentViewController {
    return contentViewController;
}

- (NSView *)view {
    return [(NSBox *)placeHolderView contentView];
}

- (void)setView:(NSView *)aView {
    [(NSBox *)placeHolderView setContentView:aView];
}

- (HostableViewController *)addTabContentForModule:(SwordModule *)aModule {
    HostableViewController *vc = nil;

    if(aModule != nil) {
        ModuleType moduleType = [aModule type];
        if(moduleType == bible) {
            vc = [[BibleCombiViewController alloc] initWithDelegate:self andInitialModule:(SwordBible *)aModule];
        } else if(moduleType == commentary) {
            vc = [[CommentaryViewController alloc] initWithModule:aModule delegate:self];
        } else if(moduleType == dictionary) {
            vc = [[DictionaryViewController alloc] initWithModule:aModule delegate:self];
        } else if(moduleType == genbook) {
            vc = [[GenBookViewController alloc] initWithModule:aModule delegate:self];
        }
        
        // set hosting delegate
        [(HostableViewController *)vc setHostingDelegate:self];
    }

    return vc;
}

- (HostableViewController *)addTabContentForModuleType:(ModuleType)aType {
    HostableViewController *vc = nil;
    if(aType == bible) {
        vc = [[BibleCombiViewController alloc] initWithDelegate:self];
    } else if(aType == commentary) {
        vc = [[CommentaryViewController alloc] initWithDelegate:self];
    } else if(aType == dictionary) {
        vc = [[DictionaryViewController alloc] initWithDelegate:self];
    } else if(aType == genbook) {
        vc = [[GenBookViewController alloc] initWithDelegate:self];
    }
    
    // set hosting delegate
    [(HostableViewController *)vc setHostingDelegate:self];
    
    // search text objects are added when this view reports it has loaded
    return vc;
}

- (NSString *)tabViewItemLabelForText:(NSString *)aText {
    return [NSString stringWithFormat:@"%@ - %i", aText, [[[tabControl tabView] tabViewItems] count]];
}

- (NSString *)computeTabTitle {
    NSMutableString *ret = [NSMutableString string];
    
    if(contentViewController != nil) {
        SwordModule *mod = [(ModuleViewController *)contentViewController module];
        if(mod != nil) {
            [ret appendFormat:@"%@ - %@", [mod name], [searchTextField stringValue]];
        }
    }    
    
    return ret;    
}

#pragma mark - Toolbar Actions

- (void)addBibleTB:(id)sender {
    if([contentViewController isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)contentViewController addNewBibleViewWithModule:nil];
    }
}

- (IBAction)forceReload:(id)sender {
    [(ModuleCommonsViewController *)contentViewController setForceRedisplay:YES];
    [(ModuleCommonsViewController *)contentViewController displayTextForReference:[currentSearchText searchTextForType:[currentSearchText searchType]]];
    [(ModuleCommonsViewController *)contentViewController setForceRedisplay:NO];
}

#pragma mark - Actions

- (void)searchInput:(id)sender {
    // let super class handle things first
    [super searchInput:sender];
    
    // now set new tab title to the current active one
    [[tabView selectedTabViewItem] setLabel:[self computeTabTitle]];
}

- (IBAction)performClose:(id)sender {
    MBLOG(MBLOG_DEBUG, @"[WorkspaceViewHostController -performClose:]");

    // if there are no tabs, close window
    if([[tabView tabViewItems] count] == 0) {
        [self close];
    } else {
        // get current selected tab item
        NSTabViewItem *item = [tabView selectedTabViewItem];
        if(item != nil) {
            // find view controller
            int index = [tabView indexOfTabViewItem:item];
            HostableViewController *vc = [viewControllers objectAtIndex:index];
            [tabView removeTabViewItem:item];
            
            // found view controller?
            if(vc != nil) {
                // also remove search text obj
                [searchTextObjs removeObjectAtIndex:index];
                // remove this view controller from our list
                [viewControllers removeObjectAtIndex:index];
            }
        }
    }
}

- (IBAction)addTab:(id)sender {
    // get default bible
    NSString *sBible = [userDefaults stringForKey:DefaultsBibleModule];
    SwordModule *mod = nil;
    if(sBible != nil) {
        mod = [[SwordManager defaultManager] moduleWithName:sBible];
    }
    if(mod) {
        [self addTabContentForModule:mod];
    } else {
        [self addTabContentForModuleType:[self moduleType]];    
    }
}

- (IBAction)openModuleInstaller:(id)sender {
    [[AppController defaultAppController] showModuleManager:sender];
}

- (IBAction)menuItemSelected:(id)sender {
    int tag = [(NSMenuItem *)sender tag];
    
    int index = [[tabView tabViewItems] indexOfObject:[tabView selectedTabViewItem]];
    HostableViewController *vc = [viewControllers objectAtIndex:index];

    // found view controller?
    if(vc != nil) {
        switch(tag) {
            case 1:
            {
                // open in single
                NSTabViewItem *tvi = [[tabView tabViewItems] objectAtIndex:index];
                // also remove search text obj
                [searchTextObjs removeObjectAtIndex:index];
                // remove this view controller from our list
                [viewControllers removeObject:vc];
                // remove tab
                [tabView removeTabViewItem:tvi];

                // if there are more tabviews, select the next one
                if([[tabView tabViewItems] count] > 0) {
                    [tabView selectTabViewItemAtIndex:0];
                } else {
                    [self setView:nil];
                    [placeHolderSearchOptionsView setContentView:nil];
                    [self showRightSideBar:NO];
                }
                
                if([vc isKindOfClass:[ModuleViewController class]]) {
                    // get module of vc and use it to open a single view
                    SwordModule *mod = [(ModuleViewController *)vc module];
                    [[AppController defaultAppController] openSingleHostWindowForModule:mod];
                } else if([vc isKindOfClass:[BibleCombiViewController class]]) {                    
                    // open single host window
                    SingleViewHostController *svc = [[AppController defaultAppController] openSingleHostWindowForModule:nil];
                    [svc setView:[tvi view]];
                    [svc setContentViewController:vc];
                }                
                break;
            }
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

#pragma mark - NSTabView delegates

- (BOOL)tabView:(NSTabView *)aTabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    
    // find view controller
    int index = [[tabControl representedTabViewItems] indexOfObject:tabViewItem];
    HostableViewController *vc = [viewControllers objectAtIndex:index];
    
    // found view controller?
    if(vc != nil) {
        // also remove search text obj
        [searchTextObjs removeObjectAtIndex:index];
        // remove this view controller from our list
        [viewControllers removeObjectAtIndex:index];
    }
    
    // repaint
    [tabControl setNeedsDisplay:YES];

    return YES;
}

- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem {
}

- (NSMenu *)tabView:(NSTabView *)aTabView menuForTabViewItem:(NSTabViewItem *)tabViewItem {
    return tabItemMenu;
}

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {

    if(hostLoaded) {
        if([[tabControl representedTabViewItems] containsObject:tabViewItem]) {
            int index = [[tabControl representedTabViewItems] indexOfObject:tabViewItem];
            HostableViewController *vc = [viewControllers objectAtIndex:index];
            // set active view controller
            contentViewController = vc;
            if(contentViewController != nil) {
                // add display options view
                [placeHolderSearchOptionsView setContentView:[(<TextDisplayable>)contentViewController referenceOptionsView]];    
            }
            
            // all booktypes have something to show in the right side bar
            [rsbViewController setContentView:[(GenBookViewController *)vc listContentView]];
            
            // this should help with the problem that the ride side bar always was reset to default width when switching tabs
            if([vc isKindOfClass:[DictionaryViewController class]] ||
               [vc isKindOfClass:[GenBookViewController class]]) {
                if(![self showingRSB]) {
                    [self showRightSideBar:YES];
                }
            } else {
                if(![self showingRSB] && [userDefaults boolForKey:DefaultsShowRSB]) {
                    [self showRightSideBar:YES];
                }
            }

            // also set current search Text
            [self setCurrentSearchText:[searchTextObjs objectAtIndex:index]];
            
            // tell host to adapt ui
            [self adaptUIToCurrentlyDisplayingModuleType];
        }
    }
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aViewController {    
    MBLOG(MBLOG_DEBUG, @"[WorkspaceViewHostController -contentViewInitFinished:]");

    // let super class handle it's things
    [super contentViewInitFinished:aViewController];

    if(hostLoaded) {
        // we are only interessted in view controllers that show information
        if([aViewController isKindOfClass:[ModuleViewController class]] || // this also handles commentary view
           [aViewController isKindOfClass:[BibleCombiViewController class]]) {
            
            // remove initialMainView if present
            if([[mainSplitView subviews] containsObject:[initialViewController view]]) {
                [[initialViewController view] removeFromSuperview];
                // and set default view
                [mainSplitView addSubview:defaultMainView];
            }
            
            // add view controller
            [viewControllers addObject:aViewController];
            // make the last added the active one
            contentViewController = aViewController;
            
            SearchType stype = ReferenceSearchType;
            if([aViewController isKindOfClass:[GenBookViewController class]]) {
                stype = IndexSearchType;
            }
            
            // extend searchTexts
            SearchTextObject *sto = [[SearchTextObject alloc] init];
            [sto setSearchText:@"" forSearchType:stype];
            [sto setRecentSearches:[NSMutableArray array] forSearchType:stype];
            [sto setSearchType:stype];
            [searchTextObjs addObject:sto];
            // also set current search Text
            [self setCurrentSearchText:sto];

            // all booktypes have something to show in the right side bar
            [rsbViewController setContentView:[(GenBookViewController *)aViewController listContentView]];
            if([aViewController isKindOfClass:[DictionaryViewController class]] ||
               [aViewController isKindOfClass:[GenBookViewController class]]) {
                [self showRightSideBar:YES];
            } else {
                [self showRightSideBar:[userDefaults boolForKey:DefaultsShowRSB]];                
            }

            NSTabViewItem *newItem = [[NSTabViewItem alloc] init];
            [newItem setLabel:[aViewController label]];
            [newItem setView:[aViewController view]];
            [tabView addTabViewItem:newItem];
            [tabView selectTabViewItem:newItem]; // this is optional, but expected behavior        
            
            // add display options view
            [placeHolderSearchOptionsView setContentView:[(<TextDisplayable>)contentViewController referenceOptionsView]];                    

            [self adaptUIToCurrentlyDisplayingModuleType];
        }
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [super removeSubview:aViewController];

    // get index for if this is a module based controller
    int index = [viewControllers indexOfObject:aViewController];
    if(index > 0) {
        [searchTextObjs removeObjectAtIndex:index];
    }
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
                
        // decode search texts
        self.searchTextObjs = [decoder decodeObjectForKey:@"SearchTextObjects"];

        // decode viewControllers
        self.viewControllers = [decoder decodeObjectForKey:@"HostableViewControllerListEncoded"];
        // set delegate
        for(HostableViewController *vc in viewControllers) {
            [vc setDelegate:self];
            [vc setHostingDelegate:self];
            [vc adaptUIToHost];
        }

        // load the common things
        [super initWithCoder:decoder];

        // load nib
        BOOL stat = [NSBundle loadNibNamed:WORKSPACEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[WorkspaceViewHostController -init] unable to load nib!");
        }
                
        // set window frame
        NSRect frame;
        frame.origin = [decoder decodePointForKey:@"WindowOriginEncoded"];
        frame.size = [decoder decodeSizeForKey:@"WindowSizeEncoded"];
        if(frame.size.width > 0 && frame.size.height > 0) {
            [[self window] setFrame:frame display:YES];
        }

        // loop over tab items and set title
        for(NSTabViewItem *item in [tabView tabViewItems]) {
            [item setLabel:[self computeTabTitle]];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode hostableviewcontroller
    [encoder encodeObject:viewControllers forKey:@"HostableViewControllerListEncoded"];
    // encode search texts
    [encoder encodeObject:searchTextObjs forKey:@"SearchTextObjects"];
    
    [super encodeWithCoder:encoder];
}

@end
