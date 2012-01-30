//
//  NotesManager.h
//  Eloquent
//
//  Created by Manfred Bergmann on 15.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FileRepresentation;

@interface NotesManager : NSObject {
    NSString *rootPath;
    FileRepresentation *rootPathRep;
}

+ (NotesManager *)defaultManager;
- (id)initWithRootPath:(NSString *)aPath;

- (FileRepresentation *)notesFileRep;
- (FileRepresentation *)fileRepForPath:(NSString *)aFilePath;

@end
