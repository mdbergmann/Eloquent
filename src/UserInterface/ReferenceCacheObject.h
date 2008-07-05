//
//  ReferenceCacheObject.h
//  MacSword2
//
//  Created by Manfred Bergmann on 04.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ReferenceCacheObject : NSObject {
    NSString *reference;
    NSString *moduleName;
    NSAttributedString *displayText;
    int numberOfFinds;
}

@property (retain, readwrite) NSString *reference;
@property (retain, readwrite) NSString *moduleName;
@property (retain, readwrite) NSAttributedString *displayText;
@property (readwrite) int numberOfFinds;


+ (ReferenceCacheObject *)referenceCacheObjectForModuleName:(NSString *)aName 
                                            withDisplayText:(NSAttributedString *)aDisplayText 
                                              numberOfFinds:(int)aNumber
                                               andReference:(NSString *)aRef;
- (id)initForModuleName:(NSString *)aName 
        withDisplayText:(NSAttributedString *)aDisplayText 
          numberOfFinds:(int)aNumber
           andReference:(NSString *)aRef;

@end
