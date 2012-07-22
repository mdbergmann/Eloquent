//
//  FileRepresentation.m
//  Eloquent
//
//  Created by Manfred Bergmann on 15.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "FileRepresentation.h"


@interface FileRepresentation ()

@property (readwrite, retain) NSFileWrapper *fileWrapper;
@property (readwrite, retain) NSMutableDictionary *directoryContentWrapper;
@property (readwrite, assign) FileRepresentation *parent;

+ (NSString *)findFileNameForPreferredName:(NSString *)aFileName atFolder:(NSString *)aFolder;

@end

@implementation FileRepresentation

@synthesize filePath;
@synthesize fileWrapper;
@synthesize directoryContentWrapper;
@synthesize parent;


+ (NSString *)findFileNameForPreferredName:(NSString *)aFileName atFolder:(NSString *)aFolder {
    NSString *pathExtension = [aFileName pathExtension];
    NSString *fileName = [aFileName stringByDeletingPathExtension];
    
    NSFileManager *fm = [NSFileManager defaultManager];    
    NSString *absPath = [aFolder stringByAppendingPathComponent:aFileName];
    int i = 1;
    while([fm fileExistsAtPath:absPath]) {
        if([pathExtension length] > 0) {
            absPath = [aFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%i.%@", fileName, i, pathExtension]];
        } else {
            absPath = [aFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%i", aFileName, i]];
        }
        i++;
    }
    return [absPath lastPathComponent];
}

+ (FileRepresentation *)createWithName:(NSString *)aName isFolder:(BOOL)isFolder destinationDirectoryRep:(FileRepresentation *)aFolderRep {
    if(![aFolderRep isDirectory]) {
        CocoLog(LEVEL_WARN, @"destination is no directory!");
        [NSException raise:@"NoDirectory" format:@"Given inFolder FileRepresentation is no folder!"];
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *fileName = [FileRepresentation findFileNameForPreferredName:aName atFolder:[aFolderRep filePath]];
    NSString *absFileName = [[aFolderRep filePath] stringByAppendingPathComponent:fileName];
    BOOL createSuccess;
    if(!isFolder) {
        createSuccess = [fm createFileAtPath:absFileName contents:[NSData data] attributes:nil];
    } else {
        createSuccess = [fm createDirectoryAtPath:absFileName withIntermediateDirectories:NO attributes:nil error:NULL];        
    }
    if(createSuccess) {
        FileRepresentation *fileRep = [[[FileRepresentation alloc] initWithPath:absFileName] autorelease];
        [aFolderRep addFileRepresentation:fileRep];
        return fileRep;
    }
    return nil;
}

+ (BOOL)copyComplete:(FileRepresentation *)source to:(FileRepresentation *)destDirectoryRep {
    if(![destDirectoryRep isDirectory]) {
        CocoLog(LEVEL_WARN, @"destination is no directory!");
        return NO;
    }
    
    if([[[source parent] filePath] isEqualToString:[destDirectoryRep filePath]]) {
        // no need to copy, it is the same path
        return NO;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // copy
    NSString *fileName = [FileRepresentation findFileNameForPreferredName:[source name] atFolder:[destDirectoryRep filePath]];    
    NSString *destinationPath = [[destDirectoryRep filePath] stringByAppendingPathComponent:fileName];
    if(![fm copyItemAtPath:[source filePath] toPath:destinationPath error:NULL]) {
        CocoLog(LEVEL_ERR, @"unable to copy file %@ to path %@", [source filePath], destinationPath);
        return NO;
    }
    FileRepresentation *destinationFileRep = [[FileRepresentation alloc] initWithPath:destinationPath];
    if([destinationFileRep isDirectory]) {
        [destinationFileRep buildTree];
    }
    [destDirectoryRep addFileRepresentation:destinationFileRep];
    
    return YES;
}

+ (BOOL)moveComplete:(FileRepresentation *)source to:(FileRepresentation *)destDirectoryRep {
    if(![destDirectoryRep isDirectory]) {
        CocoLog(LEVEL_WARN, @"destination is no directory!");
        return NO;
    }

    // copy
    if(![FileRepresentation copyComplete:source to:destDirectoryRep]) {
        return NO;
    }
    
    // delete source
    if(![FileRepresentation deleteComplete:source]) {
        CocoLog(LEVEL_ERR, @"unable to delete file %@", [source filePath]);        
        return NO;
    }
        
    return YES;
}

+ (BOOL)deleteComplete:(FileRepresentation *)fileRep {
    // remove from parent
    if([fileRep parent] && [[fileRep parent] isDirectory]) {
        [[fileRep parent] removeFileRepresentation:fileRep];
    }
    
    // delete
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm removeItemAtPath:[fileRep filePath] error:NULL];
}

#pragma mark - Initialisation

- (id)init {
    return [super init];
}

- (id)initWithPath:(NSString *)aPath {
    self = [super init];
    if(self) {
        self.filePath = aPath;
        self.fileWrapper = [[[NSFileWrapper alloc] initWithPath:aPath] autorelease];
        self.directoryContentWrapper = [NSMutableDictionary dictionary];
        self.parent = nil;
    }
    return self;
}

- (void)dealloc {
    [filePath release];
    [fileWrapper release];
    [directoryContentWrapper release];
    [super dealloc];
}

- (NSString *)name {
    return [fileWrapper filename];
}

- (NSString *)description {
    return [self name];
}

- (NSComparisonResult)compare:(FileRepresentation *)aFileRep {
    return [[self name] compare:[aFileRep name]];
}

- (void)setName:(NSString *)aName {
    NSString *newPath = [[filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:aName];
    // set name is a file move operation
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm moveItemAtPath:filePath toPath:newPath error:NULL]) {
        self.filePath = newPath;
        self.fileWrapper = [[[NSFileWrapper alloc] initWithPath:newPath] autorelease];
    } else {
        @throw [NSException exceptionWithName:@"UnableToRenameFile" reason:@"" userInfo:nil];
    }
}

# pragma mark - Regular file

- (BOOL)isFile {
    return [fileWrapper isRegularFile];
}

- (NSData *)fileContent {
    return[NSData dataWithContentsOfFile:[self filePath]];
}

- (void)setFileContent:(NSData *)aData {
    [aData writeToFile:[self filePath] atomically:YES];
}

#pragma mark - Directory

- (BOOL)isDirectory {
    return [fileWrapper isDirectory];
}

- (NSArray *)directoryContent {
    return [[directoryContentWrapper allValues] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)addFileRepresentation:(FileRepresentation *)anItem {
    [directoryContentWrapper setObject:anItem forKey:[anItem filePath]];
    [anItem setParent:self];
}

- (void)removeFileRepresentation:(FileRepresentation *)anItem {
    [directoryContentWrapper removeObjectForKey:[anItem filePath]];
    [anItem setParent:nil];
}

- (void)buildTree {
    if([self isDirectory]) {
        [directoryContentWrapper removeAllObjects];
        
        for(NSFileWrapper *subWrapper in [[fileWrapper fileWrappers] allValues]) {
            NSString *subFilePath = [self.filePath stringByAppendingPathComponent:[subWrapper filename]];
            FileRepresentation *subFileItem = [[[FileRepresentation alloc] initWithPath:subFilePath] autorelease];

            // only add directories or .rtf files
            if([subFileItem isDirectory] || [[subFileItem name] hasSuffix:@".rtf"]) {
                [self addFileRepresentation:subFileItem];                
            }
            [subFileItem buildTree];
        }
    }
}

@end
