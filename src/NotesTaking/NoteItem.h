//
//  NoteItem.h
//  MacSword2
//
//  Created by Manfred Bergmann on 15.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NoteItem : NSObject {
    NSFileWrapper *fileWrapper;
}

- (id)initWithFileWrapper:(NSFileWrapper *)aFileWrapper;

@end
