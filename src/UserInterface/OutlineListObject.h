//
//  OutlineListObject.h
//  MacSword2
//
//  Created by Manfred Bergmann on 10.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define LISTOBJECTTYPE_MODULESROOT      0
#define LISTOBJECTTYPE_MODULECATEGORY   1
#define LISTOBJECTTYPE_MODULE           2

@interface OutlineListObject : NSObject {
    NSString *displayString;
    int listType;
    id listObject;
}

@property (retain, readwrite) NSString *displayString;
@property (readwrite) int listType;
@property (retain, readwrite) id listObject;

- (id)initWithType:(int)aType andDisplayString:(NSString *)aString;

@end
