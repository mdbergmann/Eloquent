/*
 *  CocoPCRE.h
 *  CocoPCRE
 *
 *  Created by Manfred Bergmann on 13.01.08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

#import <CocoPCRE/MBRegEx.h>

#ifdef DEBUG
#define CLOG1(X)	NSLog(X)
#define CLOG2(X,Y)	NSLog(X,Y)
#else
#define CLOG1(X)	;
#define CLOG2(X,Y)	;
#endif
