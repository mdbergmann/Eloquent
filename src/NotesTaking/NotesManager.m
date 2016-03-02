//
//  NotesManager.m
//  Eloquent
//
//  Created by Manfred Bergmann on 15.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "NotesManager.h"
#import "FileRepresentation.h"
#import "globals.h"
#import "Eloquent-swift.h"

@interface NotesManager ()

@property (readwrite, strong) NSString *rootPath;
@property (readwrite, strong) FileRepresentation *rootPathRep;

- (FileRepresentation *)_fileRepForPath:(NSString *)aFilePath inFolder:(FileRepresentation *)aFolderRep;

@end

@implementation NotesManager

@synthesize rootPath;
@synthesize rootPathRep;

#pragma mark - Initialisation

static NotesManager *singleton = nil;
+ (NotesManager *)defaultManager {
    if(singleton == nil) {
        singleton = [[NotesManager alloc] initWithRootPath:[[FolderUtil urlForNotesFolder] path]];
    }
    return singleton;
}

- (id)initWithRootPath:(NSString *)aPath {
    self = [super init];
    if(self) {
        
        NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithPath:aPath];
        if([wrapper isSymbolicLink]) {
            self.rootPath = [wrapper symbolicLinkDestination];
        } else {
            self.rootPath = aPath;
        }
        self.rootPathRep = [[FileRepresentation alloc] initWithPath:rootPath];

        [rootPathRep buildTree];
    }
    
    return self;
}



#pragma mark - Methods

- (FileRepresentation *)notesFileRep {
    return rootPathRep;
}

- (FileRepresentation *)fileRepForPath:(NSString *)aFilePath {
    return [self _fileRepForPath:aFilePath inFolder:[self rootPathRep]];
}

- (FileRepresentation *)_fileRepForPath:(NSString *)aFilePath inFolder:(FileRepresentation *)aFolderRep {
    for(FileRepresentation *rep in [aFolderRep directoryContent]) {
        if([[rep filePath] isEqualToString:aFilePath]) {
            return rep;
        }
        if([rep isDirectory]) {
            FileRepresentation *found = [self _fileRepForPath:aFilePath inFolder:rep];
            if(found) {
                return found;
            }
        }
    }
    return nil;
}

@end
