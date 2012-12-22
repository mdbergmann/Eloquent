//
//  IndexingManager.h
//  Eloquent
//
//  Created by Manfred Bergmann on 28.05.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@class SwordModule, SwordManager;
@class Indexer;

@interface IndexingManager : NSObject {
	NSString *baseIndexPath;
    
    /** interval in seconds for timer to fire */
    int interval;
    
    /** timer for background indexer */
    NSTimer *timer;
    
    /** this indexing manager has a dedicated SwordManager instance */
    SwordManager *swordManager;
    
    BOOL stalled;
    
    /** don't start two threads */
    NSLock *indexCheckLock;
    
    /** book sets for indexed search */
    NSMutableArray *searchBookSets;
    
    /** registers open indexers */
    NSMutableDictionary *indexerRegistrat;
}

@property (retain, readwrite) NSString *baseIndexPath;
@property (retain, readwrite) SwordManager *swordManager;
@property (readwrite) int interval;
@property (readwrite) BOOL stalled;
@property (retain, readwrite) NSMutableArray *searchBookSets;

/**
 \brief singleton convenient allocator and getter of instance
 */
+ (IndexingManager *)sharedManager;

// init
- (id)init;

/**
 \brief open or create index for the given parameters
 @return SKIndexRef or NULL on error
 */
- (SKIndexRef)openOrCreateIndexForModName:(NSString *)aModName textType:(NSString *)aModType;

/** stores to disk */
- (void)storeSearchBookSets;

/**
 calling this method will trigger checking for modules that do not have a valid index
 in a separate thread.
 */
- (void)triggerBackgroundIndexCheck;

/**
 stops the background indexer and removes the timer
 */
- (void)invalidateBackgroundIndexer;

/**
 the manager should be used to aquire indexers. the manager will keep track of already opened indexers and not open new ones if not necessary.
 */
- (Indexer *)indexerForModuleName:(NSString *)aName moduleType:(int)aType;
/**
 the manager should also be used to close the index.
 it only closes an index if no other instance is using it any longer.
 */
- (void)closeIndexer:(Indexer *)aIndexer;

/**
\brief returns the path of the index folder for the given module name
 @return NSString that is autoreleased
 */
- (NSString *)indexPathForModuleName:(NSString *)aModName textType:(NSString *)aModType;

/**
 \brief returns the path of the index folder for the given module name
 @return NSString that is autoreleased
 */
- (NSString *)indexFolderPathForModuleName:(NSString *)aModName;

/**
\brief checks whether an index already exists for the given module name and type
 @param[in] modName: the name of the module.
 @param[in] modType: the type of the module. depending on this, more than one index may be created for the module.
 @return: YES/NO
 */
- (BOOL)indexExistsForModuleName:(NSString *)modName;

/**
 removed the index for the given module name
 */
- (BOOL)removeIndexForModuleName:(NSString *)modName;

@end
