//
//  ExtTextViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ExtTextViewController.h"
#import "MouseTrackingScrollView.h"
#import "MBPreferenceController.h"
#import "HUDPreviewController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "globals.h"
#import "ProtocolHelper.h"

@interface ExtTextViewController ()

- (NSString *)processPreviewDisplay:(NSURL *)aUrl;

@end

@implementation ExtTextViewController

- (id)init {
    self = [self initWithDelegate:nil];
    
    return self;
}

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -init] loading nib");
        
        // init values
        viewLoaded = NO;
        self.delegate = aDelegate;

        // load nib
        BOOL stat = [NSBundle loadNibNamed:EXTTEXTVIEW_NIBNAME owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[ExtTextViewController -init] unable to load nib!");
        }
    }
    
    return self;    
}

- (void)awakeFromNib {
    
    MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -awakeFromNib]");
    // call delegate method when this view has loaded
    viewLoaded = YES;
    
    //[[self view] setWantsLayer:YES];
    
    // delete any content in textview
    [textView setString:@""];
    
    // set delegate for mouse tracking
    scrollView.delegate = self;
    
    [textView setHorizontallyResizable:YES];
    //[[textView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[textView textContainer] setWidthTracksTextView:YES];
    //[[textView textContainer] setHeightTracksTextView:YES];
    NSSize margins = NSMakeSize([[userDefaults objectForKey:DefaultsTextContainerVerticalMargins] floatValue], 
                                [[userDefaults objectForKey:DefaultsTextContainerHorizontalMargins] floatValue]);
    [textView setTextContainerInset:margins];
    // we also observe changing of this value
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:DefaultsTextContainerVerticalMargins
                                               options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:DefaultsTextContainerHorizontalMargins
                                               options:NSKeyValueObservingOptionNew context:nil];
    
    // register for frame changed notifications of mouse tracking scrollview
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewFrameDidChange:)
                                                 name:NSViewFrameDidChangeNotification
                                               object:scrollView];
    
    
    // tell scrollview to post bounds notifications
    [scrollView setPostsFrameChangedNotifications:YES];    
    // enable mouse tracking
    [scrollView updateMouseTracking];
    
    // report view loading completed
    [self reportLoadingComplete];
}

/** pass though to delegate */
- (IBAction)saveDocument:(id)sender {
    [delegate saveDocument:sender];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// check for keyPath
	if([keyPath isEqualToString:DefaultsTextContainerVerticalMargins]) {
        NSSize margins = NSMakeSize([[userDefaults objectForKey:DefaultsTextContainerVerticalMargins] floatValue], 
                                    [[userDefaults objectForKey:DefaultsTextContainerHorizontalMargins] floatValue]);
        [textView setTextContainerInset:margins];
	} else if([keyPath isEqualToString:DefaultsTextContainerHorizontalMargins]) {
        NSSize margins = NSMakeSize([[userDefaults objectForKey:DefaultsTextContainerVerticalMargins] floatValue], 
                                    [[userDefaults objectForKey:DefaultsTextContainerHorizontalMargins] floatValue]);
        [textView setTextContainerInset:margins];
	}
}

#pragma mark - getter/setter

- (MBTextView *)textView {
    return textView;
}

- (MouseTrackingScrollView *)scrollView {
    return scrollView;
}

- (void)setAttributedString:(NSAttributedString *)aString {
    [[textView textStorage] setAttributedString:aString];    
}

#pragma mark - MBTextView delegates

- (NSMenu *)menuForEvent:(NSEvent *)event {
    if(delegate) {
        return [delegate performSelector:@selector(menuForEvent:) withObject:event];
    }
    
    return nil;
}

#pragma mark - methods

- (NSDictionary *)dataForLink:(NSURL *)aURL {
    // there are two types of links
    // our generated sword:// links and study data beginning with applewebdata://
    
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    NSString *scheme = [aURL scheme];
    if([scheme isEqualToString:@"sword"]) {
        // in this case host is the module and path the reference
        [ret setObject:[aURL host] forKey:ATTRTYPE_MODULE];
        [ret setObject:[[[aURL path] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"/" withString:@""]
                forKey:ATTRTYPE_VALUE];
        [ret setObject:@"scriptRef" forKey:ATTRTYPE_TYPE];
        [ret setObject:@"showRef" forKey:ATTRTYPE_ACTION];
    } else if([scheme isEqualToString:@"applewebdata"]) {
        // in this case
        NSString *path = [aURL path];
        NSString *query = [aURL query];
        if([[path lastPathComponent] isEqualToString:@"passagestudy.jsp"]) {
            NSArray *data = [query componentsSeparatedByString:@"&"];
            NSString *type = @"x";
            NSString *module = @"";
            NSString *passage = @"";
            NSString *value = @"1";
            NSString *action = @"";
            for(NSString *entry in data) {
                if([entry hasPrefix:@"type="]) {
                    type = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];
                } else if([entry hasPrefix:@"module="]) {
                    module = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];
                } else if([entry hasPrefix:@"passage="]) {
                    passage = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];
                } else if([entry hasPrefix:@"action="]) {
                    action = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];                    
                } else if([entry hasPrefix:@"value="]) {
                    value = [[entry componentsSeparatedByString:@"="] objectAtIndex:1];                    
                } else {
                    MBLOGV(MBLOG_WARN, @"[ExtTextViewController -dataForLink:] unknown parameter: %@\n", entry);
                }
            }
            
            [ret setObject:module forKey:ATTRTYPE_MODULE];
            [ret setObject:passage forKey:ATTRTYPE_PASSAGE];
            [ret setObject:value forKey:ATTRTYPE_VALUE];
            [ret setObject:action forKey:ATTRTYPE_ACTION];
            [ret setObject:type forKey:ATTRTYPE_TYPE];
        }
    }
    
    return ret;
}

#pragma mark - NSTextView delegates

- (NSString *)textView:(NSTextView *)textView willDisplayToolTip:(NSString *)tooltip forCharacterAtIndex:(NSUInteger)characterIndex {
    MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -textView:willDisplayToolTip:]");

    // create URL
    NSURL *url = [NSURL URLWithString:[tooltip stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if(!url) {
        MBLOGV(MBLOG_WARN, @"[ExtTextViewController -textView:willDisplayToolTip:] no URL: %@\n", tooltip);
    } else {
        return [self processPreviewDisplay:url];
    }
    
    return @"";
}

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -textView:clickedOnLink:]");
    
    [self processPreviewDisplay:(NSURL *)link];
    
    return YES;
}

- (NSString *)processPreviewDisplay:(NSURL *)aUrl {
    NSDictionary *linkResult = [self dataForLink:aUrl];
    SendNotifyShowPreviewData(linkResult);
    
    MBLOGV(MBLOG_DEBUG, @"[ExtTextViewController -textView:clickedOnLink:] classname: %@", [aUrl className]);    
    MBLOGV(MBLOG_DEBUG, @"[ExtTextViewController -textView:clickedOnLink:] link: %@", [aUrl description]);
    if([userDefaults boolForKey:DefaultsShowPreviewToolTip]) {
        return [[HUDPreviewController previewDataFromDict:linkResult] objectForKey:PreviewDisplayTextKey];
    }
    
    return @"";
}

- (void)textView:(NSTextView *)aTextView doubleClickedOnCell:(id < NSTextAttachmentCell >)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
    MBLOG(MBLOG_DEBUG, @"[ExtTextViewController -textView:doubleClickedOnCell:inRect:atIndex:]");    
}

#pragma mark - mouse tracking protocol

- (void)mouseEntered:(NSView *)theView {
    //MBLOG(MBLOG_DEBUG, @"[ExtTextViewController - mouseEntered]");
    if(delegate && [delegate respondsToSelector:@selector(mouseEntered:)]) {
        [delegate performSelector:@selector(mouseEntered:) withObject:[self view]];
    }
}

- (void)mouseExited:(NSView *)theView {
    //MBLOG(MBLOG_DEBUG, @"[ExtTextViewController - mouseExited]");
    if(delegate && [delegate respondsToSelector:@selector(mouseExited:)]) {
        [delegate performSelector:@selector(mouseExited:) withObject:[self view]];
    }
}

- (void)scrollViewFrameDidChange:(NSNotification *)n {
    //MBLOG(MBLOG_DEBUG, @"[ExtTextViewController - scrollViewFrameDidChange]");
    
    [scrollView updateMouseTracking];
}

@end
