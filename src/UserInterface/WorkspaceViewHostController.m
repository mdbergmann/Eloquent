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
- (void)rearrangeSegments;

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
    NSString *searchText = [currentSearchText searchTextForType:searchType];
    if([searchText length] > 0) {
        [searchTextField setStringValue:searchText];
        for(HostableViewController *vc in viewControllers) {
            if([vc isKindOfClass:[BibleCombiViewController class]]) {
                [(BibleCombiViewController *)vc displayTextForReference:searchText searchType:searchType];
            } else if([vc isKindOfClass:[CommentaryViewController class]]) {
                [(CommentaryViewController *)vc displayTextForReference:searchText searchType:searchType];
            }
        }
    }
    
    //[tabControl setHideForSingleTab:NO];
    //[tabControl setFont:FontStdBold];
    [tabControl setOrientation:PSMTabBarHorizontalOrientation];
    [tabControl setStyleNamed:@"Metal"];
//    [[tabControl addTabButton] setTarget:self];
//    [[tabControl addTabButton] setAction:@selector(addTab:)];
//    [tabControl setShowAddTabButton:YES];

    // remove all tabs
    for(NSTabViewItem *item in [tabView tabViewItems]) {
        [tabView removeTabViewItem:item];    
    }
    
    // re-set tabview items
    for(HostableViewController *vc in viewControllers) {
        if([vc viewLoaded]) {
            NSTabViewItem *item = [[NSTabViewItem alloc] init];
            [item setLabel:[vc label]];
            [item setView:[vc view]];
            [tabView addTabViewItem:item];
        }
    }
    
    // set font for bottombar segmented control
    [sideBarSegControl setFont:FontStd];
    
    // show left side bar
    [self showLeftSideBar:[userDefaults boolForKey:DefaultsShowLSB]];
    [self showRightSideBar:[userDefaults boolForKey:DefaultsShowRSB]];
    // in case this instance has been initialized with a coder we have view controllers
    // which may not necessarily call here if they have finished loading
    // we have to loop over the controllers and add segments for them
    [self rearrangeSegments];
    
    hostLoaded = YES;
}

#pragma mark - Methods

- (void)rearrangeSegments {
    
    /*
    int i = 0;
    NSTabViewItem *item = nil;
    for(NSTabViewItem *item in [tabView tabViewItems]) {
        [item setLabel:[vc label]];
        
        // set active controller
        activeViewController = vc;
        
        // set current search text object
        [self setCurrentSearchText:[searchTextObjs objectAtIndex:[viewControllers indexOfObject:vc]]];
        // set text according search type
        [searchTextField setStringValue:[currentSearchText searchTextForType:searchType]];
        // switch recentSearches
        [searchTextField setRecentSearches:[currentSearchText recentSearchsForType:searchType]];    
    }
    
    // select the last tabview item
    if(item != nil) {
        [tabView selectTabViewItem:item];
    }
    
    // for dictionaries and genbooks we show the content as another switchable view in the left side bar
    if([activeViewController isKindOfClass:[DictionaryViewController class]] ||
       [activeViewController isKindOfClass:[GenBookViewController class]]) {
        [rsbViewController setContentView:[(GenBookViewController *)activeViewController listContentView]];
        [self showRightSideBar:YES];
    } else {
        [self showRightSideBar:[userDefaults boolForKey:DefaultsShowRSB]];                
    }
     */
}

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

- (void)addTabContentForModule:(SwordModule *)aModule {

    if(aModule != nil) {
        HostableViewController *vc = nil;
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
        
        // add view controller
        [viewControllers addObject:vc];
        // make the last added the active one
        activeViewController = vc;
    }
}

- (void)addTabContentForModuleType:(ModuleType)aType {
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
    
    // add view controller
    [viewControllers addObject:vc];
    // make the last added the active one
    activeViewController = vc;
    
    // search text objects are added when this view reports it has loaded
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
    
    if([activeViewController isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)activeViewController displayTextForReference:searchText searchType:searchType];
    } else if([activeViewController isKindOfClass:[CommentaryViewController class]]) {
        [(CommentaryViewController *)activeViewController displayTextForReference:searchText searchType:searchType];
    } else if([activeViewController isKindOfClass:[DictionaryViewController class]]) {
        [(DictionaryViewController *)activeViewController displayTextForReference:searchText searchType:searchType];
    } else if([activeViewController isKindOfClass:[GenBookViewController class]]) {
        [(GenBookViewController *)activeViewController displayTextForReference:searchText searchType:searchType];
    }
}

#pragma mark - Actions

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
                // now rearrange the segments
                [self rearrangeSegments];
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
                    // now rearrange the segments
                    [self rearrangeSegments];
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
    int index = [[aTabView tabViewItems] indexOfObject:tabViewItem];
    HostableViewController *vc = [viewControllers objectAtIndex:index];
    
    // found view controller?
    if(vc != nil) {
        // also remove search text obj
        [searchTextObjs removeObjectAtIndex:index];
        // remove this view controller from our list
        [viewControllers removeObject:vc];
        // now rearrange the segments
        [self rearrangeSegments];
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
        int index = [[aTabView tabViewItems] indexOfObject:tabViewItem];
        HostableViewController *vc = [viewControllers objectAtIndex:index];
        // set active view controller
        activeViewController = vc;
        
        // for GenBook and Dictionary view controller we set the content to the left side bar
        if([vc isKindOfClass:[DictionaryViewController class]] ||
           [vc isKindOfClass:[GenBookViewController class]]) {
            [rsbViewController setContentView:[(GenBookViewController *)vc listContentView]];
            [self showRightSideBar:YES];
        } else {
            [self showRightSideBar:[userDefaults boolForKey:DefaultsShowRSB]];                
        }
        
        // also set current search Text
        [self setCurrentSearchText:[searchTextObjs objectAtIndex:index]];
        
        // set text according search type
        [searchTextField setStringValue:[currentSearchText searchTextForType:searchType]];
        // switch recentSearches
        [searchTextField setRecentSearches:[currentSearchText recentSearchsForType:searchType]];
        
        // tell host to adapt ui
        [self adaptUIToCurrentlyDisplayingModuleType];        
    }
}

- (void)addTab:(id)sender {
    NSTabViewItem *newItem = [[NSTabViewItem alloc] init];
    [newItem setLabel:@"test"];
    //[newItem setView:[aViewController view]];
    [tabView addTabViewItem:newItem];
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aViewController {    
    MBLOG(MBLOG_DEBUG, @"[WorkspaceViewHostController -contentViewInitFinished:]");
    
    // let super class first handle it's things
    [super contentViewInitFinished:aViewController];
    
    // we are only interessted in view controllers that show information
    if([aViewController isKindOfClass:[ModuleViewController class]] ||
        [aViewController isKindOfClass:[BibleCombiViewController class]]) { // this also handles commentary view
        
        NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:[[FakeModel alloc] init]];
        [newItem setLabel:[aViewController label]];
        [newItem setView:[aViewController view]];
        [tabView addTabViewItem:newItem];
        //[tabView selectTabViewItem:newItem]; // this is optional, but expected behavior        
        
        // extend searchTexts
        SearchTextObject *sto = [[SearchTextObject alloc] init];
        [searchTextObjs addObject:sto];
        // also set current search Text
        [self setCurrentSearchText:sto];
        // set text according search type
        [searchTextField setStringValue:[currentSearchText searchTextForType:searchType]];
        // switch recentSearches
        [searchTextField setRecentSearches:[currentSearchText recentSearchsForType:searchType]];    
        
        // set active controller
        activeViewController = aViewController;

        // for GenBook and Dictionary view controller we set the content to the left side bar
        if([aViewController isKindOfClass:[DictionaryViewController class]] ||
           [aViewController isKindOfClass:[GenBookViewController class]]) {
            [rsbViewController setContentView:[(GenBookViewController *)aViewController listContentView]];
            [self showRightSideBar:YES];
        } else {
            [self showRightSideBar:[userDefaults boolForKey:DefaultsShowRSB]];                
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
        
        // load the common things
        [super initWithCoder:decoder];
        
        // decode viewControllers
        self.viewControllers = [decoder decodeObjectForKey:@"HostableViewControllerListEncoded"];
        // set delegate
        for(HostableViewController *vc in viewControllers) {
            [vc setDelegate:self];
        }

        // decode search texts
        self.searchTextObjs = [decoder decodeObjectForKey:@"SearchTextObjects"];
        
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
