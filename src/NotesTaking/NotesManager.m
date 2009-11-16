//
//  NotesManager.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "NotesManager.h"
#import "globals.h"

@interface NotesManager ()

@property (readwrite, retain) NSString *rootPath;

@end

@implementation NotesManager

@synthesize rootPath;

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
    }
    
    return self;
}

- (void)finalize {
    [super finalize];
}

@end
