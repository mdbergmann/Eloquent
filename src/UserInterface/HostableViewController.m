//
//  HostableViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 17.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HostableViewController.h"
#import "WindowHostController.h"
#import "SearchTextFieldOptions.h"

@implementation HostableViewController

@dynamic delegate;
@synthesize hostingDelegate;
@synthesize viewLoaded;
@synthesize searchType;
@synthesize searchString;
@synthesize showingRSBPreferred;

- (id)init {
    self = [super init];
    if(self) {
        viewLoaded = NO;
        isLoadingCompleteReported = NO;
        self.hostingDelegate = nil;
        self.searchType = ReferenceSearchType;
        self.searchString = @"";
    }
    
    return self;
}

- (void)dealloc {
    [searchString release];
    [super dealloc];
}

- (id)delegate {
    return delegate;
}

- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate;
}

- (void)adaptUIToHost {
}

- (void)reportLoadingComplete {
    if(delegate && isLoadingCompleteReported == NO) {
        if([delegate respondsToSelector:@selector(contentViewInitFinished:)]) {
            [delegate performSelector:@selector(contentViewInitFinished:) withObject:self];
            isLoadingCompleteReported = YES;
        } else {
            CocoLog(LEVEL_WARN, @"delegate does not respond to selector!");
        }
    } else {
        CocoLog(LEVEL_WARN, @"no delegate set!");        
    }
}

- (void)removeFromSuperview {
    if(delegate) {
        if([delegate respondsToSelector:@selector(removeSubview:)]) {
            [delegate performSelector:@selector(removeSubview:) withObject:self];
        } else {
            CocoLog(LEVEL_WARN, @"delegate does not respond to selector!");
        }
    } else {
        CocoLog(LEVEL_WARN, @"no delegate set!");        
    }    
}

#pragma mark - MouseTracking protocol

- (void)mouseEnteredView:(NSView *)theView {
}

- (void)mouseExitedView:(NSView *)theView {
}

#pragma mark - HostViewDelegate protocol

- (NSString *)title {
    return @"";
}

- (void)prepareContentForHost:(WindowHostController *)aHostController {
    [self setHostingDelegate:aHostController];
}

- (NSView *)topAccessoryView {
    return nil;
}

- (NSView *)rightAccessoryView {
    return nil;
}

- (BOOL)showsRightSideBar {
    return showingRSBPreferred;
}

- (void)searchTypeChanged:(SearchType)aSearchType withSearchString:(NSString *)aSearchString {
    self.searchType = aSearchType;
    [self searchStringChanged:aSearchString];
}

- (void)searchStringChanged:(NSString *)aSearchString {    
    self.searchString = aSearchString;
}

- (void)forceReload {
}

- (SearchTextFieldOptions *)searchFieldOptions {
    SearchTextFieldOptions *options = [[SearchTextFieldOptions alloc] init];
    [options setContinuous:NO];
    [options setSendsSearchStringImmediately:NO];
    [options setSendsWholeSearchString:YES];
    return options;
}

- (SearchType)preferredSearchType {
    return searchType;
}

- (BOOL)enableReferenceSearch {
    return YES;
}

- (BOOL)enableIndexedSearch {
    return YES;
}

- (BOOL)enableAddBookmarks {
    return NO;
}

- (BOOL)enableForceReload {
    return YES;
}

- (BOOL)hasUnsavedContent {
    return NO;
}

- (void)saveContent {
}

@end
