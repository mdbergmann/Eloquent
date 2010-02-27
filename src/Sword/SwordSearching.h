//
//  SwordSearching.h
//  MacSword
//
// Copyright 2008 Manfred Bergmann
// Based on code by Will Thimbleby
//

#import <Foundation/Foundation.h>
#import <SwordModule.h>
#import <SwordBible.h>
#import <SwordCommentary.h>
#import <SwordDictionary.h>
#import <SwordBook.h>

#ifdef __cplusplus
#include <swtext.h>
#include <versekey.h>
#endif

@class Indexer;
@class SwordVerseKey;

@protocol IndexCreationProgressing

- (void)addToMaxProgressValue:(double)val;
- (void)setProgressMaxValue:(double)max;
- (void)setProgressCurrentValue:(double)val;
- (void)setProgressIndeterminate:(BOOL)flag;
- (void)incrementProgressBy:(double)increment;

@end

@interface SwordModule(Searching)

- (NSString *)indexOfVerseKey:(SwordVerseKey *)vk;
- (BOOL)hasIndex;
- (void)createIndex;
- (void)createIndexWithProgressIndicator:(id<IndexCreationProgressing>)progressIndicator;
- (void)deleteIndex;
- (void)recreateIndex;
- (void)createIndexThreadedWithDelegate:(id)aDelegate progressIndicator:(id<IndexCreationProgressing>)progressIndicator;
- (void)indexContentsIntoIndex:(Indexer *)indexer;

@end

@interface SwordBible(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer;

@end

@interface SwordCommentary(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer;

@end

@interface SwordDictionary(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer;

@end

@interface SwordBook(Searching)

- (void)indexContentsIntoIndex:(Indexer *)indexer;
- (void)indexContents:(NSString *)treeKey intoIndex:(Indexer *)indexer;
@end