/******************************************************************************
 *  utilstr.h	- prototypes for string utility functions
 *
 * $Id: utilstr.h 2062 2007-07-19 17:27:31Z scribe $
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

#ifndef UTILSTR_H
#define UTILSTR_H

#include <defs.h>

SWORD_NAMESPACE_START

/** stdstr - clone a string
*/
char *stdstr (char **iistr, const char *istr, unsigned int memPadFactor = 1);
char *strstrip (char *istr);
const char *stristr (const char *s1, const char *s2);
int strnicmp(const char *s1, const char *s2, int len);
int stricmp(const char *s1, const char *s2);

/******************************************************************************
 * SW_toupper - array of uppercase values for any given Latin-1 value
 *
 * use this instead of toupper() for fast lookups on accented characters
 */
extern const unsigned char SW_toupper_array[256];
#define SW_toupper(c) SW_toupper_array[(unsigned char)c]

SWORD_NAMESPACE_END
#endif
