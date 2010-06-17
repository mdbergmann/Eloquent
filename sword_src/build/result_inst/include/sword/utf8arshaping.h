/******************************************************************************
 *
 * $Id: utf8arshaping.h 1688 2005-01-01 04:42:26Z scribe $
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

#ifndef UTF8ARSHAPING_H
#define UTF8ARSHAPING_H

#include <swfilter.h>

#include <unicode/utypes.h>
#include <unicode/ucnv.h>
#include <unicode/uchar.h>
#include <unicode/ushape.h>

SWORD_NAMESPACE_START

/** This Filter controls the arabic shaping of UTF-8 text
 * FIXME: is that correct? how to control it?
 */
class SWDLLEXPORT UTF8arShaping : public SWFilter {
private:
	UConverter* conv;
	UErrorCode err;
public:
	UTF8arShaping();
	~UTF8arShaping();  
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif


