/******************************************************************************
 *  roman.h	- roman numeral functions
 *
 * Copyright 1998 CrossWire Bible Society (http://www.crosswire.org)
 *	CrossWire Bible Society
 *	P. O. Box 2528
 *	Tempe, AZ  85280-2528
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation version 2.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 */
#ifndef ROMAN_H
#define ROMAN_H

#include <defs.h>
SWORD_NAMESPACE_START

/** Checks if a string is a roman numeral.
*/
char isroman(const char *, int maxchars = 0);
/* char* to_rom(int num, char *p); */

/** Converts a roman numeral to a string.
* @param s Roman numeral to convert.
*/
int from_rom(const char *s);

SWORD_NAMESPACE_END
#endif
