//
//  SingleViewHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 16.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SingleViewHostController.h"
#import "BibleCombiViewController.h"
#import "CommentaryViewController.h"
#import "DictionaryViewController.h"
#import "GenBookViewController.h"
#import "HostableViewController.h"
#import "BibleSearchOptionsViewController.h"
#import "LeftSideBarViewController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SearchTextObject.h"

@interface SingleViewHostController (/* */)

@end

@implementation SingleViewHostController

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -init] loading nib");
        
        // load leftSideBar
        lsbViewController = [[LeftSideBarViewController alloc] initWithDelegate:self];
        showingLSB = NO;
    }
    
    return self;
}

- (id)initForViewType:(ModuleType)aType {
    self = [self init];
    if(self) {
        moduleType = aType;
        if(aType == bible) {
            viewController = [[BibleCombiViewController alloc] initWithDelegate:self];
            searchType = ReferenceSearchType;
        } else if(aType == commentary) {
            viewController = [[CommentaryViewController alloc] initWithDelegate:self];
            searchType = ReferenceSearchType;
        } else if(aType == dictionary) {
            viewController = [[DictionaryViewController alloc] initWithDelegate:self];
            searchType = ReferenceSearchType;        
        } else if(aType == genbook) {
            viewController = [[GenBookViewController alloc] initWithDelegate:self];
            searchType = IndexSearchType;        
        }
        
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
            viewController = [[BibleCombiViewController alloc] initWithDelegate:self andInitialModule:(SwordBible *)aModule];
            searchType = ReferenceSearchType;
        } else if(moduleType == commentary) {
            viewController = [[CommentaryViewController alloc] initWithModule:aModule delegate:self];
            searchType = ReferenceSearchType;
        } else if(moduleType == dictionary) {
            viewController = [[DictionaryViewController alloc] initWithModule:aModule delegate:self];
            searchType = ReferenceSearchType;
        } else if(moduleType == genbook) {
            viewController = [[GenBookViewController alloc] initWithModule:aModule delegate:self];
            searchType = ReferenceSearchType;
        }
        
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
    
    // check if view has loaded
    if(viewController.viewLoaded == YES) {
        // add content view
        [(NSBox *)placeHolderView setContentView:[viewController view]];
    }
    
    // if a reference is stored, we should load it
    NSString *referenceText = [currentSearchText searchTextForType:ReferenceSearchType];
    if([referenceText length] > 0) {
        if([viewController isKindOfClass:[BibleCombiViewController class]]) {
            [(BibleCombiViewController *)viewController displayTextForReference:referenceText searchType:ReferenceSearchType];
        } else if([viewController isKindOfClass:[CommentaryViewController class]]) {
            [(CommentaryViewController *)viewController displayTextForReference:referenceText searchType:ReferenceSearchType];
        }
    }
    
    // This is the last selected search type and the text for it
    NSString *searchText = [currentSearchText searchTextForType:searchType];
    if([searchText length] > 0) {
        [searchTextField setStringValue:searchText];
        if([viewController isKindOfClass:[BibleCombiViewController class]]) {
            [(BibleCombiViewController *)viewController displayTextForReference:searchText searchType:searchType];
        } else if([viewController isKindOfClass:[CommentaryViewController class]]) {
            [(CommentaryViewController *)viewController displayTextForReference:searchText searchType:searchType];
        }
    }
    
    // set recent searche array
    [searchTextField setRecentSearches:[currentSearchText recentSearchsForType:searchType]];
}

#pragma mark - methods

- (ModuleType)moduleType {
    ModuleType type = bible;
    
    if([viewController isKindOfClass:[CommentaryViewController class]]) {
        type = commentary;
    } else if([viewController isKindOfClass:[BibleCombiViewController class]]) {
        type = bible;
    } else if([viewController isKindOfClass:[DictionaryViewController class]]) {
        type = dictionary;
    } else if([viewController isKindOfClass:[GenBookViewController class]]) {
        type = genbook;
    }
    
    return type;
}

- (HostableViewController *)contentViewController {
    return viewController;
}

- (NSView *)view {
    return [(NSBox *)placeHolderView contentView];
}

- (void)setView:(NSView *)aView {
    [(NSBox *)placeHolderView setContentView:aView];
}

#pragma mark - toolbar actions

- (void)addBibleTB:(id)sender {
    if([viewController isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)viewController addNewBibleViewWithModule:nil];
    }
}

- (void)searchInput:(id)sender {
    MBLOGV(MBLOG_DEBUG, @"search input: %@", [sender stringValue]);
    
    [super searchInput:sender];
    
    NSString *searchText = [sender stringValue];
    
    if([viewController isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)viewController displayTextForReference:searchText searchType:searchType];
    } else if([viewController isKindOfClass:[CommentaryViewController class]]) {
        [(CommentaryViewController *)viewController displayTextForReference:searchText searchType:searchType];
    } else if([viewController isKindOfClass:[DictionaryViewController class]]) {
        [(DictionaryViewController *)viewController displayTextForReference:searchText searchType:searchType];
    } else if([viewController isKindOfClass:[GenBookViewController class]]) {
        [(GenBookViewController *)viewController displayTextForReference:searchText searchType:searchType];
    }
}

- (void)toggleModulesTB:(id)sender {
    NSView *view = [lsbViewController view];
    if(showingLSB) {
        // remove
        [[view animator] removeFromSuperview];
        showingLSB = NO;
    } else {
        // add
        [splitView addSubview:view positioned:NSWindowBelow relativeTo:defaultView];        
        showingLSB = YES;
    }
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

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {    
    MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -contentViewInitFinished:]");
    
    if([aView isKindOfClass:[ModuleViewController class]]) {
        // add the webview as contentvew to the placeholder
        [(NSBox *)placeHolderView setContentView:[aView view]];    
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [[aViewController view] removeFromSuperview];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {

        // load the common things
        [super initWithCoder:decoder];
        
        // decode viewController
        viewController = [decoder decodeObjectForKey:@"HostableViewControllerEncoded"];
        // set delegate
        [viewController setDelegate:self];

        // load lsb view
        lsbViewController = [[LeftSideBarViewController alloc] initWithDelegate:self];
        showingLSB = NO;
                
        // load nib
        BOOL stat = [NSBundle loadNibNamed:SINGLEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SingleViewHostController -init] unable to load nib!");
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
    [encoder encodeObject:viewController forKey:@"HostableViewControllerEncoded"];
    
    [super encodeWithCoder:encoder];
}

@end
