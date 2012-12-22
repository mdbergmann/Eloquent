//
//  IndexingManager.m
//  Eloquent
//
//  Created by Manfred Bergmann on 28.05.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import "IndexingManager.h"
#import "globals.h"
#import "ObjCSword/SwordManager.h"
#import "SearchBookSet.h"
#import "ObjCSword/SwordVerseKey.h"
#import "Indexer.h"
#import "SwordModule+SearchKitIndex.h"

@interface IndexingManager ()

@property (retain, readwrite) NSTimer *timer;
@property (retain, readwrite) NSMutableDictionary *indexerRegistrat;

/**
\brief creates a non existing empty index for the given parameters
 @param[in] modName: the name of the module.
 @param[in] modType: the type of the module. depending on this, more than one index may be created for the module.
 @return: success YES/NO
 */
- (BOOL)createIndexForModuleName:(NSString *)modName moduleType:(int)modType;

/**
 this method can be run in separate thread for checking index validity
 */
- (void)runIndexCheck;
- (void)detachedIndexCheckRunner;

@end

@implementation IndexingManager

@synthesize baseIndexPath;
@synthesize swordManager;
@synthesize interval;
@synthesize stalled;
@synthesize timer;
@synthesize searchBookSets;
@synthesize indexerRegistrat;

/**
\brief creates a non existing empty index for the given parameters
 @param[in] modName: the name of the module.
 @param[in] modType: the type of the module. depending on this, more than one index may be created for the module.
 @return: success YES/NO
 */
- (BOOL)createIndexForModuleName:(NSString *)modName moduleType:(int)modType {
	return NO;
}

/**
 this method can be run in separate thread for checking index validity
 */
- (void)runIndexCheck {
    if(!stalled) {
        [NSThread detachNewThreadSelector:@selector(detachedIndexCheckRunner) toTarget:self withObject:nil];    
    }
}

- (void)detachedIndexCheckRunner {
    
    // set thread priority
    [NSThread setThreadPriority:0.1];
    if([indexCheckLock tryLock]) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // make copy of array
        NSArray *modNames = [NSArray arrayWithArray:[swordManager moduleNames]];
        for(NSString *name in modNames) {
            CocoLog(LEVEL_DEBUG, @"checking index for module: %@", name);
            SwordModule *mod = [swordManager moduleWithName:name];
            if(![mod hasSKSearchIndex]) {
                CocoLog(LEVEL_DEBUG, @"creating index for module: %@", name);
                [mod createSKSearchIndex];
            }
        }
        
        [pool drain];
        [indexCheckLock unlock];
    }    
}

/**
\brief this is a singleton
 */
+ (IndexingManager *)sharedManager {
	static IndexingManager *singleton = nil;
	
	if(singleton == nil) {
		singleton = [[IndexingManager alloc] init];
	}
	
	return singleton;	
}

/**
\brief init is called after alloc:. some initialization work can be done here.
 @returns initialized not nil object
 */
- (id)init {
	CocoLog(LEVEL_DEBUG, @"init of IndexingManager");
	
	self = [super init];
	if(self == nil) {
		CocoLog(LEVEL_ERR, @"cannot alloc IndexingManager!");
	}
	else {
		[self setBaseIndexPath:@""];
        [self setInterval:30];
        [self setStalled:NO];
        [self setIndexerRegistrat:[NSMutableDictionary dictionary]];
        indexCheckLock = [[NSLock alloc] init];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if([fm fileExistsAtPath:DEFAULT_SEARCHBOOKSET_PATH]) {
            // load
            [self setSearchBookSets:[NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:DEFAULT_SEARCHBOOKSET_PATH]]];
        } else {
            // build default search book sets
            NSMutableArray *bookSets = [NSMutableArray array];
            // All
            SearchBookSet *set = [SearchBookSet searchBookSetWithName:NSLocalizedString(@"All", @"")];
            [set setIsPredefined:YES];
            [bookSets addObject:set]; // empty for all
            // Torah
            set = [SearchBookSet searchBookSetWithName:NSLocalizedString(@"Law", @"")];
            [set setIsPredefined:YES];
            [bookSets addObject:set];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Gen"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Exod"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Lev"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Num"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Deut"] osisBookName]];
            // Prophets
            set = [SearchBookSet searchBookSetWithName:NSLocalizedString(@"Prophets", @"")];
            [set setIsPredefined:YES];            
            [bookSets addObject:set];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Josh"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Judg"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"1Sam"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"2Sam"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"1Kgs"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"2Kgs"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Isa"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Jer"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Ezek"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Hos"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Joel"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Amos"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Obad"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Jonah"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Mic"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Nah"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Hab"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Zeph"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Hag"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Zech"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Mal"] osisBookName]];
            // Scriptures
            set = [SearchBookSet searchBookSetWithName:NSLocalizedString(@"Scriptures", @"")];
            [set setIsPredefined:YES];
            [bookSets addObject:set];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Ruth"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"1Chr"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"2Chr"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Ezra"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Neh"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Esth"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Job"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Ps"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Prov"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Eccl"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Song"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Lam"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Dan"] osisBookName]];
            // Evangelien
            set = [SearchBookSet searchBookSetWithName:NSLocalizedString(@"Gospels", @"")];
            [set setIsPredefined:YES];
            [bookSets addObject:set];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Matt"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Mark"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Luke"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"John"] osisBookName]];
            // Briefe
            set = [SearchBookSet searchBookSetWithName:NSLocalizedString(@"Letters", @"")];
            [set setIsPredefined:YES];
            [bookSets addObject:set];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Rom"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"1Cor"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"2Cor"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Gal"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Eph"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Col"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Phil"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"1Thess"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"2Thess"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"1Tim"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"2Tim"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Titus"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Phlm"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Heb"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Jas"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"1Pet"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"2Pet"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"1John"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"2John"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"3John"] osisBookName]];
            [set addBook:[[SwordVerseKey verseKeyWithRef:@"Jude"] osisBookName]];
            
            // store
            [NSKeyedArchiver archiveRootObject:bookSets toFile:DEFAULT_SEARCHBOOKSET_PATH];
            // take it
            [self setSearchBookSets:bookSets];
        }
	}
	
	return self;
}

- (void)dealloc {
    [indexCheckLock release];
    [baseIndexPath release];
    [swordManager release];
    [timer release];
    [searchBookSets release];
    [indexerRegistrat release];

    [super dealloc];
}

- (void)storeSearchBookSets {
    // store
    [NSKeyedArchiver archiveRootObject:searchBookSets toFile:DEFAULT_SEARCHBOOKSET_PATH];
}

/**
 \brief open or create index for the given parameters
 @return SKIndexRef or NULL on error
 */
- (SKIndexRef)openOrCreateIndexForModName:(NSString *)aModName textType:(NSString *)aModType {
	// we do not accept nil values
	if(aModName == nil) {
		aModName = @"";
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];    
    NSString *indexFolder = [self indexFolderPathForModuleName:aModName];
    if([fm fileExistsAtPath:indexFolder] == NO) {
        // create index folder
        [fm createDirectoryAtPath:indexFolder withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
	// construct index for content
    NSString *indexName = [NSString stringWithFormat:@"%@-%@", aModName, aModType];
	SKIndexRef indexRef;
	NSString *indexPath = [self indexPathForModuleName:aModName textType:aModType];
	NSURL *indexURL = [NSURL fileURLWithPath:indexPath];
	if([fm fileExistsAtPath:indexPath] == YES) {
		// open index
		indexRef = SKIndexOpenWithURL((CFURLRef)indexURL, (CFStringRef)indexName, NO);
	} else {
        // create properties for indexing
        NSMutableDictionary *props = [NSMutableDictionary dictionary];
        [props setObject:(NSNumber *)kCFBooleanTrue forKey:(NSString *)kSKProximityIndexing];
        
		// create index
		indexRef = SKIndexCreateWithURL((CFURLRef)indexURL, 
										(CFStringRef)indexName, 
										kSKIndexInvertedVector, 
										(CFDictionaryRef)props);
	}
	
	return indexRef;
}

/**
 the manager should be used to aquire indexers. the manager will keep track of already opened indexers and not open new ones if not necessary.
 */
- (Indexer *)indexerForModuleName:(NSString *)aName moduleType:(int)aType {
    Indexer *ret = [indexerRegistrat objectForKey:aName];
    if(!ret) {
        ret = [Indexer indexerWithModuleName:aName moduleType:aType];
        [indexerRegistrat setObject:ret forKey:aName];
    }
    
    if(ret) {
        [ret setAccessCounter:[ret accessCounter]+1];
    }
    
    return ret;
}

/**
 the manager should also be used to close the index.
 it only closes an index if no other instance is using it any longer.
 */
- (void)closeIndexer:(Indexer *)aIndexer {
    // only close if no other instance is holding a reference
    [aIndexer setAccessCounter:[aIndexer accessCounter]-1];
    if([aIndexer accessCounter] == 0) {
        [aIndexer close];
        // and remove from registrat
        [indexerRegistrat removeObjectForKey:[aIndexer modName]];
    }
}

/**
 calling this method will trigger checking for modules that do not have a valid index
 in a separate thread.
 */
- (void)triggerBackgroundIndexCheck {
    
    // check for swordManager
    if(swordManager == nil) {    
        CocoLog(LEVEL_ERR, @"[IndexingManager -triggerBackgroundIndexCheck] no SwordManager instance available!");
        return;
    }
    
	// run every $interval seconds
    CocoLog(LEVEL_INFO, @"[IndexingManager -triggerBackgroundIndexCheck] starting index check timer");
    if(![timer isValid] || timer == nil) {
        CocoLog(LEVEL_DEBUG, @"[IndexingManager -triggerBackgroundIndexCheck] starting new timer");
        NSTimer *t = [NSTimer scheduledTimerWithTimeInterval:(float)interval
                                                      target:self 
                                                    selector:@selector(runIndexCheck) 
                                                    userInfo:nil 
                                                     repeats:YES];
        [self setTimer:t];
    } else {
        CocoLog(LEVEL_WARN, @"[IndexingManager -triggerBackgroundIndexCheck] timer still valid!");
    }
}

/**
 stops the background indexer and removes the timer
 */
- (void)invalidateBackgroundIndexer {
    if(timer) {
        [timer invalidate];
    }
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
        CocoLog(LEVEL_ERR, @"[IndexingManager -indexPathForModuleName:] Cannot get index folder path!");
    }
    
    return ret;
}

/**
\brief returns the path of the index for the given module name
 @return NSString that is autoreleased
 */
- (NSString *)indexFolderPathForModuleName:(NSString *)aModName {
    // we currently only have content types
	NSString *indexName = [NSString stringWithFormat:@"index-%@", aModName];

    NSString *ret = [baseIndexPath stringByAppendingPathComponent:indexName];
    return ret;
}

/**
\brief checks whether an index already exists for the given module name and type
 @param[in] modName: the name of the module.
 @return: YES/NO
 */
- (BOOL)indexExistsForModuleName:(NSString *)aModName {
	BOOL isDir = NO;
	NSFileManager *fm = [NSFileManager defaultManager];
    NSString *indexPath	= [self indexFolderPathForModuleName:aModName];
	
	return (([fm fileExistsAtPath:indexPath isDirectory:&isDir] && isDir == YES) ? YES : NO);
}

/**
 removed the index for the given module name
 */
- (BOOL)removeIndexForModuleName:(NSString *)modName {
    BOOL ret = YES;
    
	NSFileManager *fm = [NSFileManager defaultManager];
    NSString *indexPath	= [self indexFolderPathForModuleName:modName];

	if([fm fileExistsAtPath:indexPath]) {
        ret = [fm removeItemAtPath:indexPath error:NULL];
		if(!ret) {
            CocoLog(LEVEL_ERR, @"[IndexingManager -removeIndexForModuleName:] could not remove index for module: %@", modName);
        }
    }
    
    return ret;
}

@end
