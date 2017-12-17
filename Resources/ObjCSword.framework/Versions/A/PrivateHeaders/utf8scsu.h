/******************************************************************************
 *
 *  utf8scsu.h -	Implementation of UTF8SCSU
 *
 * $Id: utf8scsu.h 3472 2017-05-22 04:19:02Z scribe $
 *
 * Copyright 2001-2014 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef UTF8SCSU_H
#define UTF8SCSU_H

#include <swfilter.h>

#include <unicode/utypes.h>
#include <unicode/ucnv.h>
#include <unicode/uchar.h>
#include <unicode/unistr.h>

SWORD_NAMESPACE_START

/** This filter converts UTF-8 encoded text to SCSU
 */
class SWDLLEXPORT UTF8SCSU : public SWFilter {
private:
	UConverter* scsuConv;
	UConverter* utf8Conv;
	UErrorCode err;
public:
	UTF8SCSU();
	~UTF8SCSU();
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif
