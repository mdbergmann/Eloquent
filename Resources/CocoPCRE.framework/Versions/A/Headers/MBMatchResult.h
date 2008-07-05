//
//  MBMatchResult.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 17.05.06.
//  Copyright 2006 mabe. All rights reserved.
//

// $Author: mbergmann $
// $HeadURL: file:///REPOSITORY/private/cocoa/iKnowAndManage/trunk/src/RegEx/MBMatchResult.h $
// $LastChangedBy: mbergmann $
// $LastChangedDate: 2006-07-18 14:44:23 +0200 (Tue, 18 Jul 2006) $
// $Rev: 557 $

#import <Cocoa/Cocoa.h>

/**
 \brief MatchResult is a class that stores match results of a pattern matches as an array of substrings.
 Each substrings has 1 or more substrings.
 If the array of substrings is empty, there is no match.
*/
@interface MBMatchResult : NSObject 
{
	NSMutableArray *listOfMatches;
}

+ (id)matchResult;
+ (id)matchResultWithListOfMatches:(NSArray *)list;

- (id)initWithListOfMatches:(NSArray *)list;

- (void)addMatch:(NSArray *)substringList;

- (void)setListOfMatches:(NSArray *)list;
- (NSArray *)listOfMatches;
- (int)numberOfMatches;

@end
