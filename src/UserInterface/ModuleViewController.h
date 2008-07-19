//
//  ModuleViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <HostableViewController.h>
#import <ProtocolHelper.h>
#import <Indexer.h>

@class SwordModule;

@protocol TextDisplayable
- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType;
@end

@interface ModuleViewController : HostableViewController <NSCoding, MouseTracking> {

    // placeholder for webview or other views depending on nodule tyoe
    IBOutlet NSBox *placeHolderView;
    
    // the module
    SwordModule *module;
    // current reference
    NSString *reference;
    // view search found range
    NSRange viewSearchLastFound;
    // view search direction
    BOOL viewSearchDirectionRight;
}

// --------- properties ---------
@property (retain, readwrite) SwordModule *module;
@property (retain, readwrite) NSString *reference;
@property (readwrite) BOOL viewSearchDirectionRight;

// ---------- methods ---------
- (NSAttributedString *)searchResultStringForQuery:(NSString *)searchQuery numberOfResults:(int *)results;
    
// ---------- Hostable delegate methods ---------
- (void)contentViewInitFinished:(HostableViewController *)aView;

// --------- getter / setter ----------
- (NSString *)reference;
- (void)setReference:(NSString *)aReference;

// Mouse tracking protocol implementation
- (void)mouseEntered:(NSView *)theView;
- (void)mouseExited:(NSView *)theView;

// NSCoding
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
