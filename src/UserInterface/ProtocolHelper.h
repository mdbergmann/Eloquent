/*
 *  SubviewHosting.h
 *  MacSword2
 *
 *  Created by Manfred Bergmann on 21.06.08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import <SwordModule.h>

@class HostableViewController;

@protocol SubviewHosting
/** called from subview when it has fully loaded */
- (void)contentViewInitFinished:(HostableViewController *)aViewController;
- (void)removeSubview:(HostableViewController *)aViewController;
@end

@protocol WindowHosting
- (ModuleType)moduleType;
@end

/** protocol to track mouse movement */
@protocol MouseTracking
- (void)mouseEntered:(NSView *)theView;
- (void)mouseExited:(NSView *)theView;
@end