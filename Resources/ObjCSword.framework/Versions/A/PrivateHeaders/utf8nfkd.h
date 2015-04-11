/******************************************************************************
 *
 *  utf8nfkd.h -	Implementation of UTF8NFKD
 *
 * $Id: utf8nfkd.h 2833 2013-06-29 06:40:28Z chrislit $
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

#ifndef UTF8NFKD_H
#define UTF8NFKD_H

#include <swfilter.h>

#include <unicode/utypes.h>
#include <unicode/ucnv.h>
#include <unicode/uchar.h>
#include <unicode/unorm.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT UTF8NFKD : public SWFilter {
private:
	UConverter* conv;
	UChar *source, *target;
	UErrorCode err;
public:
	UTF8NFKD();
	~UTF8NFKD();  
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif
