/***************************************************************************
 *
 * $Id: plainhtml.h 1688 2005-01-01 04:42:26Z scribe $
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

#ifndef PLAINHTML_H
#define PLAINHTML_H

#include <swfilter.h>

SWORD_NAMESPACE_START

/** this filter converts plain text to HTML text
 * @author Torsten Uhlmann, begin : Tue Jun 15 15:34:26 CEST 1999
 */
class SWDLLEXPORT PLAINHTML : public SWFilter {
public:
	PLAINHTML();
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif
