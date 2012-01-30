//
//  SearchOptionsViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 14.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <HostableViewController.h>
#import <Indexer.h>

@interface SearchOptionsViewController : HostableViewController {
    
    IBOutlet NSView *referenceSearchOptionsView;
    IBOutlet NSView *indexSearchOptionsView;
    IBOutlet NSView *viewSearchOptionsView;
    
    IBOutlet id target;    
    
    NSSize referenceSearchOptionsViewSize;
    NSSize indexSearchOptionsViewSize;
    NSSize viewSearchOptionsViewSize;    
}

@property (assign, readwrite) id target;

// initializers
- (id)initWithDelegate:(id)aDelegate;
- (id)initWithDelegate:(id)aDelegate andTarget:(id)aTarget;

// methods
- (NSView *)optionsViewForSearchType:(SearchType)aType;
- (NSSize)optionsViewSizeForSearchType:(SearchType)aType;

@end
