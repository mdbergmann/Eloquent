//
//  Regex.h
//  CocoPCRE
//
//  Created by Manfred Bergmann on 20.03.06.
//  Copyright 2006 mabe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoPCRE/MatchResult.h>
#import <CocoPCRE/pcre.h>						// Perl Compatible Regex

typedef enum _RegexResult {
	RegexNoMatch = 0,
	RegexMatch,
	RegexMatchError
}RegexResultType;

typedef enum _RegexOptions {
	RegexCaseSensitive = PCRE_CASELESS,
	RegexMultiline = PCRE_MULTILINE,
	RegexExtended = PCRE_EXTENDED
}RegexOptionsType;

/**
 \brief Error codes for Regex
 */
typedef enum _RegexErrorCodes {
	RegexSuccess = 0,				/** On success */
	RegexCompileError,			/** Error on compiling pattern */
	RegexError					/** General, unknown error */
}RegexErrorCodeType;


@class MatchResult;

@interface Regex : NSObject  {
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
- (RegexResultType)matchIn:(NSString *)string matchResult:(MatchResult **)mResult;

// get number of captures in pattern
- (int)numberOfCapturingSubpatterns;

// error handling
- (NSString *)errorMessageOfLastAction;
- (int)errorCodeOfLastAction;

@end
