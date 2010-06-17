/******************************************************************************
 *
 * $Id: thmlosis.h 1804 2005-05-07 06:26:10Z scribe $
 *
 * Copyright 2003 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef THMLOSIS_H
#define THMLOSIS_H

#include <swfilter.h>

SWORD_NAMESPACE_START

/** this filter converts ThML text to OSIS text
 */
class SWDLLEXPORT ThMLOSIS : public SWFilter {
public:
	ThMLOSIS();
	virtual ~ThMLOSIS();
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif /* THMLOSIS_H */
