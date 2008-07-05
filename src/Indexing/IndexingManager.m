//
//  IndexingManager.m
//  Eloquent
//
//  Created by Manfred Bergmann on 28.05.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import "IndexingManager.h"

#define INDEXTYPE kSKIndexInverted


@interface IndexingManager (PrivateAPI)

/**
\brief creates a nonexisting empty index for the given parameters
 @param[in] modName: the name of the module.
 @param[in] modType: the type of the module. depending on this, more than one index may be created for the module.
 @return: success YES/NO
 */
- (BOOL)createIndexForModuleName:(NSString *)modName moduleType:(ModuleType)modType;

@end

@implementation IndexingManager (PrivateAPI)

/**
\brief creates a nonexisting empty index for the given parameters
 @param[in] modName: the name of the module.
 @param[in] modType: the type of the module. depending on this, more than one index may be created for the module.
 @return: success YES/NO
 */
- (BOOL)createIndexForModuleName:(NSString *)modName moduleType:(ModuleType)modType {
	return NO;
}

@end


@implementation IndexingManager

/**
\brief this is a singleton
 */
+ (IndexingManager *)sharedManager {
	static IndexingManager *singleton;
	
	if(singleton == nil) {
		singleton = [[IndexingManager alloc] init];
	}
	
	return singleton;	
}

/**
\brief init is called after alloc:. some initialization work can be done here.
 @returns initialized not nil object
 */
- (id)init
{
	MBLOG(MBLOG_DEBUG,@"init of IndexingManager");
	
	self = [super init];
	if(self == nil) {
		MBLOG(MBLOG_ERR,@"cannot alloc IndexingManager!");
	}
	else {
		[self setBaseIndexPath:@""];
	}
	
	return self;
}

/**
\brief dealloc of this class is called on closing this document
 */
- (void)dealloc {
	MBLOG(MBLOG_DEBUG,@"dealloc of IndexingManager");
	
	[self setBaseIndexPath:nil];
	
	// dealloc object
	[super dealloc];
}

- (void)setBaseIndexPath:(NSString *)aPath {
	[aPath retain];
	[baseIndexPath release];
	baseIndexPath = aPath;
}

- (NSString *)baseIndexPath {
	return baseIndexPath;
}

/**
\brief returns the path of the index for the given module name and type
 @return NSString that is autoreleased
 */
- (NSString *)indexPathForModuleName:(NSString *)aModName textType:(NSString *)aModType {
    NSString *ret = nil;
    
    NSString *folderPath = [self indexFolderPathForModuleName:aModName];
    if(folderPath != nil) {
        ret = [folderPath stringByAppendingPathComponent:aModType];
    } else {
        MBLOG(MBLOG_ERR, @"Cannot get index folder path!");
    }
    
    return ret;
}

/**
\brief returns the path of the index for the given module name
 @return NSString that is autoreleased
 */
- (NSString *)indexFolderPathForModuleName:(NSString *)aModName {
    NSString *ret = nil;

    // we currently only have content types
	NSString *indexName = [NSString stringWithFormat:@"index-%@", aModName];
	ret = [baseIndexPath stringByAppendingPathComponent:indexName];

    return ret;
}

/**
\brief checks whether an index already exists for the given module name and type
 @param[in] modName: the name of the module.
 @param[in] modType: the type of the module. depending on this, more than one index may be created for the module.
 @return: YES/NO
 */
- (BOOL)indexExistsForModuleName:(NSString *)aModName {
	NSFileManager *fm = [NSFileManager defaultManager];	

    NSString *indexPath = [self indexFolderPathForModuleName:aModName];
	
	return [fm fileExistsAtPath:indexPath];
}

@end
