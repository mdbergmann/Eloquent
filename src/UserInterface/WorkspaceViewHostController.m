//
//  WorkspaceViewHostController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 06.11.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WorkspaceViewHostController.h"
#import "AppController.h"
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
        MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -init] loading nib");
        
        // load leftSideBar
        lsbViewController = [[LeftSideBarViewController alloc] initWithDelegate:self];
        showingLSB = NO;

        // init view controller array
        [self setViewControllers:[NSMutableArray array]];
        // init search texts
        [self setSearchTextObjs:[NSMutableArray array]];
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:WORKSPACEVIEWHOST_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[SingleViewHostController -init] unable to load nib!");
        }        
    }
    
    return self;
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[SingleViewHostController -awakeFromNib]");
    
    // super class has some things to set
    [super awakeFromNib];

    // in case this instance has been initialized with a coder we have view controllers
    // which may not necessarily call here if they have finished loading
    // we have to loop over the controllers and add segments for them
    [self rearrangeSegments];    
    
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
    
    // show left side bar
    [self toggleModulesTB:self];
}

#pragma mark - Methods

- (void)rearrangeSegments {
    
    // set segments to 0
    [tabControl setSegmentCount:0];    

    for(HostableViewController *vc in viewControllers) {
        if([vc viewLoaded]) {
            // add segment to control and set this as current view
            [tabControl setSegmentCount:[tabControl segmentCount]+1];
            [[tabControl cell] setTag:[vc hash] forSegment:[tabControl segmentCount]-1];
            [tabControl setLabel:[self tabViewItemLabelForText:[vc label]] forSegment:[tabControl segmentCount]-1];
            [tabControl setSelected:YES forSegment:[tabControl segmentCount]-1];
            NSMenu *menu = [segmentMenu copy];
            [[tabControl cell] setMenu:menu forSegment:[tabControl segmentCount]-1];
            [tabControl setTarget:self];
            [tabControl sizeToFit];
            [tabControl setHidden:NO];
            [tabControl setNeedsDisplay:YES];

            // add view
            [self setView:[vc view]];
            // set active controller
            activeViewController = vc;
            
            // set current search text object
            [self setCurrentSearchText:[searchTextObjs objectAtIndex:[viewControllers indexOfObject:vc]]];
            // set text according search type
            [searchTextField setStringValue:[currentSearchText searchTextForType:searchType]];
            // switch recentSearches
            [searchTextField setRecentSearches:[currentSearchText recentSearchsForType:searchType]];    
        }
    }    
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
            vc = [[CommentaryViewController alloc] initWithDelegate:self];
            [(CommentaryViewController *)vc setModule:aModule];
        } else if(moduleType == dictionary) {
            vc = [[DictionaryViewController alloc] initWithDelegate:self];
            [(DictionaryViewController *)vc setModule:aModule];
        } else if(moduleType == genbook) {
            vc = [[GenBookViewController alloc] initWithDelegate:self];
            [(GenBookViewController *)vc setModule:aModule];
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
    return [NSString stringWithFormat:@"%@ - %i", aText, [tabControl segmentCount]];
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

#pragma mark - Actions

- (IBAction)segmentButtonChange:(id)sender {
    // get tag
    int sel = [(NSSegmentedControl *)sender selectedSegment];
    HostableViewController *vc = [viewControllers objectAtIndex:sel];
    [self setView:[vc view]];
    activeViewController = vc;
    
    // also set current search Text
    [self setCurrentSearchText:[searchTextObjs objectAtIndex:sel]];
    
    // set text according search type
    [searchTextField setStringValue:[currentSearchText searchTextForType:searchType]];
    // switch recentSearches
    [searchTextField setRecentSearches:[currentSearchText recentSearchsForType:searchType]];    
}

- (IBAction)menuItemSelected:(id)sender {
    int tag = [(NSMenuItem *)sender tag];
    
    NSMenuItem *mitem = sender;
    // every segment has it's own copy of the menu which we will find now here
    // to identify the viewController
    int selSeg = -1;
    for(int i = 0;i < [tabControl segmentCount];i++) {
        NSMenu *m = [tabControl menuForSegment:i];
        if(m == [mitem menu]) {
            // get the tag of this segment
            selSeg = [[tabControl cell] tagForSegment:i];
            break;
        }
    }
    
    // this is the controller of the view which segment has been selected for menu
    HostableViewController *vc = nil;
    if(selSeg > -1) {
        for(HostableViewController *c in viewControllers) {
            int hash = [c hash];
            if(hash == selSeg) {
                vc = c;
                break;
            }
        }        
    }
    
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
                    int index = [viewControllers indexOfObject:vc];
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

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aViewController {    
    MBLOG(MBLOG_DEBUG, @"[WorkspaceViewHostController -contentViewInitFinished:]");
    
    // we are only interessted in view controllers that show information
    if([aViewController isKindOfClass:[ModuleViewController class]] ||
        [aViewController isKindOfClass:[BibleCombiViewController class]]) {
        
        // add segment to control and set this as current view
        [tabControl setSegmentCount:[tabControl segmentCount]+1];
        [[tabControl cell] setTag:[aViewController hash] forSegment:[tabControl segmentCount]-1];
        [tabControl setLabel:[self tabViewItemLabelForText:[aViewController label]] forSegment:[tabControl segmentCount]-1];
        [tabControl setSelected:YES forSegment:[tabControl segmentCount]-1];
        [[tabControl cell] setMenu:[segmentMenu copy] forSegment:[tabControl segmentCount]-1];
        [tabControl sizeToFit];
        [tabControl setHidden:NO];
        [tabControl setNeedsDisplay:YES];
        
        // extend searchTexts
        SearchTextObject *sto = [[SearchTextObject alloc] init];
        [searchTextObjs addObject:sto];
        // also set current search Text
        [self setCurrentSearchText:sto];
        // set text according search type
        [searchTextField setStringValue:[currentSearchText searchTextForType:searchType]];
        // switch recentSearches
        [searchTextField setRecentSearches:[currentSearchText recentSearchsForType:searchType]];    
        
        // add view
        [self setView:[aViewController view]];
        // set active controller
        activeViewController = aViewController;
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    [[aViewController view] removeFromSuperview];
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
        
        // load lsb view
        lsbViewController = [[LeftSideBarViewController alloc] initWithDelegate:self];
        showingLSB = NO;
        
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
