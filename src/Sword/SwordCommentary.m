/*	SwordCommentary.mm - Sword API wrapper for Commentaries.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import "SwordCommentary.h"
#import "utils.h"

// Well this is pretty much an empty sub-class of SwordBible
@implementation SwordCommentary

#pragma mark - SwordModuleAccess

- (NSArray *)stripedTextForRef:(NSString *)reference {
	return [super stripedTextForRef:[reference uppercaseString]];    
}

- (NSArray *)renderedTextForRef:(NSString *)reference {
    return [super renderedTextForRef:reference];
}

- (long)entryCount {
    return [super entryCount];
}

- (void)writeEntry:(NSString *)value forRef:(NSString *)reference {
    [super writeEntry:value forRef:reference];
}

@end
