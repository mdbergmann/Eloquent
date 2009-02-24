/******************************************************************************
 *
 * $Id: utf8bidireorder.h 1688 2005-01-01 04:42:26Z scribe $
 *
 * Copyright 2001 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef UTF8BIDIREORDER_H
#define UTF8BIDIREORDER_H

#include <swfilter.h>

#include <unicode/utypes.h>
#include <unicode/ucnv.h>
#include <unicode/uchar.h>
#include <unicode/ubidi.h>

SWORD_NAMESPACE_START

/** This Filter reorders UTF-8 text according to Unicode BiDi
 */
class SWDLLEXPORT UTF8BiDiReorder : public SWFilter {
private:
	UConverter* conv;
	UErrorCode err;
public:
	UTF8BiDiReorder();
	~UTF8BiDiReorder();  
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif

