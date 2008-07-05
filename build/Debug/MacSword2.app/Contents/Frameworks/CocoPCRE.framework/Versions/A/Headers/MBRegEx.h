//
//  MBRegEx.h
//  iKnowAndManage
//
//  Created by Manfred Bergmann on 20.03.06.
//  Copyright 2006 mabe. All rights reserved.
//

// $Author: asrael $
// $HeadURL: file:///REPOSITORY/private/cocoa/iKnowAndManage/trunk/src/RegEx/MBRegEx.h $
// $LastChangedBy: asrael $
// $LastChangedDate: 2006-05-27 13:47:09 +0200 (Sat, 27 May 2006) $
// $Rev: 538 $

#import <Cocoa/Cocoa.h>
#import <CocoPCRE/CocoPCRE.h>
#import <CocoPCRE/pcre.h>						// Perl Compatible RegEx
#import <CocoPCRE/MBMatchResult.h>

typedef enum RegexResult
{
	MBRegexNoMatch = 0,
	MBRegexMatch,
	MBRegexMatchError
}MBRegExResultType;

typedef enum RegexOptions
{
	MBRegexCaseSensitive = PCRE_CASELESS,
	MBRegexMultiline = PCRE_MULTILINE,
	MBRegexExtended = PCRE_EXTENDED
}MBRegexOptionsType;

/**
\brief Error codes for Regex
 */
typedef enum MBRegexErrorCodes
{
	MBRegexSuccess = 0,				/** On success */
	MBRegexCompileError,			/** Error on compiling pattern */
	MBRegexError					/** General, unknown error */
}MBRegexErrorCodeType;

@interface MBRegex : NSObject 
{
	pcre *re;				// pointer to pcre structure
	pcre_extra *pe;			// pointer for study information
	
	int options;

	BOOL captureSubstrings;
	BOOL findAll;
	
	// the search pattern
	NSString *pattern;
	NSString *origPattern;		// the search pattern may vary to the original pattern
	
	// error handling
	NSString *errorMessageOfLastAction;
	int errorCodeOfLastAction;
}

// convevient allocator
+ (id)regexWithPattern:(NSString *)pat;
+ (id)regexWithPattern:(NSString *)pat options:(int)opts;

// alloc
- (id)initWithPattern:(NSString *)pat;
- (id)initWithPattern:(NSString *)pat options:(int)opts;

// study the pattern to speed things up
- (void)studyPattern;

// getter and setter for the pattern
- (void)setPattern:(NSString *)pat;
- (NSString *)pattern;
- (void)setOrigPattern:(NSString *)origPat;
- (NSString *)origPattern;

// options for pcre_compile
- (void)setMultiline:(BOOL)flag;
- (void)setCaseSensitive:(BOOL)flag;
- (void)setExtended:(BOOL)flag;

// general options
- (void)setCaptureSubstrings:(BOOL)flag;
- (BOOL)captureSubstrings;
- (void)setFindAll:(BOOL)flag;
- (BOOL)findAll;

// simple string matching
- (MBRegExResultType)matchIn:(NSString *)string matchResult:(MBMatchResult **)mResult;

// error handling
- (NSString *)errorMessageOfLastAction;
- (int)errorCodeOfLastAction;

@end
