//
//  MatchResult.h
//  CocoPCRE
//
//  Created by Manfred Bergmann on 17.05.06.
//  Copyright 2006 mabe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 \brief MatchResult is a class that stores match results of a pattern matches as an array of substrings.
 If the array of substrings is empty, there is no match.
*/
@interface MatchResult : NSObject  {
	NSMutableArray *listOfMatches;
}

+ (id)matchResult;
+ (id)matchResultWithMatches:(NSArray *)list;

- (id)initWithMatches:(NSArray *)list;

- (void)addMatch:(NSString *)substring;

- (void)setMatches:(NSArray *)list;
- (NSArray *)matches;
- (NSString *)matchAtIndex:(int)index;
- (int)numberOfMatches;

@end
