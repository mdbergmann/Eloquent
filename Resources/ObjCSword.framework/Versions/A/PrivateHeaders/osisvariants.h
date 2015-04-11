/******************************************************************************
 *
 *  osisvariants.h -	Implementation of OSISVariants
 *
 * $Id: osisvariants.h 2980 2013-09-14 21:51:47Z scribe $
 *
 * Copyright 2006-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef OSISVARIANTS_H
#define OSISVARIANTS_H

#include <swoptfilter.h>
#include <swmodule.h>

SWORD_NAMESPACE_START

/** This Filter shows/hides textual variants
 */
class SWDLLEXPORT OSISVariants : public SWOptionFilter {

public:
	OSISVariants();
	virtual ~OSISVariants();
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif
