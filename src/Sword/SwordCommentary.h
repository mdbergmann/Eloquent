/*	SwordCommentary.h - Sword API wrapper for Commentaries.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import "SwordBible.h"

@class SwordManager;

@interface SwordCommentary : SwordBible <SwordModuleAccess> {
}

// ------- SwordModuleAccess ---------
- (int)htmlForRef:(NSString *)reference html:(NSString **)htmlString;
- (long)entryCount;
- (void)writeEntry:(NSString *)value forRef:(NSString *)reference;

@end
