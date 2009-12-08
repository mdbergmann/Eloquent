//
//  SingleViewHostController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 16.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <WindowHostController.h>
#import <Indexer.h>
#import <SwordModule.h>
#import <ProtocolHelper.h>

#define SINGLEVIEWHOST_NIBNAME   @"SingleViewHost"

@class HostableViewController;
@class SwordModule;
@class SearchTextObject;
@class FileRepresentation;

@interface SingleViewHostController : WindowHostController <NSCoding, SubviewHosting> {
}

// initializers
- (id)initForViewType:(ModuleType)aType;
- (id)initWithModule:(SwordModule *)aModule;
- (id)initWithFileRepresentation:(FileRepresentation *)aFileRep;

// methods
- (NSView *)view;
- (void)setView:(NSView *)aView;

// SubviewHosting
- (void)contentViewInitFinished:(HostableViewController *)aView;
- (void)removeSubview:(HostableViewController *)aViewController;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
