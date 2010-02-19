//
//  BibleCombiViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BibleCombiViewController.h"
#import "WorkspaceViewHostController.h"
#import "MBPreferenceController.h"
#import "BibleViewController.h"
#import "CommentaryViewController.h"
#import "ScrollSynchronizableView.h"
#import "WindowHostController.h"
#import "SwordManager.h"
#import "SwordSearching.h"
#import "ReferenceCacheManager.h"
#import "NSButton+Color.h"
#import "globals.h"
#import "ProgressOverlayViewController.h"
#import "SearchBookSet.h"
#import "SearchBookSetEditorController.h"
#import "BibleCombiViewController+ViewSynchronisation.h"

@interface BibleCombiViewController ()

@property(readwrite, retain) NSMutableArray *parBibleViewControllers;
@property(readwrite, retain) NSMutableArray *parMiscViewControllers;

- (void)distributeReference:(NSString *)aRef;
- (void)tileSubViews;

@end

@implementation BibleCombiViewController

#pragma mark - properties

@synthesize parBibleViewControllers;
@synthesize parMiscViewControllers;

#pragma mark - initialization

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
    return [self initWithDelegate:aDelegate andInitialModule:nil];
}

- (id)initWithDelegate:(id)aDelegate andInitialModule:(SwordBible *)aBible {
    self = [super init];
    if(self) {
        self.delegate = aDelegate;
        searchType = ReferenceSearchType;
        progressControl = NO;
        
        [self initDefaultModDisplayOptions];
        [self initDefaultDisplayOptions];
        
        self.parBibleViewControllers = [NSMutableArray array];
        self.parMiscViewControllers = [NSMutableArray array];
        
        [self addNewBibleViewWithModule:aBible];

        regex = [[MBRegex alloc] initWithPattern:@".*\"sword://.+\/.+\/\\d+\/\\d+\".*"];
        if([regex errorCodeOfLastAction] != MBRegexSuccess) {
            MBLOGV(MBLOG_ERR, @"error creating regex: %@", [regex errorMessageOfLastAction]);
        }

        BOOL stat = [NSBundle loadNibNamed:BIBLECOMBIVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BibleCombiViewController -init] unable to load nib!");
        }
    }
    
    return self;    
}

- (void)awakeFromNib {
    progressStartedCounter = 0;
        
    [super awakeFromNib];

    defaultMiscViewHeight = 60;
    [horiSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    
    [[displayOptionsMenu itemWithTag:1] setState:[[displayOptions objectForKey:DefaultsBibleTextVersesOnOneLineKey] intValue]];
    
    [parBibleSplitView setVertical:YES];
    [parBibleSplitView setDividerStyle:NSSplitViewDividerStyleThin];

    [parMiscSplitView setVertical:YES];
    [parMiscSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    
    [horiSplitView addSubview:parBibleSplitView positioned:NSWindowAbove relativeTo:nil];
    if([parMiscViewControllers count] > 0) {
        [horiSplitView addSubview:parMiscSplitView positioned:NSWindowAbove relativeTo:nil];
    }
    
    BOOL loaded = YES;
    for(HostableViewController *hc in parBibleViewControllers) {
        if(hc.viewLoaded == NO) {
            loaded = NO;
        } else {
            [parBibleSplitView addSubview:[hc view] positioned:NSWindowAbove relativeTo:nil];        
            [self tileSubViews];
        }
    }
    for(HostableViewController *hc in parMiscViewControllers) {
        if(hc.viewLoaded == NO) {
            loaded = NO;
        } else {
            // add the webview as contentvew to the placeholder
            [parMiscSplitView addSubview:[hc view] positioned:NSWindowAbove relativeTo:nil];        
        }
    }
    
    if(loaded) {
        [self reportLoadingComplete];
    }

    viewLoaded = YES;
}

#pragma mark - Methods

- (NSString *)label {
    return @"BibleView";
}

/** we override this in order to be able to set it to all sub views */
- (void)setHostingDelegate:(id)aDelegate {
    [super setHostingDelegate:aDelegate];
    
    for(HostableViewController *hc in parBibleViewControllers) {
        [hc setHostingDelegate:hostingDelegate];
    }
    for(HostableViewController *hc in parMiscViewControllers) {
        [hc setHostingDelegate:hostingDelegate];
    }    
}

/**
 Creates a new parallel bible view and presets the given bible module.
 If nil is given, the first module found is taken.
 */
- (void)addNewBibleViewWithModule:(SwordBible *)aModule {
    // if given module is nil, choose the first found in SwordManager
    if(aModule == nil) {
        NSArray *modArray = [[SwordManager defaultManager] modulesForType:SWMOD_CATEGORY_BIBLES];
        if([modArray count] > 0) {
            aModule = [modArray objectAtIndex:0];
        }
    }
    
    // after loading this combi view there is only one bibleview, nothing more
    BibleViewController *bvc = [[BibleViewController alloc] initWithModule:aModule delegate:self];
    [bvc setHostingDelegate:delegate];
    [parBibleViewControllers addObject:bvc];
    [self tileSubViews];
    
    for(HostableViewController *hc in parBibleViewControllers) {
        [hc adaptUIToHost];
    }
    
    if(hostingDelegate) {
        [bvc displayTextForReference:[(WindowHostController *)hostingDelegate searchText] searchType:searchType];
    }
}

/**
 Creates a new parallel commentary view and presets the given commentary module.
 If nil is given, the first module found is taken.
 */
- (void)addNewCommentViewWithModule:(SwordCommentary *)aModule {
    // if given module is nil, choose the first found in SwordManager
    if(aModule == nil) {
        NSArray *modArray = [[SwordManager defaultManager] modulesForType:SWMOD_CATEGORY_COMMENTARIES];
        if([modArray count] > 0) {
            aModule = [modArray objectAtIndex:0];
        }
    }
    
    CommentaryViewController *cvc = [[CommentaryViewController alloc] initWithModule:(SwordBible *)aModule delegate:self];
    [cvc setHostingDelegate:delegate];
    
    if([parMiscViewControllers count] == 0) {
        [horiSplitView addSubview:parMiscSplitView positioned:NSWindowAbove relativeTo:nil];        
    }
    
    [parMiscViewControllers addObject:cvc];

    for(HostableViewController *hc in parMiscViewControllers) {
        [hc adaptUIToHost];
    }

    if(hostingDelegate) {
        [cvc displayTextForReference:[(WindowHostController *)hostingDelegate searchText] searchType:searchType];
    }
}

- (void)distributeReference:(NSString *)aRef {
    int i = 0;
    for(BibleViewController *bvc in parBibleViewControllers) {
        if(i > 0) {
            // the first did it. that applies to all the others
            [bvc setPerformProgressCalculation:NO];
        }
        if(customFontSize > 0) {
            [bvc setCustomFontSize:customFontSize];
        }
        [bvc setSearchType:searchType];
        [bvc setForceRedisplay:forceRedisplay];
        [bvc setDisplayOptions:displayOptions];
        [bvc setModDisplayOptions:modDisplayOptions];
        [bvc displayTextForReference:aRef searchType:searchType];
        
        i++;
    }
    
    for(CommentaryViewController *cvc in parMiscViewControllers) {
        if(customFontSize > 0) {
            [cvc setCustomFontSize:customFontSize];
        }
        [cvc setSearchType:searchType];
        [cvc setForceRedisplay:forceRedisplay];
        [cvc setDisplayOptions:displayOptions];
        [cvc setModDisplayOptions:modDisplayOptions];
        [cvc displayTextForReference:aRef searchType:searchType];
    }
}

- (void)tileSubViews {
    if(viewLoaded) {
        // what we also do here is recalculate the view size so all
        // views have the same size
        NSRect contentRect = [[self view] frame];
        int width = contentRect.size.width;
        int subViews = [[parBibleSplitView subviews] count];
        int subViewWidth = width;
        if(subViews > 0) {
            subViewWidth = (int)width/subViews;
        }
        
        NSEnumerator *iter = [[parBibleSplitView subviews] reverseObjectEnumerator];
        ScrollSynchronizableView *v = nil;
        BOOL haveRight = NO;
        while((v = [iter nextObject])) {
            // get scrollView
            NSScrollView *sView = v.syncScrollView;
            
            // set new width
            NSSize newSize = [v frame].size;
            newSize.width = subViewWidth;
            [v setFrameSize:newSize];
            
            if(haveRight == NO) {
                // have the most right one
                haveRight = YES;
                // this one shows vertical scrollbar
                [sView setHasVerticalScroller:YES];
            } else {
                // all others do not have vertical scrollers but are synchronized
                [sView setHasVerticalScroller:NO];
            }
            
            // tell scrollview to post bounds notifications
            [sView setPostsBoundsChangedNotifications:NO];
        }
    }
}

- (NSNumber *)bibleViewCount {
    return [NSNumber numberWithInt:[parBibleViewControllers count]];
}

- (NSArray *)openBibleModules {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[parBibleViewControllers count]];
    
    for(BibleViewController *vc in parBibleViewControllers) {
        [ret addObject:[vc module]];
    }
    
    return ret;
}

- (NSArray *)openMiscModules {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[parMiscViewControllers count]];
    
    for(ModuleViewController *vc in parMiscViewControllers) {
        [ret addObject:[vc module]];
    }
    
    return ret;
}

#pragma mark - AccessoryViewDisplaying

- (NSView *)rightAccessoryView {
    NSView *ret = nil;
    
    if([parBibleViewControllers count] > 0) {
        ret = [(<AccessoryViewProviding>)[parBibleViewControllers objectAtIndex:0] rightAccessoryView];
    }
    
    return ret;
}

- (NSView *)topAccessoryView {
    return referenceOptionsView;
}

- (BOOL)showsRightSideBar {
    if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
        return [userDefaults boolForKey:DefaultsShowRSBWorkspace];
    } else {
        return [userDefaults boolForKey:DefaultsShowRSBSingle];        
    }
}

#pragma mark - ModuleProviding

- (SwordModule *)module {
    if([parBibleViewControllers count] > 0) {
        return [(ModuleViewController *)[parBibleViewControllers objectAtIndex:0] module];
    }
    
    return nil;
}

#pragma mark - ContentSaving

- (BOOL)hasUnsavedContent {
    for(ContentDisplayingViewController *vc in parMiscViewControllers) {
        if([vc hasUnsavedContent]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)saveContent {
    for(ContentDisplayingViewController *vc in parMiscViewControllers) {
        if([vc hasUnsavedContent]) {
            [vc saveContent];
        }
    }
}

#pragma mark - Printing

- (NSView *)printViewForInfo:(NSPrintInfo *)printInfo {
    NSSize paperSize = [printInfo paperSize];
    
    NSSize printSize = NSMakeSize(paperSize.width - ([printInfo leftMargin] + [printInfo rightMargin]), 
                                  paperSize.height - ([printInfo topMargin] + [printInfo bottomMargin]));

    NSTextView *printView = [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, printSize.width, printSize.height)];

    if([parBibleViewControllers count] > 0) {
        [printView insertText:[[(ModuleViewController *)[parBibleViewControllers objectAtIndex:0] textView] attributedString]];
    }
    
    return printView;
}

#pragma mark - Menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    BOOL ret = NO;
    
    if([menuItem menu] == modDisplayOptionsMenu) {
        NSMutableArray *modCs = [NSMutableArray arrayWithArray:parBibleViewControllers];
        [modCs addObjectsFromArray:parMiscViewControllers];

        switch([menuItem tag]) {
            case 1:
            {
                for(ModuleViewController *modC in modCs) {
                    SwordModule *mod = [modC module];
                    if([mod hasFeature:SWMOD_FEATURE_STRONGS]) {
                        ret = YES;
                        break;
                    }
                }
                break;
            }
            case 2:
            {
                for(ModuleViewController *modC in modCs) {
                    SwordModule *mod = [modC module];
                    if([mod hasFeature:SWMOD_FEATURE_MORPH]) {
                        ret = YES;
                        break;
                    }
                }
                break;
            }
            case 3:
            {
                for(ModuleViewController *modC in modCs) {
                    SwordModule *mod = [modC module];
                    if([mod hasFeature:SWMOD_FEATURE_FOOTNOTES]) {
                        ret = YES;
                        break;
                    }
                }
                break;
            }
            case 4:
            {
                for(ModuleViewController *modC in modCs) {
                    SwordModule *mod = [modC module];
                    if([mod hasFeature:SWMOD_FEATURE_SCRIPTREF]) {
                        ret = YES;
                        break;
                    }
                }
                break;
            }
            case 5:
            {
                for(ModuleViewController *modC in modCs) {
                    SwordModule *mod = [modC module];
                    if([mod hasFeature:SWMOD_FEATURE_REDLETTERWORDS]) {
                        ret = YES;
                        break;
                    }
                }
                break;
            }
            case 6:
            {
                for(ModuleViewController *modC in modCs) {
                    SwordModule *mod = [modC module];
                    if([mod hasFeature:SWMOD_FEATURE_HEADINGS]) {
                        ret = YES;
                        break;
                    }
                }
                break;
            }
            case 7:
            {
                for(ModuleViewController *modC in modCs) {
                    SwordModule *mod = [modC module];
                    if([mod hasFeature:SWMOD_FEATURE_HEBREWPOINTS]) {
                        ret = YES;
                        break;
                    }
                }
                break;
            }
            case 8:
            {
                for(ModuleViewController *modC in modCs) {
                    SwordModule *mod = [modC module];
                    if([mod hasFeature:SWMOD_FEATURE_CANTILLATION]) {
                        ret = YES;
                        break;
                    }
                }
                break;
            }
            case 9:
            {
                for(ModuleViewController *modC in modCs) {
                    SwordModule *mod = [modC module];
                    if([mod hasFeature:SWMOD_FEATURE_GREEKACCENTS]) {
                        ret = YES;
                        break;
                    }
                }
                break;
            }
        }
    } else if([menuItem menu] == displayOptionsMenu) {
        if([menuItem action] == @selector(displayOptionShowVerseNumberOnly:)) {
            if([[displayOptions objectForKey:DefaultsBibleTextVersesOnOneLineKey] boolValue]) {
                ret = YES;
            }
        } else {
            ret = YES;        
        }
    } else {
        ret = YES;
    }
    
    return ret;
}

#pragma mark - Actions

- (IBAction)textContextChange:(id)sender {
    [super textContextChange:sender];

    int tag = [(NSPopUpButton *)sender selectedTag];    
    for(BibleViewController *bv in parBibleViewControllers) {
        [bv setTextContext:tag];
    }
    
    forceRedisplay = YES;
    [self displayTextForReference:reference];
}

#pragma mark - SearchBookSetEditorController delegate methods

- (void)indexBookSetChanged:(id)sender {
    // if one of the subviews sends this message, set the selected book set for all view bible and commentary controllers
    SearchBookSetEditorController *bsc = [(BibleViewController *)sender searchBookSetsController];
    SearchBookSet *bookSet = [bsc selectedBookSet];
    for(BibleViewController *bc in parBibleViewControllers) {
        [[bc searchBookSetsController] setSelectedBookSet:bookSet];
    }
    for(HostableViewController *vc in parMiscViewControllers) {
        if([vc isKindOfClass:[BibleViewController class]]) {
            [[(BibleViewController *)vc searchBookSetsController] setSelectedBookSet:bookSet];        
        }
    }
}

#pragma mark - ProgressIndicating

- (void)beginIndicateProgress {
    if(viewLoaded) {
        ProgressOverlayViewController *pc = [ProgressOverlayViewController defaultController];
        if(![[[self view] subviews] containsObject:[pc view]]) {
            // we need the same size
            [[pc view] setFrame:[[self view] frame]];        
            [pc startProgressAnimation];
            [[self view] addSubview:[pc view]];
            [[[self view] superview] setNeedsDisplay:YES];
        }
        
        progressStartedCounter++;        
    }
}

- (void)endIndicateProgress {
    if(viewLoaded) {
        if(progressStartedCounter > 0) {
            --progressStartedCounter;
        }
        
        // subviews create the progress indicator view but shouldn't be able to remove it if we distribute a new reference ourselfs
        if(progressControl == NO) {
            if(progressStartedCounter == 0) {
                ProgressOverlayViewController *pc = [ProgressOverlayViewController defaultController];
                [pc stopProgressAnimation];
                if([[[self view] subviews] containsObject:[pc view]]) {
                    [[pc view] removeFromSuperview];
                }            
            }
        }        
    }    
}

#pragma mark - SubviewHosting

- (void)contentViewInitFinished:(HostableViewController *)aView {
    NSView *view = nil;
    
    if(viewLoaded) {
        BOOL loaded = YES;
        if([aView isKindOfClass:[BibleViewController class]]) {

            if([aView isKindOfClass:[CommentaryViewController class]]) {
                // add the webview as contentview to the placeholder
                [parMiscSplitView addSubview:[aView view] positioned:NSWindowAbove relativeTo:view];        
                
                for(HostableViewController *hc in parMiscViewControllers) {
                    if(hc.viewLoaded == NO) {
                        loaded = NO;
                    }
                }
            } else {
                // add the webview as contentview to the placeholder
                [parBibleSplitView addSubview:[aView view] positioned:NSWindowAbove relativeTo:view];
                
                [self tileSubViews];
                
                for(HostableViewController *hc in parBibleViewControllers) {
                    if(hc.viewLoaded == NO) {
                        loaded = NO;
                    }
                }
            }
        }
                
        if(loaded) {
            [self reportLoadingComplete];
        }
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    // remove the view of the send controller from our hosts
    NSView *view = [aViewController view];
    [view removeFromSuperview];
    
    if([aViewController isKindOfClass:[CommentaryViewController class]]) {
        // remove controller
        [parMiscViewControllers removeObject:aViewController];
        if([parMiscViewControllers count] == 0) {
            [parMiscSplitView removeFromSuperview];
        }
    } else if([aViewController isKindOfClass:[BibleViewController class]]) {
        // remove controller
        [parBibleViewControllers removeObject:aViewController];
        [self tileSubViews];
    }
    
    // loop and tell controller to adapt UI
    for(HostableViewController *hc in parBibleViewControllers) {
        [hc adaptUIToHost];
    }
    for(HostableViewController *hc in parMiscViewControllers) {
        [hc adaptUIToHost];
    }
}

#pragma mark - TextDisplayable

- (void)displayTextForReference:(NSString *)aReference {
    [self displayTextForReference:aReference searchType:searchType];
}

- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType {
    searchType = aType;
    
    self.reference = aReference;

    if(aReference) {
        if([aReference length] > 0) {
            if(searchType == IndexSearchType) {
                // for search type index, check before hand that all modules that are open
                // have a valid index
                BOOL validIndex = YES;
                
                // bibles
                for(BibleViewController *bvc in parBibleViewControllers) {
                    SwordModule *mod = [bvc module];
                    if(mod != nil) {
                        if(![mod hasIndex]) {
                            validIndex = NO;
                            break;
                        }
                    }
                }
                
                // search further for no vaid indexes
                if(validIndex) {
                    // commentaries
                    for(CommentaryViewController *cvc in parMiscViewControllers) {
                        SwordModule *mod = [cvc module];
                        if(mod != nil) {
                            if(![mod hasIndex]) {
                                validIndex = NO;
                                break;
                            }
                        }
                    }
                }
                
                if(!validIndex) {
                    if([userDefaults boolForKey:DefaultsBackgroundIndexerEnabled]) {
                        // show Alert
                        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"IndexNotReady", @"")
                                                         defaultButton:NSLocalizedString(@"OK", @"") alternateButton:nil otherButton:nil 
                                             informativeTextWithFormat:NSLocalizedString(@"IndexNotReadyBGOn", @"")];
                        [alert runModal];
                    } else {
                        // let the user know that creating the index on the fly might take a while
                        // show Alert
                        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"IndexNotReady", @"")
                                                         defaultButton:NSLocalizedString(@"OK", @"") alternateButton:nil otherButton:nil 
                                             informativeTextWithFormat:NSLocalizedString(@"IndexNotReadyBGOff", @"")];
                        [alert runModal];
                    }
                }
            }
        }
        
        // we take control over the progress action
        progressControl = YES;
        // let subcontrollers display their things
        [self distributeReference:aReference];
        // give back control to subview controller
        progressControl = NO;
        
        // end progress indication
        // index search type is handled by virew controllers themselves
        if(aType == ReferenceSearchType) {
            [self endIndicateProgress];    
        }        
    }
}

#pragma mark - MouseTracking

- (void)mouseEntered:(NSView *)theView {
    currentSyncView = (ScrollSynchronizableView *)theView;
    [self establishScrollSynchronization:[(ScrollSynchronizableView *)theView syncScrollView]];
}

- (void)mouseExited:(NSView *)theView {
    [self stopScrollSynchronizationForView:[(ScrollSynchronizableView *)theView syncScrollView]];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        progressControl = NO;
        searchType = [decoder decodeIntForKey:@"SearchTypeEncoded"];
        
        // init bible views array
        self.parBibleViewControllers = [decoder decodeObjectForKey:@"ParallelBibleViewControllerEncoded"];
        // init commentary views array
        self.parMiscViewControllers = [decoder decodeObjectForKey:@"ParallelMiscViewControllerEncoded"];
        // loop and set delegate
        for(HostableViewController *hc in parBibleViewControllers) {
            hc.delegate = self;
            [hc adaptUIToHost];
        }
        for(HostableViewController *hc in parMiscViewControllers) {
            hc.delegate = self;
            [hc adaptUIToHost];
        }
        
        regex = [[MBRegex alloc] initWithPattern:@"^(.+\\d+:\\d+:).*"];
        // check error
        if([regex errorCodeOfLastAction] != MBRegexSuccess) {
            // set error string and return
            MBLOGV(MBLOG_ERR, @"error creating regex: %@", [regex errorMessageOfLastAction]);
        }

        // load nib
        BOOL stat = [NSBundle loadNibNamed:BIBLECOMBIVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BibleCombiViewController -initWithCoder] unable to load nib!");
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [super encodeWithCoder:encoder];

    // encode searchType
    [encoder encodeInt:searchType forKey:@"SearchTypeEncoded"];
    // encode parallel bible view controllers
    [encoder encodeObject:parBibleViewControllers forKey:@"ParallelBibleViewControllerEncoded"];
    // encode parallel commentary view controllers
    [encoder encodeObject:parMiscViewControllers forKey:@"ParallelMiscViewControllerEncoded"];
}

@end
