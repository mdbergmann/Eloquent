//
//  ExtTextViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ExtTextViewController.h"
#import "MouseTrackingScrollView.h"
#import "MBPreferenceController.h"
#import "globals.h"
#import "NSUserDefaults+Additions.h"
#import "MBTextView.h"

@interface ExtTextViewController ()

@end

@implementation ExtTextViewController

- (id)init {
    self = [self initWithDelegate:nil];
    
    return self;
}

- (id)initWithDelegate:(id)aDelegate {
    self = [super init];
    if(self) {
        CocoLog(LEVEL_DEBUG, @"loading nib");
        
        // init values
        viewLoaded = NO;
        self.delegate = aDelegate;

        // load nib
        BOOL stat = [NSBundle loadNibNamed:EXTTEXTVIEW_NIBNAME owner:self];
        if(!stat) {
            CocoLog(LEVEL_ERR, @"unable to load nib!");
        }
    }
    
    return self;    
}

- (void)awakeFromNib {
    
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
    [linkAttributes setObject:[userDefaults objectForKey:DefaultsLinkUnderlineAttribute] forKey:NSUnderlineStyleAttributeName];
    [linkAttributes setObject:[userDefaults colorForKey:DefaultsLinkForegroundColor] forKey:NSForegroundColorAttributeName];
    [linkAttributes setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
    [textView setLinkTextAttributes:linkAttributes];

    [textView setBackgroundColor:[userDefaults colorForKey:DefaultsTextBackgroundColor]];

    NSMutableDictionary *selectionAttributes = [[[textView selectedTextAttributes] mutableCopy] autorelease];
    [selectionAttributes setObject:[userDefaults colorForKey:DefaultsTextHighlightColor] forKey:NSBackgroundColorAttributeName];
    [textView setSelectedTextAttributes:selectionAttributes];
     
    [textView setString:@""];
    scrollView.delegate = self;
    
    [textView setHorizontallyResizable:YES];
    [[textView textContainer] setWidthTracksTextView:YES];
    NSSize margins = NSMakeSize([[userDefaults objectForKey:DefaultsTextContainerVerticalMargins] floatValue], 
                                [[userDefaults objectForKey:DefaultsTextContainerHorizontalMargins] floatValue]);
    [textView setTextContainerInset:margins];
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:DefaultsTextContainerVerticalMargins
                                               options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:DefaultsTextContainerHorizontalMargins
                                               options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:DefaultsTextBackgroundColor
                                               options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:DefaultsTextHighlightColor
                                               options:NSKeyValueObservingOptionNew context:nil];
    [[NSUserDefaults standardUserDefaults] addObserver:self 
                                            forKeyPath:DefaultsLinkForegroundColor
                                               options:NSKeyValueObservingOptionNew context:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewFrameDidChange:)
                                                 name:NSViewFrameDidChangeNotification
                                               object:scrollView];
    
    [scrollView setPostsFrameChangedNotifications:YES];    
    [scrollView updateMouseTracking];

    viewLoaded = YES;
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
	} else if([keyPath isEqualToString:DefaultsTextBackgroundColor]) {
        [textView setBackgroundColor:[userDefaults colorForKey:DefaultsTextBackgroundColor]];        
	} else if([keyPath isEqualToString:DefaultsTextHighlightColor]) {
        NSMutableDictionary *selectionAttributes = [[[textView selectedTextAttributes] mutableCopy] autorelease];
        [selectionAttributes setObject:[userDefaults colorForKey:DefaultsTextHighlightColor] forKey:NSBackgroundColorAttributeName];
        [textView setSelectedTextAttributes:selectionAttributes];
	} else if([keyPath isEqualToString:DefaultsLinkForegroundColor]) {
        NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
        [linkAttributes setObject:[userDefaults objectForKey:DefaultsLinkUnderlineAttribute] forKey:NSUnderlineStyleAttributeName];
        [linkAttributes setObject:[userDefaults colorForKey:DefaultsLinkForegroundColor] forKey:NSForegroundColorAttributeName];
        [linkAttributes setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
        [textView setLinkTextAttributes:linkAttributes];
	}
}

#pragma mark - TextContentProviding

- (MBTextView *)textView {
    return textView;
}

- (MouseTrackingScrollView *)scrollView {
    return scrollView;
}

- (void)setAttributedString:(NSAttributedString *)aString {
    [[textView textStorage] setAttributedString:aString];    
}

- (void)setString:(NSString *)aString {
    [textView setString:aString];
}

- (void)textChanged:(NSNotification *)aNotification {
    if(delegate && [delegate respondsToSelector:@selector(textChanged:)]) {
        [delegate performSelector:@selector(textChanged:) withObject:aNotification];
    }
}

#pragma mark - MBTextView delegates

- (NSMenu *)menuForEvent:(NSEvent *)event {
    if(delegate) {
        return [delegate performSelector:@selector(menuForEvent:) withObject:event];
    }
    return nil;
}

#pragma mark - NSTextView delegates

- (NSString *)textView:(NSTextView *)aTextView willDisplayToolTip:(NSString *)tooltip forCharacterAtIndex:(NSUInteger)characterIndex {
    NSURL *url = [NSURL URLWithString:[tooltip stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if(!url) {
        CocoLog(LEVEL_WARN, @"no URL: %@\n", tooltip);
    } else {
        return [delegate performSelector:@selector(processPreviewDisplay:) withObject:url];
    }
    
    return @"";
}

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    if(delegate) {
        [delegate performSelector:@selector(linkClicked:) withObject:link];
    }
    return YES;
}

- (void)textView:(NSTextView *)aTextView doubleClickedOnCell:(id < NSTextAttachmentCell >)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
}

#pragma mark - mouse tracking protocol

- (void)mouseEnteredView:(NSView *)theView {
    if(delegate && [delegate respondsToSelector:@selector(mouseEnteredView:)]) {
        [delegate performSelector:@selector(mouseEnteredView:) withObject:[self view]];
    }
}

- (void)mouseExitedView:(NSView *)theView {
    if(delegate && [delegate respondsToSelector:@selector(mouseExitedView:)]) {
        [delegate performSelector:@selector(mouseExitedView:) withObject:[self view]];
    }
}

- (void)scrollViewFrameDidChange:(NSNotification *)n {
    [scrollView updateMouseTracking];
}

@end
