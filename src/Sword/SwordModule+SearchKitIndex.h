//
//  SwordSearching.h
//  Eloquent
//
// Copyright 2008 Manfred Bergmann
// Based on code by Will Thimbleby
//

#import <Foundation/Foundation.h>
#import <ObjCSword/SwordModule.h>
#import <ObjCSword/SwordBible.h>
#import <ObjCSword/SwordCommentary.h>
#import <ObjCSword/SwordDictionary.h>
#import <ObjCSword/SwordBook.h>

@class Indexer;
@class SwordVerseKey;

@protocol IndexCreationProgressing

- (void)addToMaxProgressValue:(double)val;
- (void)setProgressMaxValue:(double)max;
- (void)setProgressCurrentValue:(double)val;
- (void)setProgressIndeterminate:(BOOL)flag;
- (void)incrementProgressBy:(double)increment;

@end

@interface SwordModule(SearchKitIndex)

- (BOOL)hasSKSearchIndex;
- (void)createSKSearchIndex;
- (void)createSKSearchIndexWithProgressIndicator:(id<IndexCreationProgressing>)progressIndicator;
- (void)deleteSKSearchIndex;
- (void)recreateSKSearchIndex;
- (void)createSKSearchIndexThreadedWithDelegate:(id)aDelegate progressIndicator:(id<IndexCreationProgressing>)progressIndicator;
- (NSArray *)performSKIndexSearch:(NSString *)searchString;
- (NSArray *)performSKIndexSearch:(NSString *)searchString constrains:(id)constrains maxResults:(int)maxResults;

@end
