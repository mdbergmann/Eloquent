/******************************************************************************
 *
 * $Id: unicodertf.h 1688 2005-01-01 04:42:26Z scribe $
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

#ifndef UNICODERTF_H
#define UNICODERTF_H

#include <swfilter.h>

SWORD_NAMESPACE_START

/** This filter converts UTF-8 text into RTF Unicode tags
 */
class SWDLLEXPORT UnicodeRTF : public SWFilter {
public:
	UnicodeRTF();
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif
