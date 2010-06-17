/******************************************************************************
 *
 * $Id: osiswebif.h 1946 2006-07-15 20:41:24Z scribe $
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

#ifndef OSISWEBIF_H
#define OSISWEBIF_H

#include <osishtmlhref.h>

SWORD_NAMESPACE_START

/** this filter converts OSIS  text to HTML text with hrefs
 */
class SWDLLEXPORT OSISWEBIF : public OSISHTMLHREF {
	const SWBuf baseURL;
	const SWBuf passageStudyURL;
	bool javascript;

protected:
	virtual bool handleToken(SWBuf &buf, const char *token, BasicFilterUserData *userData);
	virtual BasicFilterUserData *createUserData(const SWModule *module, const SWKey *key);
public:
	OSISWEBIF();
	void setJavascript(bool mode) { javascript = mode; }
};

SWORD_NAMESPACE_END
#endif
