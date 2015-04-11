/*	SwordCommentary.h - Sword API wrapper for Commentaries.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import <Foundation/Foundation.h>
#import <ObjCSword/ObjCSword.h>

#ifdef __cplusplus
#include <rawfiles.h>
#endif



@interface SwordCommentary : SwordBible {
}

/** 
 creates a new empty editable commentary module 
 caller has to make sure the module doesn't exist yet
 @return path of the created module
 */
+ (NSString *)createCommentaryWithName:(NSString *)aName;

@end
