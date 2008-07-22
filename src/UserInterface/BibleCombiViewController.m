//
//  BibleCombiViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BibleCombiViewController.h"
#import "BibleViewController.h"
#import "ScrollSynchronizableView.h"
#import "SwordManager.h"
#import "ReferenceCacheManager.h"

@interface BibleCombiViewController (/* Private, class continuation */)
/** private property */
@property(readwrite, retain) NSMutableArray *parBibleViewControllers;

/** distribute the reference */
- (void)distributeReference:(NSString *)aRef;
/** when a subview is added we have to recalculate the subview sizes */
- (void)tileSubViews;

// for synchronization of scrollview we need the following methods
- (void)stopScrollSynchronizationForView:(NSScrollView *)aView;
- (void)establishScrollSynchronization:(NSScrollView *)scrollView;
- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)aNotification;
- (NSRange)rangeFromViewableFirstLineInTextView:(NSTextView *)theTextView lineRect:(NSRect *)lineRect;
- (NSString *)verseKeyInTextLine:(NSString *)text;

@end

@implementation BibleCombiViewController

#pragma mark - properties

@synthesize parBibleViewControllers;

#pragma mark - initialization

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[BibleCombiViewController -init] loading nib");

        // delegate
        self.delegate = aDelegate;
        searchType = ReferenceSearchType;
        viewSearchDirRight = YES;
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:BIBLECOMBIVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BibleCombiViewController -init] unable to load nib!");
        } else {
            // init bible views array
            self.parBibleViewControllers = [NSMutableArray array];
            
            regex = [[MBRegex alloc] initWithPattern:@"^(.+\\d+:\\d+:).*"];
            // check error
            if([regex errorCodeOfLastAction] != MBRegexSuccess) {
                // set error string and return
                MBLOGV(MBLOG_ERR, @"error creating regex: %@", [regex errorMessageOfLastAction]);
            }
            
            // add initial bible view
            [self addNewBibleViewWithModule:nil];
        }
    }
    
    return self;    
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[BibleCombiViewController -awakeFromNib]");
    
    // set vertical parallel splitview
    [parBibleSplitView setVertical:YES];
    [parBibleSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    
    // add parallel bible split view to main
    [horiSplitView addSubview:parBibleSplitView positioned:NSWindowAbove relativeTo:nil];
    
    // loading finished
    viewLoaded = YES;
    
    // if our hosted subviews also have loaded, report that
    // else, wait until the subviews have loaded and report then
    // loop over all subview controllers
    BOOL loaded = YES;
    for(HostableViewController *hc in parBibleViewControllers) {
        if(hc.viewLoaded == NO) {
            loaded = NO;
        } else {
            // add the webview as contentvew to the placeholder
            [parBibleSplitView addSubview:[hc view] positioned:NSWindowBelow relativeTo:nil];        
            [self tileSubViews];
        }
    }
    
    if(loaded) {
        [self reportLoadingComplete];
    }
}

#pragma mark - methods

- (void)addNewBibleViewWithModule:(SwordModule *)aModule {
    // after loading this combi view there is only one bibleview, nothing more
    BibleViewController *bvc = [[BibleViewController alloc] initWithModule:(SwordBible *)aModule delegate:self];
    // add to array
    [parBibleViewControllers addObject:bvc];
    [self tileSubViews];
}

- (void)distributeReference:(NSString *)aRef {
    // loop over all BibleViewControllers and set this reference
    for(BibleViewController *bvc in parBibleViewControllers) {
        // set view search direction
        bvc.viewSearchDirectionRight = viewSearchDirRight;
        // set reference
        [bvc displayTextForReference:aRef searchType:searchType];
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

#pragma mark - scrollview synchronization

- (void)stopScrollSynchronizationForView:(NSScrollView *)aScrollView {
    // get contentview of this view and remove listener
    if (aScrollView != nil) {
        NSView *contentView = [aScrollView contentView];
        
        // remove any existing notification registration
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSViewBoundsDidChangeNotification
                                                      object:contentView];
    }    
}

- (void)establishScrollSynchronization:(NSScrollView *)scrollView {
    // loop over all views in parallel bible splitview and deacivate the scroller for all but the most right view
    // let all left scrollview register for notifications from the bounds changes of the most right scrollview
    if(viewLoaded) {
        // register observer for notification only for the given one
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(synchronizedViewContentBoundsDidChange:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:[scrollView contentView]];
        // tell scrollview to post bounds notifications
        [scrollView setPostsBoundsChangedNotifications:YES];
    }
}

- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)aNotification {

    // get the changed content view from the notification
    NSView *changedContentView = [aNotification object];
    
    // get the origin of the NSClipView of the scroll view that
    // we're watching
    NSPoint changedBoundsOrigin = [changedContentView bounds].origin;
    
    NSString *match = nil;
    if(searchType == ReferenceSearchType) {
        // all bible views display all verse keys whether they are empty or not. But we can search for the verse location
        NSRect lineRect;
        NSRange lineRange = [self rangeFromViewableFirstLineInTextView:[currentSyncView textView] lineRect:&lineRect];
        // try to get characters of textStorage
        NSAttributedString *attrString = [[[currentSyncView textView] textStorage] attributedSubstringFromRange:NSMakeRange(lineRange.location, lineRange.length)];
        NSString *rangeString = [attrString string];
        // now, that we have the first line, extract the sword key
        match = [self verseKeyInTextLine:rangeString];
    }
    
    // loop over all parallel views and check bounds
    NSEnumerator *iter = [[parBibleSplitView subviews] reverseObjectEnumerator];
    ScrollSynchronizableView *v = nil;
    while((v = [iter nextObject])) {
        // get scrollView
        NSScrollView *scrollView = v.syncScrollView;
        
        // we only want to change bounds for the scrollviews that are not the sender of the notification
        if([scrollView contentView] != changedContentView) {
            // get our current origin
            NSPoint curOffset = [[scrollView contentView] bounds].origin;
            NSPoint newOffset = curOffset;
            
            // scrolling is synchronized in the vertical plane
            // so only modify the y component of the offset
            newOffset.y = changedBoundsOrigin.y;            
            
            // the point to scroll to
            NSPoint destPoint;
            
            BOOL updateScroll = YES;
            if(searchType == ReferenceSearchType) {
                // the sender is the rightest scrollview
                if((match != nil) && ([match length] > 0)) {
                    // get all text
                    NSAttributedString *allText = [[v textView] textStorage];
                    // get index of match
                    NSRange destRange = [[allText string] rangeOfString:match];
                    
                    // now get glyph range for these character range
                    NSRange glyphRange = [[[v textView] layoutManager] glyphRangeForCharacterRange:destRange actualCharacterRange:nil];
                    // get view rect of this glyph range
                    NSRect destRect = [[[v textView] layoutManager] lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:nil];
                    
                    // set point
                    destPoint.x = destRect.origin.x;
                    destPoint.y = destRect.origin.y;                    
                } else {
                    updateScroll = NO;
                }
            } else {
                // for al others we can't garatie that all view have the verse key
                destPoint = newOffset;
            }
            
            // if our synced position is different from our current
            // position, reposition our content view
            if (!NSEqualPoints(curOffset, changedBoundsOrigin) && updateScroll) {
                // note that a scroll view watching this one will
                // get notified here
                [[scrollView contentView] scrollToPoint:destPoint];
                // we have to tell the NSScrollView to update its
                // scrollers
                [scrollView reflectScrolledClipView:[scrollView contentView]];
            }        
        }
    }        
}

- (NSRange)rangeFromViewableFirstLineInTextView:(NSTextView *)theTextView lineRect:(NSRect *)lineRect {
    
    if([theTextView enclosingScrollView]) {
        NSLayoutManager *layoutManager = [theTextView layoutManager];
        NSRect visibleRect = [theTextView visibleRect];
        
        NSPoint containerOrigin = [theTextView textContainerOrigin];
        visibleRect.origin.x -= containerOrigin.x;
        visibleRect.origin.y -= containerOrigin.y;
        
        NSRange glyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:[theTextView textContainer]];
        //NSRange glyphRange = [layoutManager glyphRangeForBoundingRectWithoutAdditionalLayout:visibleRect inTextContainer:[theTextView textContainer]];
        //MBLOGV(MBLOG_DEBUG, @"glyphRange loc:%i len:%i", glyphRange.location, glyphRange.length);
        
        // get line range
        *lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:nil];
        //MBLOGV(MBLOG_DEBUG, @"lineRect x:%f y:%f w:%f h:%f", lineRect->origin.x, lineRect->origin.y, lineRect->size.width, lineRect->size.height);
        
        NSRange lineRange = [layoutManager glyphRangeForBoundingRect:*lineRect inTextContainer:[theTextView textContainer]];
        //MBLOGV(MBLOG_DEBUG, @"lineRange loc:%i len:%i", lineRange.location, lineRange.length);        

        return lineRange;
    }
    
    return NSMakeRange(NSNotFound, 0);
}

- (NSString *)verseKeyInTextLine:(NSString *)text {
    NSString *ret = nil;
    
    if(regex) {
        //[regex setCaptureSubstrings:YES];
        MBMatchResult *result = [MBMatchResult matchResult];
        MBRegExResultType stat = [regex matchIn:text matchResult:&result];
        if(stat == MBRegexMatch) {
            // get match
            int index = 0;
            BOOL haveFirst = NO;
            for(int i = 0;i < [text length];i++) {
                unichar c = [text characterAtIndex:i];
                if(c == ':') {
                    if(haveFirst == YES) {
                        index = i;
                        break;
                    }
                    haveFirst = YES;
                }
            }
            NSString *key = [text substringToIndex:index];
            ret = key;
        } else if(stat == MBRegexMatchError) {
            MBLOGV(MBLOG_ERR, @"error matching: %@", [regex errorMessageOfLastAction]);
        }
    }
    
    return ret;
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOG(MBLOG_DEBUG, @"[BibleCombiViewController -contentViewInitFinished:]");
    // get latest view
    NSView *view = nil;
    
    // check if this view has completed loading annd also all of the subviews    
    if(viewLoaded == YES) {
        // add the webview as contentvew to the placeholder
        [parBibleSplitView addSubview:[aView view] positioned:NSWindowAbove relativeTo:view];
        
        [self tileSubViews];

        BOOL loaded = YES;
        for(HostableViewController *hc in parBibleViewControllers) {
            if(hc.viewLoaded == NO) {
                loaded = NO;
            }
        }
        
        if(loaded) {
            // report to super controller
            [self reportLoadingComplete];
        }
    }
}

- (void)removeSubview:(HostableViewController *)aViewController {
    // remove the view of the send controller from our hosts
    NSView *view = [aViewController view];
    [view removeFromSuperview];
    
    // remove controller
    [parBibleViewControllers removeObject:aViewController];
    
    [self tileSubViews];
}

- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType {
    searchType = aType;
    [self distributeReference:aReference];
}

#pragma mark - view search delegate methods

- (void)viewSearchPrevious {
    viewSearchDirRight = NO;
    [self distributeReference:nil];
}

- (void)viewSearchNext {
    viewSearchDirRight = YES;
    [self distributeReference:nil];
}

#pragma mark - mouse tracking protocol

- (void)mouseEntered:(NSView *)theView {
    MBLOG(MBLOG_DEBUG, @"[BibleCombiViewController - mouseEntered]");
    
    // theView should be a ScrollSynchronizableView
    currentSyncView = (ScrollSynchronizableView *)theView;
    [self establishScrollSynchronization:[(ScrollSynchronizableView *)theView syncScrollView]];
}

- (void)mouseExited:(NSView *)theView {
    MBLOG(MBLOG_DEBUG, @"[BibleCombiViewController - mouseExited]");

    // stop synchronization
    [self stopScrollSynchronizationForView:[(ScrollSynchronizableView *)theView syncScrollView]];
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[BibleCombiViewController -initWithCoder] loading nib");
        
        searchType = [decoder decodeIntForKey:@"SearchTypeEncoded"];
        viewSearchDirRight = YES;
        
        // init bible views array
        self.parBibleViewControllers = [decoder decodeObjectForKey:@"ParallelBibleViewControllerEncoded"];
        // loop and set delegate
        for(HostableViewController *hc in parBibleViewControllers) {
            hc.delegate = self;
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
    // encode searchType
    [encoder encodeInt:searchType forKey:@"SearchTypeEncoded"];
    // encode parallel bible view controllers
    [encoder encodeObject:parBibleViewControllers forKey:@"ParallelBibleViewControllerEncoded"];
}

#pragma mark - actions

@end
