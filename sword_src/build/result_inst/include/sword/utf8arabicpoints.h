/******************************************************************************
 *
 * UTF8ArabicPoints - SWFilter descendant to remove UTF-8 Arabic vowel points
 *
 * $Id: utf8arabicpoints.h 1688 2008-11-30 04:42:26Z refdoc $
 *
 * Copyright 2009 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef UTF8ARABICPOINTS_H
#define UTF8ARABICPOINTS_H

#include <swoptfilter.h>

SWORD_NAMESPACE_START

/** This Filter shows/hides Arabic vowel points in UTF8 text
 */
class SWDLLEXPORT UTF8ArabicPoints : public SWOptionFilter {
public:
	UTF8ArabicPoints();
	virtual ~UTF8ArabicPoints();
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif
