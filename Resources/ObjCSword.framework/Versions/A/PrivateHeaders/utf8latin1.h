/******************************************************************************
 *
 *  utf8latin1.h -	 Implementation of UTF8Latin1
 *
 * $Id: utf8latin1.h 2833 2013-06-29 06:40:28Z chrislit $
 *
 * Copyright 2001-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef UTF8Latin1_H
#define UTF8Latin1_H

#include <swfilter.h>

SWORD_NAMESPACE_START

/** This filter converts UTF-8 encoded text to Latin-1
 */
class SWDLLEXPORT UTF8Latin1 : public SWFilter {
	char replacementChar;
public:
	UTF8Latin1(char rchar = '?');
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif
