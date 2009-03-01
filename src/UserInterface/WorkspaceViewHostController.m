//
//  WorkspaceViewHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 06.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WorkspaceViewHostController.h"
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
    
    // re-set already loaded tabview items
    int i = 0;
    for(HostableViewController *vc in viewControllers) {
        if([vc viewLoaded]) {
            NSTabViewItem *item = [[NSTabViewItem alloc] init];
            [item setLabel:[vc label]];
            [item setView:[vc view]];
            [tabView addTabViewItem:item];
            
            // select first
            if(i == 0) {
                activeViewController = vc;
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
    
    // show left side bar
    [self showLeftSideBar:[userDefaults boolForKey:DefaultsShowLSB]];
    if(activeViewController != nil) {
        // add content view
        [placeHolderView setContentView:[activeViewController view]];
        // add display options view
        [placeHolderSearchOptionsView setContentView:[(<TextDisplayable>)activeViewController referenceOptionsView]];        
        
        // all booktypes have something to show in the right side bar
        [rsbViewController setContentView:[(GenBookViewController *)activeViewController listContentView]];
        if([activeViewController isKindOfClass:[DictionaryViewController class]] ||
           [activeViewController isKindOfClass:[GenBookViewController class]]) {
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
    
    if([activeViewController isKindOfClass:[CommentaryViewController class]]) {
        moduleType = commentary;
    } else if([activeViewController isKindOfClass:[BibleCombiViewController class]]) {
        moduleType = bible;
    } else if([activeViewController isKindOfClass:[DictionaryViewController class]]) {
        moduleType = dictionary;
    } else if([activeViewController isKindOfClass:[GenBookViewController class]]) {
        moduleType = genbook;
    }
    
    return moduleType;
}

- (HostableViewController *)contentViewController {
    return activeViewController;
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
        
        // the view controller will be added in contentViewDidFinisLoading:
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

    // search text objects are added when this view reports it has loaded
    return vc;
}

- (NSString *)tabViewItemLabelForText:(NSString *)aText {
    return [NSString stringWithFormat:@"%@ - %i", aText, [[[tabControl tabView] tabViewItems] count]];
}

#pragma mark - Toolbar Actions

- (void)addBibleTB:(id)sender {
    if([activeViewController isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)activeViewController addNewBibleViewWithModule:nil];
    }
}

- (void)searchInput:(id)sender {
    MBLOGV(MBLOG_DEBUG, @"search input: %@", [sender stringValue]);
    
    [super searchInput:sender];
    
    NSString *searchText = [sender stringValue];
    if([activeViewController isKindOfClass:[BibleCombiViewController class]] ||
        [activeViewController isKindOfClass:[CommentaryViewController class]] ||
        [activeViewController isKindOfClass:[DictionaryViewController class]] ||
        [activeViewController isKindOfClass:[GenBookViewController class]]) {
        [(<TextDisplayable>)activeViewController displayTextForReference:searchText searchType:self.searchType];
    }
}

#pragma mark - Actions

- (IBAction)addTab:(id)sender {
    [self addTabContentForModuleType:[self moduleType]];
}

- (IBAction)menuItemSelected:(id)sender {
    int tag = [(NSMenuItem *)sender tag];
    
    int index = [[tabView tabViewItems] indexOfObject:[tabView selectedTabViewItem]];
    HostableViewController *vc = [viewControllers objectAtIndex:index];

    // found view controller?
    if(vc != nil) {
        switch(tag) {
            case 0:
            {
                // close
                int index = [viewControllers indexOfObject:vc];
                // also remove search text obj
                [searchTextObjs removeObjectAtIndex:index];
                // remove this view controller from our list
                [viewControllers removeObject:vc];
                break;
            }
            case 1:
            {
                // open in single
                if([viewControllers count] > 1) {
                    // also remove search text obj
                    [searchTextObjs removeObjectAtIndex:index];
                    // remove this view controller from our list
                    [viewControllers removeObject:vc];
                }
                if([vc isKindOfClass:[ModuleViewController class]]) {
                    // get module of vc and use it to open a single view
                    SwordModule *mod = [(ModuleViewController *)vc module];
                    [[AppController defaultAppController] openSingleHostWindowForModule:mod];
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
            activeViewController = vc;
            if(activeViewController != nil) {
                // add display options view
                [placeHolderSearchOptionsView setContentView:[(<TextDisplayable>)activeViewController referenceOptionsView]];    
            }
            
            // all booktypes have something to show in the right side bar
            [rsbViewController setContentView:[(GenBookViewController *)vc listContentView]];
            if([vc isKindOfClass:[DictionaryViewController class]] ||
               [vc isKindOfClass:[GenBookViewController class]]) {
                [self showRightSideBar:YES];
            } else {
                [self showRightSideBar:[userDefaults boolForKey:DefaultsShowRSB]];                
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
    
    // let super class first handle it's things
    [super contentViewInitFinished:aViewController];
    
    if(hostLoaded) {
        // we are only interessted in view controllers that show information
        if([aViewController isKindOfClass:[ModuleViewController class]] ||
           [aViewController isKindOfClass:[BibleCombiViewController class]]) { // this also handles commentary view
            
            // add view controller
            [viewControllers addObject:aViewController];
            // make the last added the active one
            activeViewController = aViewController;
            
            // extend searchTexts
            SearchTextObject *sto = [[SearchTextObject alloc] init];
            [sto setSearchText:@"" forSearchType:self.searchType];
            [sto setRecentSearches:[NSMutableArray array] forSearchType:self.searchType];
            [sto setSearchType:self.searchType];
            [searchTextObjs addObject:sto];
            // also set current search Text
            [self setCurrentSearchText:sto];
            // set text according search type
            [searchTextField setStringValue:[currentSearchText searchTextForType:self.searchType]];
            // switch recentSearches
            [searchTextField setRecentSearches:[currentSearchText recentSearchsForType:self.searchType]];    

            NSTabViewItem *newItem = [[NSTabViewItem alloc] init];
            [newItem setLabel:[aViewController label]];
            [newItem setView:[aViewController view]];
            [tabView addTabViewItem:newItem];
            [tabView selectTabViewItem:newItem]; // this is optional, but expected behavior        

            // all booktypes have something to show in the right side bar
            [rsbViewController setContentView:[(GenBookViewController *)aViewController listContentView]];
            if([aViewController isKindOfClass:[DictionaryViewController class]] ||
               [aViewController isKindOfClass:[GenBookViewController class]]) {
                [self showRightSideBar:YES];
            } else {
                [self showRightSideBar:[userDefaults boolForKey:DefaultsShowRSB]];                
            }
            
            if(activeViewController != nil) {
                // add display options view
                [placeHolderSearchOptionsView setContentView:[(<TextDisplayable>)activeViewController referenceOptionsView]];    
            }            
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
        }

        // load nib
        BOOL stat = [NSBundle loadNibNamed:WORKSPACEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[WorkspaceViewHostController -init] unable to load nib!");
        }
        
        // load the common things
        [super initWithCoder:decoder];
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
