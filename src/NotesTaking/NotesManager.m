//
//  NotesManager.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "NotesManager.h"
#import "FileRepresentation.h"
#import "globals.h"

@interface NotesManager ()

@property (readwrite, retain) NSString *rootPath;
@property (readwrite, retain) FileRepresentation *rootPathRep;

@end

@implementation NotesManager

@synthesize rootPath;
@synthesize rootPathRep;

#pragma mark - Initialisation

static NotesManager *singleton = nil;
+ (NotesManager *)defaultManager {
    if(singleton == nil) {
        singleton = [[NotesManager alloc] initWithRootPath:DEFAULT_NOTES_PATH];
    }
    return singleton;
}

- (id)initWithRootPath:(NSString *)aPath {
    self = [super init];
    if(self) {
        self.rootPath = aPath;
        self.rootPathRep = [[FileRepresentation alloc] initWithPath:aPath];
        [rootPathRep buildTree];
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

#pragma mark - Methods


- (FileRepresentation *)notesFileRep {
    return rootPathRep;
}

@end
