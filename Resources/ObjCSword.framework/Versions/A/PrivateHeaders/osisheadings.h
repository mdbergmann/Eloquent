/******************************************************************************
 *
 *  osisheadings.h -	Implementation of OSISHeadings
 *
 * $Id: osisheadings.h 2833 2013-06-29 06:40:28Z chrislit $
 *
 * Copyright 2003-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef OSISHEADINGS_H
#define OSISHEADINGS_H

#include <swoptfilter.h>
#include <swbasicfilter.h>

SWORD_NAMESPACE_START

/** This Filter shows/hides headings in a OSIS text
 */
class SWDLLEXPORT OSISHeadings : public SWOptionFilter, public SWBasicFilter {
public:
	OSISHeadings();
	virtual BasicFilterUserData *createUserData(const SWModule *module, const SWKey *key);
	virtual bool handleToken(SWBuf &buf, const char *token, BasicFilterUserData *userData);
};

SWORD_NAMESPACE_END
#endif
