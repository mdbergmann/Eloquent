//
//  BibleCombiViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BibleCombiViewController.h"
#import "BibleViewController.h"
#import "CommentaryViewController.h"
#import "ScrollSynchronizableView.h"
#import "SwordManager.h"
#import "SwordSearching.h"
#import "ReferenceCacheManager.h"

@interface BibleCombiViewController (/* Private, class continuation */)
/** private property */
@property(readwrite, retain) NSMutableArray *parBibleViewControllers;
@property(readwrite, retain) NSMutableArray *parMiscViewControllers;

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
- (NSString *)verseMarkerInTextLine:(NSAttributedString *)text;
- (NSRect)rectForTextRange:(NSRange)range inTextView:(NSTextView *)textView;
- (NSRect)rectForAttributeName:(NSString *)attrName attributeValue:(id)attrValue inTextView:(NSTextView *)textView;
- (NSString *)verseMarkerOfFirstLineOfTextView:(ScrollSynchronizableView *)syncView;

@end

@implementation BibleCombiViewController

#pragma mark - properties

@synthesize parBibleViewControllers;
@synthesize parMiscViewControllers;
@synthesize reference;

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
        MBLOG(MBLOG_DEBUG, @"[BibleCombiViewController -init] loading nib");
        
        // delegate
        self.delegate = aDelegate;
        searchType = ReferenceSearchType;
        
        // init bible views array
        self.parBibleViewControllers = [NSMutableArray array];
        // init misc views array
        self.parMiscViewControllers = [NSMutableArray array];
        
        regex = [[MBRegex alloc] initWithPattern:@".*\"sword://.+\/.+\/\\d+\/\\d+\".*"];
        // check error
        if([regex errorCodeOfLastAction] != MBRegexSuccess) {
            // set error string and return
            MBLOGV(MBLOG_ERR, @"error creating regex: %@", [regex errorMessageOfLastAction]);
        }

        // load nib
        BOOL stat = [NSBundle loadNibNamed:BIBLECOMBIVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[BibleCombiViewController -init] unable to load nib!");
        } else {
            // add initial bible view
            [self addNewBibleViewWithModule:aBible];
        }
    }
    
    return self;    
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[BibleCombiViewController -awakeFromNib]");
    
    defaultMiscViewHeight = 60;
    [horiSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    
    // set vertical parallel splitview
    [parBibleSplitView setVertical:YES];
    [parBibleSplitView setDividerStyle:NSSplitViewDividerStyleThin];

    // set vertical parallel misc splitview
    [parMiscSplitView setVertical:YES];
    [parMiscSplitView setDividerStyle:NSSplitViewDividerStyleThin];
    
    // add parallel bible split view to main
    [horiSplitView addSubview:parBibleSplitView positioned:NSWindowAbove relativeTo:nil];
    [horiSplitView addSubview:parMiscSplitView positioned:NSWindowAbove relativeTo:nil];
    // if this is the first entry, we need to add the parallel misc view itself
    NSSize s = [parMiscSplitView frame].size;
    if([parMiscViewControllers count] > 0) {
        s.height = defaultMiscViewHeight;
    } else {
        s.height = 0;
    }
    [parMiscSplitView setFrameSize:s];
    
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
    
    // if we have a reference, process it
    if(reference) {
        [self displayTextForReference:reference searchType:searchType];
    }
    
    if(loaded) {
        [self reportLoadingComplete];
    }
}

#pragma mark - methods

- (NSString *)label {
    return @"BibleView";
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
    // add to array
    [parBibleViewControllers addObject:bvc];
    [self tileSubViews];
    
    // tell views to adapt any UI components
    for(HostableViewController *hc in parBibleViewControllers) {
        [hc adaptUIToHost];
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
    
    CommentaryViewController *cvc = [[CommentaryViewController alloc] initWithDelegate:self];
    [cvc setModule:(SwordModule *)aModule];
    // add to array
    [parMiscViewControllers addObject:cvc];

    // tell views to adapt any UI components
    for(HostableViewController *hc in parMiscViewControllers) {
        [hc adaptUIToHost];
    }
}

- (void)distributeReference:(NSString *)aRef {
    // loop over all BibleViewControllers and set this reference
    for(BibleViewController *bvc in parBibleViewControllers) {
        // set reference
        [bvc displayTextForReference:aRef searchType:searchType];
    }
    
    // loop over all misc ViewControllers and set this reference
    for(CommentaryViewController *cvc in parMiscViewControllers) {
        // set reference
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
    
    NSString *sourceMarker = nil;
    if(searchType == ReferenceSearchType) {
        sourceMarker = [self verseMarkerOfFirstLineOfTextView:currentSyncView];
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
                
                // get the cerseMarker of this syncview
                NSString *marker = [self verseMarkerOfFirstLineOfTextView:v];
                
                // the sender is the rightest scrollview
                if((sourceMarker != nil) && ([sourceMarker length] > 0) && ![marker isEqualToString:sourceMarker]) {
                    /*
                    // get all text
                    NSAttributedString *allText = [[v textView] textStorage];
                    // get index of match
                    NSRange destRange = [[allText string] rangeOfString:match];
                    
                    // now get glyph range for these character range
                    NSRange glyphRange = [[[v textView] layoutManager] glyphRangeForCharacterRange:destRange actualCharacterRange:nil];
                    // get view rect of this glyph range
                    NSRect destRect = [[[v textView] layoutManager] lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:nil];
                     */
                    
                    NSRect destRect = [self rectForAttributeName:@"VerseMarkerAttributeName" attributeValue:sourceMarker inTextView:v.textView];
                    
                    if(destRect.origin.x != NSNotFound) {
                        // set point
                        destPoint.x = destRect.origin.x;
                        destPoint.y = destRect.origin.y;                                            
                    } else {
                        updateScroll = NO;                        
                    }
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

- (NSString *)verseMarkerInTextLine:(NSAttributedString *)text {
    NSString *ret = nil;
    
    // get the first found verseMarker attribute in the given text
    long len = [text length];
    for(int i = 0;i < len;i++) {
        NSString * val = [text attribute:@"VerseMarkerAttributeName" atIndex:i effectiveRange:nil];
        if(val != nil) {
            ret = val;
            break;
        }
    }
    
    return ret;
}

- (NSRect)rectForTextRange:(NSRange)range inTextView:(NSTextView *)textView {
    NSLayoutManager *layoutManager = [textView layoutManager];
    NSRect rect = [layoutManager lineFragmentRectForGlyphAtIndex:range.location effectiveRange:nil];
    return rect;
}

/**
 tries to find the given attribute value
 if not found, ret.origin.x == NSNotFound
 */
- (NSRect)rectForAttributeName:(NSString *)attrName attributeValue:(id)attrValue inTextView:(NSTextView *)textView {
    NSRect ret;
    ret.origin.x = NSNotFound;
    
    NSAttributedString *text = [textView attributedString];
    long len = [[textView string] length];
    NSRange foundRange;
    foundRange.location = NSNotFound;
    for(int i = 0;i < len;i++) {
        id val = [text attribute:attrName atIndex:i effectiveRange:&foundRange];
        if(val != nil) {
            if([val isKindOfClass:[NSString class]] && [(NSString *)val isEqualToString:(NSString *)attrValue]) {
                break;
            } else {
                i = foundRange.location + foundRange.length;
                foundRange.location = NSNotFound;
            }
        }
    }
    
    if(foundRange.location != NSNotFound) {
        ret = [self rectForTextRange:foundRange inTextView:textView];
    }
    
    return ret;
}

- (NSString *)verseMarkerOfFirstLineOfTextView:(ScrollSynchronizableView *)syncView {
    // all bible views display all verse keys whether they are empty or not. But we can search for the verse location
    NSRect lineRect;
    NSRange lineRange = [self rangeFromViewableFirstLineInTextView:[syncView textView] lineRect:&lineRect];
    // try to get characters of textStorage
    NSAttributedString *attrString = [[[syncView textView] textStorage] attributedSubstringFromRange:NSMakeRange(lineRange.location, lineRange.length)];
    // now, that we have the first line, extract the verse Marker
    return [self verseMarkerInTextLine:attrString];    
}

#pragma mark - SubviewHosting protocol

- (void)contentViewInitFinished:(HostableViewController *)aView {
    MBLOG(MBLOG_DEBUG, @"[BibleCombiViewController -contentViewInitFinished:]");
    // get latest view
    NSView *view = nil;
    
    // check if this view has completed loading annd also all of the subviews    
    if(viewLoaded == YES) {
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
            
            // set search text and let the controller handle it
            [(BibleViewController *)aView displayTextForReference:reference searchType:searchType];
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
    
    if([aViewController isKindOfClass:[CommentaryViewController class]]) {
        // remove controller
        [parMiscViewControllers removeObject:aViewController];
        if([parMiscViewControllers count] == 0) {
            NSSize s = [parMiscSplitView frame].size;
            s.height = 0;
            [parMiscSplitView setFrameSize:s];
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

- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType {
    searchType = aType;
    self.reference = aReference;
    
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
        if(!validIndex) {
            // show Alert
            NSAlert *alert = [NSAlert alertWithMessageText:@"Index not ready"
                                             defaultButton:@"OK" alternateButton:nil otherButton:nil 
                                 informativeTextWithFormat:@"The index of one or more modules is not created yet. Please try again later!"];
            [alert runModal];
        } else {
            [self distributeReference:aReference];    
        }
    } else {
        [self distributeReference:aReference];    
    }
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
        reference = [decoder decodeObjectForKey:@"SearchReference"];
        
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
    // encode searchType
    [encoder encodeInt:searchType forKey:@"SearchTypeEncoded"];
    // encode reference
    [encoder encodeObject:reference forKey:@"SearchReference"];
    // encode parallel bible view controllers
    [encoder encodeObject:parBibleViewControllers forKey:@"ParallelBibleViewControllerEncoded"];
    // encode parallel commentary view controllers
    [encoder encodeObject:parMiscViewControllers forKey:@"ParallelMiscViewControllerEncoded"];
}

#pragma mark - actions

@end
