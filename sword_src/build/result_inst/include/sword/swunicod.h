/*
 *
 * Copyright 1998 CrossWire Bible Society (http://www.crosswire.org)
 *      CrossWire Bible Society
 *      P. O. Box 2528
 *      Tempe, AZ  85280-2528
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


#ifndef SWUNICOD_H
#define SWUNICOD_H

#include <defs.h>
SWORD_NAMESPACE_START

/** Converts a 32-bit unsigned integer UTF-32 value into a UTF-8 encoded 1-6 byte array
 * @param utf32 the UTF-32 Unicode code point value
 * @param utf8 pointer to an array of 6 unsigned chars to contain the UTF-8 value
 * @return utf8
 */
unsigned char* UTF32to8 (unsigned long utf32, unsigned char * utf8);


/** Converts a UTF-8 encoded 1-6 byte array into a 32-bit unsigned integer UTF-32 value
 * @param utf8 pointer to an array of 6 unsigned chars containing the UTF-8 value, starting in the utf8[0]
 * @param utf32 the UTF-32 Unicode code point value
 * @return utf32
 */
unsigned long UTF8to32 (unsigned char * utf8, unsigned long utf32);

SWORD_NAMESPACE_END

#endif
