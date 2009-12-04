//
//  FileRepresentation.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "FileRepresentation.h"

@interface FileRepresentation ()

@property (readwrite, retain) NSFileWrapper *fileWrapper;
@property (readwrite, retain) NSMutableDictionary *directoryContentWrapper;
@property (readwrite) FileRepresentation *parent;

@end

@implementation FileRepresentation

@synthesize filePath;
@synthesize fileWrapper;
@synthesize directoryContentWrapper;
@synthesize parent;


+ (FileRepresentation *)createWithName:(NSString *)aName isFolder:(BOOL)isFolder destinationDirectoryRep:(FileRepresentation *)aFolderRep {
    if(![aFolderRep isDirectory]) {
        MBLOG(MBLOG_WARN, @"[FileRepresentation +createWithName::] destination is no directory!");
        [NSException raise:@"NoDirectory" format:@"Given inFolder FileRepresentation is no folder!"];
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *absFileName = [[aFolderRep filePath] stringByAppendingPathComponent:aName];
    BOOL createSuccess = YES;
    if(!isFolder) {
        createSuccess = [fm createFileAtPath:absFileName contents:[NSData data] attributes:nil];
    } else {
        createSuccess = [fm createDirectoryAtPath:absFileName attributes:nil];        
    }
    if(createSuccess) {
        FileRepresentation *fileRep = [[FileRepresentation alloc] initWithPath:absFileName];
        [aFolderRep addFileRepresentation:fileRep];
        return fileRep;
    }
    return nil;
}

+ (BOOL)copyComplete:(FileRepresentation *)source to:(FileRepresentation *)destDirectoryRep {
    if(![destDirectoryRep isDirectory]) {
        MBLOG(MBLOG_WARN, @"[FileRepresentation +moveComplete::] destination is no directory!");
        return NO;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // copy
    NSString *destinationPath = [[destDirectoryRep filePath] stringByAppendingPathComponent:[source name]];
    if(![fm copyItemAtPath:[source filePath] toPath:destinationPath error:NULL]) {
        MBLOGV(MBLOG_ERR, @"[FileRepresentation +copyComplete::] unable to copy file %@ to path %@", [source filePath], destinationPath);
        return NO;
    }
    FileRepresentation *destinationFileRep = [[FileRepresentation alloc] initWithPath:destinationPath];
    [destDirectoryRep buildTree];
    
    // add destination file rep to dest folder rep
    [destDirectoryRep addFileRepresentation:destinationFileRep];
    
    return YES;
}

+ (BOOL)moveComplete:(FileRepresentation *)source to:(FileRepresentation *)destDirectoryRep {
    if(![destDirectoryRep isDirectory]) {
        MBLOG(MBLOG_WARN, @"[FileRepresentation +moveComplete::] destination is no directory!");
        return NO;
    }

    // copy
    if(![FileRepresentation copyComplete:source to:destDirectoryRep]) {
        return NO;
    }
    
    // delete source
    if(![FileRepresentation deleteComplete:source]) {
        MBLOGV(MBLOG_ERR, @"[FileRepresentation +moveComplete::] unable to delete file %@", [source filePath]);        
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
        self.fileWrapper = [[NSFileWrapper alloc] initWithPath:aPath];
        self.directoryContentWrapper = [NSMutableDictionary dictionary];
        self.parent = nil;
    }
    return self;
}

- (void)finalize {
    [super finalize];
}

- (NSString *)name {
    return [fileWrapper filename];
}

- (void)setName:(NSString *)aName {
    NSString *newPath = [[filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:aName];
    // set name is a file move operation
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm moveItemAtPath:filePath toPath:newPath error:NULL]) {
        self.filePath = newPath;
        self.fileWrapper = [[NSFileWrapper alloc] initWithPath:newPath];
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
    return [directoryContentWrapper allValues];
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
            FileRepresentation *subFileItem = [[FileRepresentation alloc] initWithPath:subFilePath];
            [self addFileRepresentation:subFileItem];
            [subFileItem buildTree];
        }
    }
}

@end
