//
//  ReferenceCacheObject.m
//  MacSword2
//
//  Created by Manfred Bergmann on 04.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ReferenceCacheObject.h"


@implementation ReferenceCacheObject

@synthesize reference;
@synthesize moduleName;
@synthesize displayText;
@synthesize numberOfFinds;

+ (ReferenceCacheObject *)referenceCacheObjectForModuleName:(NSString *)aName 
                                            withDisplayText:(NSAttributedString *)aDisplayText 
                                              numberOfFinds:(int)aNumber
                                               andReference:(NSString *)aRef {
    return [[[ReferenceCacheObject alloc] initForModuleName:aName withDisplayText:aDisplayText numberOfFinds:aNumber andReference:aRef] autorelease];
}

- (id)initForModuleName:(NSString *)aName 
        withDisplayText:(NSAttributedString *)aDisplayText 
          numberOfFinds:(int)aNumber
           andReference:(NSString *)aRef {
    self = [super init];
    if(self) {
        self.reference = aRef;
        self.moduleName = aName;
        self.numberOfFinds = aNumber;
        self.displayText = aDisplayText;
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

/** for comparison */
- (NSComparisonResult)compare:(ReferenceCacheObject *)anObject {
    return [[self reference] compare:[anObject reference]];
}

@end
