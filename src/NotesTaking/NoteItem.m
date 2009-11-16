//
//  NoteItem.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "NoteItem.h"

@interface NoteItem ()

@property (readwrite, retain) NSFileWrapper *fileWrapper;

@end

@implementation NoteItem

@synthesize fileWrapper;

- (id)init {
    return [super init];
}

- (id)initWithFileWrapper:(NSFileWrapper *)aFileWrapper {
    self = [super init];
    if(self) {
        self.fileWrapper = aFileWrapper;
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

@end
