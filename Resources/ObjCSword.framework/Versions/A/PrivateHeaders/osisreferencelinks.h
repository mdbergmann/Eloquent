/******************************************************************************
 *
 *  osisreferencelinks.h -	SWFilter descendant to toggle OSIS reference
 *				links with specified type/subType
 *
 * $Id: osisreferencelinks.h 2989 2013-10-09 08:22:21Z chrislit $
 *
 * Copyright 2013 CrossWire Bible Society (http://www.crosswire.org)
 *      CrossWire Bible Society
 *      P. O. Box 2528
 *      Tempe, AZ  85280-2528
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

#ifndef OSISREFERENCELINKS_H
#define OSISREFERENCELINKS_H

#include <swoptfilter.h>

SWORD_NAMESPACE_START

/** This Filter hides reference links with a particular type/subtype in an OSIS text
 */
class SWDLLEXPORT OSISReferenceLinks : public SWOptionFilter {
	SWBuf optionName;
	SWBuf optionTip;
	SWBuf type;
	SWBuf subType;
public:

	/**
	 * @param optionName - name of this option
	 * @param optionTip - user help tip for this option
	 * @param type - which reference types to hide
	 * @param subType - which reference subTypes to hide (optional)
	 * @param defaultValue - default value of option "On" or "Off" (optional)
	 */
	OSISReferenceLinks(const char *optionName, const char *optionTip, const char *type, const char *subType = 0, const char *defaultValue = "On");
	virtual ~OSISReferenceLinks();
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif


