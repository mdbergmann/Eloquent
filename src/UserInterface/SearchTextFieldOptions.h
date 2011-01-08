//
//  SearchTextFieldOptions.h
//  Eloquent
//
//  Created by Manfred Bergmann on 22.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchTextFieldOptions : NSObject {
    BOOL continuous;
    BOOL sendsSearchStringImmediately;
    BOOL sendsWholeSearchString;
}

@property (readwrite) BOOL continuous;
@property (readwrite) BOOL sendsSearchStringImmediately;
@property (readwrite) BOOL sendsWholeSearchString;

@end
