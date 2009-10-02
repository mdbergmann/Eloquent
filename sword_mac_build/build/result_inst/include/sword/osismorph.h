/***************************************************************************
 *
 * $Id: osismorph.h 1688 2005-01-01 04:42:26Z scribe $
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

#ifndef OSISMORPH_H
#define OSISMORPH_H

#include <swoptfilter.h>

SWORD_NAMESPACE_START

/** This Filter shows/hides morph tags in a OSIS text
 */
class SWDLLEXPORT OSISMorph : public SWOptionFilter {
public:
	OSISMorph();
	virtual ~OSISMorph();
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif
