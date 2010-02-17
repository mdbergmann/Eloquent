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
#import "ContentDisplayingViewController.h"
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
#import "FileRepresentation.h"
#import "NotesViewController.h"

@interface WorkspaceViewHostController ()

@property (retain, readwrite) NSMutableArray *viewControllers;
@property (retain, readwrite) NSMutableArray *searchTextObjs;

- (NSString *)tabViewItemLabelForText:(NSString *)aText;
- (NSString *)computeTabTitleForTabIndex:(int)index;

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
    for(ContentDisplayingViewController *vc in viewControllers) {
        if([vc viewLoaded]) {
            NSTabViewItem *item = [[NSTabViewItem alloc] init];
            [item setView:[vc view]];
            [tabView addTabViewItem:item];
            [item setLabel:[self computeTabTitle]];
            
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
    
    // show left side bar
    [self showLeftSideBar:[userDefaults boolForKey:DefaultsShowLSB]];
    
    if(contentViewController != nil) {
        [self setupContentRelatedViews];
        [self adaptAccessoryViewComponents];
        [self adaptUIToCurrentlyDisplayingModuleType];
    }
    
    hostLoaded = YES;
}

#pragma mark - Methods

- (ContentDisplayingViewController *)contentViewController {
    return contentViewController;
}

- (NSView *)view {
    return [(NSBox *)placeHolderView contentView];
}

- (void)setView:(NSView *)aView {
    [(NSBox *)placeHolderView setContentView:aView];
}

- (ContentDisplayingViewController *)addTabContentForModule:(SwordModule *)aModule {
    ContentDisplayingViewController *vc = nil;

    if(aModule != nil) {
        ModuleType moduleType = [aModule type];
        if(moduleType == bible) {
            vc = [[BibleCombiViewController alloc] initWithDelegate:self andInitialModule:(SwordBible *)aModule];
        } else if(moduleType == commentary) {
            vc = [[CommentaryViewController alloc] initWithModule:(SwordBible *)aModule delegate:self];
        } else if(moduleType == dictionary) {
            vc = [[DictionaryViewController alloc] initWithModule:(SwordBible *)aModule delegate:self];
        } else if(moduleType == genbook) {
            vc = [[GenBookViewController alloc] initWithModule:(SwordBible *)aModule delegate:self];
        }
        
        // set hosting delegate
        [vc setHostingDelegate:self];
    }

    return vc;
}

- (ContentDisplayingViewController *)addTabContentForModuleType:(ModuleType)aType {
    ContentDisplayingViewController *vc = nil;
    if(aType == bible) {
        vc = [[BibleCombiViewController alloc] initWithDelegate:self];
    } else if(aType == commentary) {
        vc = [[CommentaryViewController alloc] initWithDelegate:self];
    } else if(aType == dictionary) {
        vc = [[DictionaryViewController alloc] initWithDelegate:self];
    } else if(aType == genbook) {
        vc = [[GenBookViewController alloc] initWithDelegate:self];
    }    
    [vc setHostingDelegate:self];
    
    return vc;
}

- (ContentDisplayingViewController *)addTabContentForNote:(FileRepresentation *)aFileRep {
    NotesViewController *vc = [[NotesViewController alloc] initWithDelegate:self hostingDelegate:self fileRep:aFileRep];
    return vc;
}

- (NSString *)tabViewItemLabelForText:(NSString *)aText {
    return [NSString stringWithFormat:@"%@ - %i", aText, [[[tabControl tabView] tabViewItems] count]];
}

- (NSString *)computeTabTitle {
    return [self computeTabTitleForTabIndex:-1];
}

- (NSString *)computeTabTitleForTabIndex:(int)index {
    NSMutableString *ret = [NSMutableString string];
    
    if(contentViewController != nil) {
        if([contentViewController isSwordModuleContentType]) {
            SwordModule *mod = [(ModuleViewController *)contentViewController module];
            if(mod != nil) {
                SearchTextObject *sto = nil;
                if(index == -1) {
                    sto = currentSearchText;
                } else {
                    sto = [searchTextObjs objectAtIndex:index];
                }
                [ret appendFormat:@"%@ - %@", [mod name], [sto searchTextForType:[self searchType]]];                    
            }            
        } else if([contentViewController isNoteContentType]) {
            [ret appendString:[(NotesViewController *)contentViewController label]];
        }
    }    
    
    return ret;    
}

#pragma mark - Toolbar Actions

- (IBAction)forceReload:(id)sender {
    [(ModuleCommonsViewController *)contentViewController setForceRedisplay:YES];
    [(ModuleCommonsViewController *)contentViewController displayTextForReference:[currentSearchText searchTextForType:[self searchType]]];
    [(ModuleCommonsViewController *)contentViewController setForceRedisplay:NO];
}

#pragma mark - Actions

- (void)searchInput:(id)sender {
    [super searchInput:sender];
    
    [[tabView selectedTabViewItem] setLabel:[self computeTabTitle]];
}

- (IBAction)performClose:(id)sender {
    MBLOG(MBLOG_DEBUG, @"[WorkspaceViewHostController -performClose:]");

    if([[tabView tabViewItems] count] == 0) {
        [self close];
    } else {
        NSTabViewItem *item = [tabView selectedTabViewItem];
        if(item != nil) {
            // find view controller
            int index = [tabView indexOfTabViewItem:item];
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
        [self addTabContentForModule:mod];
    } else {
        // TODO: define a deault bible to open here
    }
}

- (IBAction)openModuleInstaller:(id)sender {
    [[AppController defaultAppController] showModuleManager:sender];
}

- (IBAction)menuItemSelected:(id)sender {
    int tag = [(NSMenuItem *)sender tag];
    
    int index = [[tabView tabViewItems] indexOfObject:[tabView selectedTabViewItem]];
    ContentDisplayingViewController *vc = [viewControllers objectAtIndex:index];

    // found view controller?
    if(vc != nil) {
        switch(tag) {
            case 1:
            {
                // open in single

                // save search reference
                NSString *searchRef = [searchTextField stringValue];
                
                NSTabViewItem *tvi = [[tabView tabViewItems] objectAtIndex:index];
                [searchTextObjs removeObjectAtIndex:index];
                [viewControllers removeObject:vc];
                [tabView removeTabViewItem:tvi];

                // if there are more tabviews, select the next one
                if([[tabView tabViewItems] count] > 0) {
                    [tabView selectTabViewItemAtIndex:0];
                } else {
                    [self setView:nil];
                    [placeHolderSearchOptionsView setContentView:nil];
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
                    [svc setView:[tvi view]];
                    [svc setContentViewController:vc];
                }
                [svc setSearchText:searchRef];
                [vc setHostingDelegate:svc];
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
    if(index >= 0) {
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
            
            // also remove search text obj
            [searchTextObjs removeObjectAtIndex:index];            
            // remove this view controller from our list
            [viewControllers removeObjectAtIndex:index];
        }        
        [tabControl setNeedsDisplay:YES];
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
            contentViewController = [viewControllers objectAtIndex:index];
            
            if(contentViewController != nil) {
                [rsbViewController setContentView:[contentViewController rightAccessoryView]];
                [placeHolderSearchOptionsView setContentView:[contentViewController topAccessoryView]];                    

                BOOL showRightSideBar = YES;
                if([contentViewController isSwordModuleContentType]) {
                    if([self showingRSB] && ![userDefaults boolForKey:DefaultsShowRSB]) {
                        showRightSideBar = NO;
                    }
                } else if([contentViewController isNoteContentType]) {
                    showRightSideBar = NO;
                }
                [self showRightSideBar:showRightSideBar];
            }
            
            [self setCurrentSearchText:[searchTextObjs objectAtIndex:index]];
            [self adaptAccessoryViewComponents];
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
        if([aViewController isKindOfClass:[ContentDisplayingViewController class]]) {
            
            // remove initialMainView if present
            if([[mainSplitView subviews] containsObject:[initialViewController view]]) {
                [[initialViewController view] removeFromSuperview];
                [mainSplitView addSubview:defaultMainView];
            }
            
            [viewControllers addObject:aViewController];
            contentViewController = (ContentDisplayingViewController *)aViewController;
                        
            // extend searchTexts
            SearchType stype = [contentViewController searchType];
            SearchTextObject *sto = [[SearchTextObject alloc] init];
            [sto setSearchText:@"" forSearchType:stype];
            [sto setRecentSearches:[NSMutableArray array] forSearchType:stype];
            [sto setSearchType:stype];
            [searchTextObjs addObject:sto];
            [self setCurrentSearchText:sto];
                                        
            // add tab item
            NSTabViewItem *newItem = [[NSTabViewItem alloc] init];
            [newItem setLabel:[self computeTabTitle]];
            [newItem setView:[contentViewController view]];
            [tabView addTabViewItem:newItem];
            [tabView selectTabViewItem:newItem];

            [self setupContentRelatedViews];
            [self adaptAccessoryViewComponents];
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
        self.searchTextObjs = [decoder decodeObjectForKey:@"SearchTextObjects"];

        self.viewControllers = [decoder decodeObjectForKey:@"HostableViewControllerListEncoded"];
        for(ContentDisplayingViewController *vc in viewControllers) {
            [vc setDelegate:self];
            [vc setHostingDelegate:self];
            [vc adaptUIToHost];
        }

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

        // set tab labels
        for(int i = [viewControllers count]-1;i >= 0;--i) {
            ContentDisplayingViewController *vc = [viewControllers objectAtIndex:i];
            contentViewController = vc;
            if([vc viewLoaded]) {
                NSTabViewItem *item = [[tabView tabViewItems] objectAtIndex:i];
                [item setLabel:[self computeTabTitleForTabIndex:i]];
            }
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
