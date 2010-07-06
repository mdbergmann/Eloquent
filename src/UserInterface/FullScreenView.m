//
//  FullScreenView.m
//  MacSword2
//
//  Created by Manfred Bergmann on 09.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FullScreenView.h"
#import "MBPreferenceController.h"
#import "ConfirmationSheetController.h"
#import "ToolbarController.h"
#import "globals.h"

@interface FullScreenView ()

@property (retain, readwrite) NSDictionary *trackingData;

- (void)enterFullScreenMode;
- (void)exitFullScreenMode;

- (void)updateTrackingRectForViewRect:(NSRect)aRect;

@end

@implementation FullScreenView

@synthesize delegate;
@synthesize toolbarController;
@synthesize trackingData;

- (BOOL)isFullScreenMode {
    return [self isInFullScreenMode];
}

- (void)setFullScreenMode:(BOOL)flag {
    if(flag) {
        if([userDefaults objectForKey:DefaultsShowFullScreenConfirm] == nil || 
           [userDefaults boolForKey:DefaultsShowFullScreenConfirm] == NO) {
            conf = [[ConfirmationSheetController alloc] initWithSheetTitle:NSLocalizedString(@"ConfirmFullScreenMode", @"") 
                                                                   message:NSLocalizedString(@"ConfirmFullScreenModeText", @"") 
                                                             defaultButton:NSLocalizedString(@"OK", @"") 
                                                           alternateButton:NSLocalizedString(@"Cancel", @"") 
                                                               otherButton:nil 
                                                            askAgainButton:NSLocalizedString(@"DoNotAskAgain", @"") 
                                                       defaultsAskAgainKey:DefaultsShowFullScreenConfirm 
                                                               contextInfo:nil 
                                                                 docWindow:[self window]];
            [conf setDelegate:self];
            [conf beginSheet];
        } else {
            [self enterFullScreenMode];
        }
    } else {
        [self exitFullScreenMode];
    }
}

- (IBAction)fullScreenModeOnOff:(id)sender {
    [self setFullScreenMode:![self isFullScreenMode]];
}

- (void)confirmationSheetEnded {
    if(conf) {
        if([conf sheetReturnCode] == SheetDefaultButtonCode) {
            [self enterFullScreenMode];
        }
    }
}

- (void)enterFullScreenMode {
    if([self delegate] && [[self delegate] respondsToSelector:@selector(goingToFullScreenMode)]) {
        [[self delegate] performSelector:@selector(goingToFullScreenMode)];
    }
    [self enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];    
    
    // stretch toolbar view to take up 3/4 of the main view width    
    NSView *hudView = [toolbarController toolbarHUDView];
    CGFloat mainViewWidth = [self frame].size.width;
    CocoLog(LEVEL_DEBUG, @"fsview width: %f", mainViewWidth);
    CGFloat newHUDViewWidth = mainViewWidth * (3.0/4.0);
    CocoLog(LEVEL_DEBUG, @"hudview width: %f", newHUDViewWidth);
    [hudView setFrameSize:NSMakeSize(newHUDViewWidth, [hudView frame].size.height)];
    
    if([self delegate] && [[self delegate] respondsToSelector:@selector(goneToFullScreenMode)]) {
        [[self delegate] performSelector:@selector(goneToFullScreenMode)];
    }
}

- (void)exitFullScreenMode {
    if([self delegate] && [[self delegate] respondsToSelector:@selector(leavingFullScreenMode)]) {
        [[self delegate] performSelector:@selector(leavingFullScreenMode)];
    }
    [self exitFullScreenModeWithOptions:nil];    
    if([self delegate] && [[self delegate] respondsToSelector:@selector(leftFullScreenMode)]) {
        [[self delegate] performSelector:@selector(leftFullScreenMode)];
    }
}

#pragma mark - Mouse tracking

- (void)mouseEntered:(NSEvent *)theEvent {
    
    if(theEvent) {
        if([theEvent userData] == trackingData) {
            CocoLog(LEVEL_DEBUG, @"[FullscreenView -mouseEntered:]");
            if([self isInFullScreenMode]) {
                NSView *hudView = [toolbarController toolbarHUDView];
                                
                // center position                
                CGFloat x = [self frame].size.width / 2.0 - [hudView frame].size.width / 2.0;
                CGFloat y = [self frame].size.height - [hudView frame].size.height - 5.0;                
                [hudView setFrameOrigin:NSMakePoint(x, y)];
                
                [NSAnimationContext beginGrouping];
                [[NSAnimationContext currentContext] setDuration:1.0];
                [[self animator] addSubview:hudView positioned:NSWindowAbove relativeTo:nil];
                [NSAnimationContext endGrouping];
                
                [self updateTrackingRectForViewRect:NSMakeRect(x, y, [hudView frame].size.width, [hudView frame].size.height + 5.0)];
            }
        }
    }
        
    //[super mouseEntered:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent {
    if(theEvent) {
        if([theEvent userData] == trackingData) {
            CocoLog(LEVEL_DEBUG, @"[FullscreenView -mouseExited:]");
            if([self isInFullScreenMode]) {
                BOOL setupDefaultTracking = [[self subviews] containsObject:[toolbarController toolbarHUDView]];

                [NSAnimationContext beginGrouping];
                [[NSAnimationContext currentContext] setDuration:1.0];
                [[[toolbarController toolbarHUDView] animator] removeFromSuperview];
                [NSAnimationContext endGrouping];

                if(setupDefaultTracking) {
                    [self updateTrackingAreas];        
                }
            }
        }
    }
    
    //[super mouseExited:theEvent];
}

- (void)updateTrackingRectForViewRect:(NSRect)aRect {
    CocoLog(LEVEL_DEBUG, @"[FullscreenView -updateTrackingRectForSubview:]");
    
    while(self.trackingAreas.count > 0) {
		[self removeTrackingArea:[self.trackingAreas lastObject]];
	}
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:aRect
                                                                options:(NSTrackingMouseEnteredAndExited | 
                                                                         NSTrackingActiveInKeyWindow |
                                                                         NSTrackingAssumeInside) 
                                                                  owner:self 
                                                               userInfo:trackingData];
    [self addTrackingArea:trackingArea];
}

- (void)updateTrackingAreas {
    CocoLog(LEVEL_DEBUG, @"[FullscreenView -updateMouseTracking]");
    
    if(!trackingData) {
        [self setTrackingData:[NSDictionary dictionary]];
    }

    while(self.trackingAreas.count > 0) {
		[self removeTrackingArea:[self.trackingAreas lastObject]];
	}
    NSRect trackingRect = NSMakeRect(0.0, [self frame].size.height-10.0, [self frame].size.width, 10.0);
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect
                                                                options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow) 
                                                                  owner:self 
                                                               userInfo:trackingData];
    [self addTrackingArea:trackingArea];
}

@end
