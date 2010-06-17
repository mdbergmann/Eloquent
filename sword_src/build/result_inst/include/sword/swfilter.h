/******************************************************************************
 *  swfilter.h	- definition of class SWFilter used to filter text between
 *				different formats
 *
 * $Id: swfilter.h 1864 2005-11-20 06:06:40Z scribe $
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

#ifndef SWFILTER_H
#define SWFILTER_H

#include <defs.h>

SWORD_NAMESPACE_START

class SWKey;
class SWBuf;
class SWModule;


class SWModule;

/** Base class for all filters in sword.
* Filters are used to filter/convert text between different formats
* like GBF, HTML, RTF ...
*/
class SWDLLEXPORT  SWFilter {
public:
	virtual ~SWFilter() {}

	/** This is the main filter function
	 * @param text The text to be filtered/converted
	 * @param key Current key That was used.
	 * @param module Current module.
	 * @return 0
	 */
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0) = 0;
};

	SWORD_NAMESPACE_END
#endif
