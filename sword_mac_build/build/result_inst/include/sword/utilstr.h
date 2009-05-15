/******************************************************************************
 *  utilstr.h	- prototypes for string utility functions
 *
 * $Id: utilstr.h 2391 2009-05-08 02:02:16Z chrislit $
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
#include <sysdata.h>

SWORD_NAMESPACE_START

/** stdstr - clone a string
*/
SWDLLEXPORT char *stdstr (char **iistr, const char *istr, unsigned int memPadFactor = 1);
SWDLLEXPORT char *strstrip (char *istr);
SWDLLEXPORT const char *stristr (const char *s1, const char *s2);
SWDLLEXPORT int strnicmp(const char *s1, const char *s2, int len);
SWDLLEXPORT int stricmp(const char *s1, const char *s2);

/******************************************************************************
 * SW_toupper - array of uppercase values for any given Latin-1 value
 *
 * use this instead of toupper() for fast lookups on accented characters
 */
extern const unsigned char SW_toupper_array[256];
#define SW_toupper(c) SW_toupper_array[(unsigned char)c]

/******************************************************************************
 * getUniCharFromUTF8 - retrieves the next Unicode codepoint from a UTF8 string
 * 					and increments buf to start of next codepoint
 *
 * ENT:	buf - address of a utf8 buffer
 *
 * RET:	buf - incremented past last byte used in computing the current codepoint
 * 		unicode codepoint value (0 with buf incremented is invalid UTF8 byte
 */

__u32 getUniCharFromUTF8(const unsigned char **buf);


SWORD_NAMESPACE_END
#endif
