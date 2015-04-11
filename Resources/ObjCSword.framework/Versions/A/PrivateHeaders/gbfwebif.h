/******************************************************************************
 *
 *  gbfwebif.h -	Implementation of GBFWEBIF
 *
 * $Id: gbfwebif.h 2833 2013-06-29 06:40:28Z chrislit $
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

#ifndef GBFWEBIF_H
#define GBFWEBIF_H

#include <gbfxhtml.h>

SWORD_NAMESPACE_START

/** this filter converts GBF text to classed XHTML for web interfaces
 */
class SWDLLEXPORT GBFWEBIF : public GBFXHTML {
	const SWBuf baseURL;
	const SWBuf passageStudyURL;

protected:
	virtual bool handleToken(SWBuf &buf, const char *token, BasicFilterUserData *userData);
public:
	GBFWEBIF();
};

SWORD_NAMESPACE_END
#endif
