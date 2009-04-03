//
//  SingleViewHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 16.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SingleViewHostController.h"
#import "globals.h"
#import "MBPreferenceController.h"
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

@interface SingleViewHostController (/* */)

@end

@implementation SingleViewHostController

@synthesize contentViewController;

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -init] loading nib");        
    }
    
    return self;
}

- (id)initForViewType:(ModuleType)aType {
    self = [self init];
    if(self) {
        moduleType = aType;
        if(aType == bible) {
            contentViewController = [[BibleCombiViewController alloc] initWithDelegate:self];
            self.searchType = ReferenceSearchType;
        } else if(aType == commentary) {
            contentViewController = [[CommentaryViewController alloc] initWithDelegate:self];
            self.searchType = ReferenceSearchType;
        } else if(aType == dictionary) {
            contentViewController = [[DictionaryViewController alloc] initWithDelegate:self];
            self.searchType = ReferenceSearchType;        
        } else if(aType == genbook) {
            contentViewController = [[GenBookViewController alloc] initWithDelegate:self];
            self.searchType = IndexSearchType;        
        }
        
        // set hosting delegate
        [(HostableViewController *)contentViewController setHostingDelegate:self];

        // load nib
        BOOL stat = [NSBundle loadNibNamed:SINGLEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SingleViewHostController -init] unable to load nib!");
        }        
    }
    
    return self;
}

- (id)initWithModule:(SwordModule *)aModule {
    self = [self init];
    if(self) {
        moduleType = [aModule type];
        if(moduleType == bible) {
            contentViewController = [[BibleCombiViewController alloc] initWithDelegate:self andInitialModule:(SwordBible *)aModule];
            self.searchType = ReferenceSearchType;
        } else if(moduleType == commentary) {
            contentViewController = [[CommentaryViewController alloc] initWithModule:aModule delegate:self];
            self.searchType = ReferenceSearchType;
        } else if(moduleType == dictionary) {
            contentViewController = [[DictionaryViewController alloc] initWithModule:aModule delegate:self];
            self.searchType = ReferenceSearchType;
        } else if(moduleType == genbook) {
            contentViewController = [[GenBookViewController alloc] initWithModule:aModule delegate:self];
            self.searchType = IndexSearchType;
        }
        
        // set hosting delegate
        [(HostableViewController *)contentViewController setHostingDelegate:self];
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:SINGLEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SingleViewHostController -init] unable to load nib!");
        }        
    }
    
    return self;    
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -awakeFromNib]");
    
    [super awakeFromNib];
        
    // if a reference is stored, we should load it
    NSString *referenceText = [currentSearchText searchTextForType:ReferenceSearchType];
    if([referenceText length] > 0) {
        if([contentViewController isKindOfClass:[BibleCombiViewController class]]) {
            [(BibleCombiViewController *)contentViewController displayTextForReference:referenceText searchType:ReferenceSearchType];
        } else if([contentViewController isKindOfClass:[CommentaryViewController class]]) {
            [(CommentaryViewController *)contentViewController displayTextForReference:referenceText searchType:ReferenceSearchType];
        }
    }
    
    // This is the last selected search type and the text for it
    NSString *searchText = [currentSearchText searchTextForType:self.searchType];
    if([searchText length] > 0) {
        [searchTextField setStringValue:searchText];
        if([contentViewController isKindOfClass:[BibleCombiViewController class]]) {
            [(BibleCombiViewController *)contentViewController displayTextForReference:searchText searchType:self.searchType];
        } else if([contentViewController isKindOfClass:[CommentaryViewController class]]) {
            [(CommentaryViewController *)contentViewController displayTextForReference:searchText searchType:self.searchType];
        }
    }
    
    // set recent searche array
    [searchTextField setRecentSearches:[currentSearchText recentSearchsForType:self.searchType]];
    
    // check if view has loaded
    if(contentViewController.viewLoaded == YES) {
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
    
    // set font for bottombar segmented control
    [leftSideBottomSegControl setFont:FontStd];
    [rightSideBottomSegControl setFont:FontStd];

    switch(moduleType) {
        case bible:
            [[self window] setTitle:NSLocalizedString(@"Bible Window", @"")];
            break;
        case commentary:
            [[self window] setTitle:NSLocalizedString(@"Commentary Window", @"")];            
            break;
        case dictionary:
        case devotional:
            [[self window] setTitle:NSLocalizedString(@"Dictionary Window", @"")];
            break;
        case genbook:
            [[self window] setTitle:NSLocalizedString(@"Genbook Window", @"")];
            break;
    }    
}

#pragma mark - methods

/** sets the type of search to UI */
- (void)setSearchUIType:(SearchType)aType searchString:(NSString *)aString {
    [super setSearchUIType:aType searchString:aString];
    
    // accessorie view may change
    [rsbViewController setContentView:[(GenBookViewController *)contentViewController listContentView]];    
}

- (ModuleType)moduleType {
    ModuleType type = bible;
    
    if([contentViewController isKindOfClass:[CommentaryViewController class]]) {
        type = commentary;
    } else if([contentViewController isKindOfClass:[BibleCombiViewController class]]) {
        type = bible;
    } else if([contentViewController isKindOfClass:[DictionaryViewController class]]) {
        type = dictionary;
    } else if([contentViewController isKindOfClass:[GenBookViewController class]]) {
        type = genbook;
    }

    return type;
}

- (NSView *)view {
    return [(NSBox *)placeHolderView contentView];
}

- (void)setView:(NSView *)aView {
    [(NSBox *)placeHolderView setContentView:aView];
}

#pragma mark - toolbar actions

- (void)addBibleTB:(id)sender {
    if([contentViewController isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)contentViewController addNewBibleViewWithModule:nil];
    }
}

- (void)searchInput:(id)sender {
    MBLOGV(MBLOG_DEBUG, @"search input: %@", [sender stringValue]);
    
    [super searchInput:sender];
    
    NSString *searchText = [sender stringValue];
    [(<TextDisplayable>)contentViewController displayTextForReference:searchText searchType:self.searchType];
}

/*
- (void)showSearchOptionsView:(BOOL)flag {
    
    if(showingOptions != flag) {
        float fullHeight = [[[self window] contentView] frame].size.height;
        //float fullWidth = [[[self window] contentView] frame].size.width;

        // set frame size of placeholder box according to view
        searchOptionsView = [searchOptionsViewController optionsViewForSearchType:searchType];
        [placeHolderSearchOptionsView setContentView:searchOptionsView];
        NSSize viewSize = [searchOptionsViewController optionsViewSizeForSearchType:searchType];
        
        if(searchOptionsView != nil) {
            float margin = 25;
            float optionsBoxHeight = viewSize.height + 5;
            NSSize newSize = NSMakeSize([placeHolderSearchOptionsView frame].size.width, optionsBoxHeight);
            [placeHolderSearchOptionsView setFrameSize:newSize];
            //[searchOptionsView setFrameSize:NSMakeSize([placeHolderSearchOptionsView frame].size.width, viewSize.height)];
            
            // change sizes of views
            // calculate new size
            NSRect newUpperRect = [placeHolderSearchOptionsView frame];
            NSRect newLowerRect = [placeHolderView frame];
            // full height
            if(flag) {
                // lower
                newLowerRect.size.height = fullHeight - optionsBoxHeight - margin;
                // upper
                newUpperRect.size.height = optionsBoxHeight;
                newUpperRect.origin.y = fullHeight - optionsBoxHeight;
            } else {
                newLowerRect.size.height = fullHeight - margin;
                // upper
                newUpperRect.size.height = 0.0;
                newUpperRect.origin.y = fullHeight;
            }
            
            // set new sizes
            [placeHolderSearchOptionsView setFrame:newUpperRect];
            [placeHolderView setFrame:newLowerRect];
            
            // redisplay the whole view
            [placeHolderSearchOptionsView setHidden:!flag];
            [[[self window] contentView] setNeedsDisplay:YES];
        }
    }
}
*/

#pragma mark - Actions

- (IBAction)forceReload:(id)sender {
    [(ModuleCommonsViewController *)contentViewController setForceRedisplay:YES];
    [(ModuleCommonsViewController *)contentViewController displayTextForReference:[currentSearchText searchTextForType:[currentSearchText searchType]]];
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -contentViewInitFinished:]");
    
    // first let super class handle it's things
    [super contentViewInitFinished:aView];
    
    if([aView isKindOfClass:[ModuleViewController class]] || [aView isKindOfClass:[BibleCombiViewController class]]) {
        // all booktypes have something to show in the right side bar
        [rsbViewController setContentView:[(GenBookViewController *)aView listContentView]];
        if([aView isKindOfClass:[DictionaryViewController class]] ||
            [aView isKindOfClass:[GenBookViewController class]]) {
            [self showRightSideBar:YES];
        } else {
            [self showRightSideBar:[userDefaults boolForKey:DefaultsShowRSB]];                
        }
        // add the webview as contentvew to the placeholder
        [placeHolderView setContentView:[aView view]];
        [placeHolderSearchOptionsView setContentView:[(<TextDisplayable>)aView referenceOptionsView]];
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [super removeSubview:aViewController];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {        
        // decode contentViewController
        contentViewController = [decoder decodeObjectForKey:@"HostableViewControllerEncoded"];
        // set delegate
        [contentViewController setDelegate:self];
        [contentViewController setHostingDelegate:self];
        [contentViewController adaptUIToHost];
        
        // decode searchQuery
        self.currentSearchText = [decoder decodeObjectForKey:@"SearchTextObject"];

        if([contentViewController isKindOfClass:[BibleCombiViewController class]]) {
            moduleType = bible;
        } else {
            moduleType = [[(ModuleViewController *)contentViewController module] type];        
        }

        // load nib
        BOOL stat = [NSBundle loadNibNamed:SINGLEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SingleViewHostController -init] unable to load nib!");
        }

        // load the common things
        [super initWithCoder:decoder];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode hostableviewcontroller
    [encoder encodeObject:contentViewController forKey:@"HostableViewControllerEncoded"];
    
    [super encodeWithCoder:encoder];
}

@end
