//
//  ModuleViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ModuleViewController.h"
#import "SwordManager.h"

@implementation ModuleViewController

#pragma mark - getter/setter

@synthesize module;
@dynamic reference;

- (NSString *)reference {
    return reference;
}

- (void)setReference:(NSString *)aReference {
    [aReference retain];
    [reference release];
    reference = aReference;
}

#pragma mark - initializers

- (id)init {
    self = [super init];
    if(self) {
    }
    
    return self;
}

#pragma mark - methods

/**
 Searches in index for the given searchQuery.
 Generates NSAttributedString to be displayed in NSTextView
 @param[in] searchQuery
 @param[out] number of verses found
 @return attributed string
 */
- (NSAttributedString *)searchResultStringForQuery:(NSString *)searchQuery numberOfResults:(int *)results {
    // abstract method, sub classes should override
    return nil;
}

#pragma mark - Hostable delegate methods

- (void)contentViewInitFinished:(HostableViewController *)aView {
    
}

- (NSString *)label {
    if(module != nil) {
        return [module name];
    }
    
    return @"ModuleView";
}

#pragma mark - mouse tracking protocol

- (void)mouseEntered:(NSView *)theView {
    MBLOG(MBLOG_DEBUG, @"[ModuleViewController - mouseEntered]");
}

- (void)mouseExited:(NSView *)theView {
    MBLOG(MBLOG_DEBUG, @"[ModuleViewController - mouseExited]");
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        // decode module name
        NSString *moduleName = [decoder decodeObjectForKey:@"ModuleNameEncoded"];
        // set module
        self.module = [[SwordManager defaultManager] moduleWithName:moduleName];
        // decode reference
        self.reference = [decoder decodeObjectForKey:@"ReferenceEncoded"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode reference
    [encoder encodeObject:reference forKey:@"ReferenceEncoded"];
    // encode module name
    [encoder encodeObject:[module name] forKey:@"ModuleNameEncoded"];
}

@end
