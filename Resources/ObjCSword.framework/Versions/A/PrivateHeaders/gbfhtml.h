/******************************************************************************
 *
 *  gbfhtml.h -	Implementation of GBFHTML
 *
 * $Id: gbfhtml.h 2833 2013-06-29 06:40:28Z chrislit $
 *
 * Copyright 1999-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef GBFHTML_H
#define GBFHTML_H

#include <swbasicfilter.h>

SWORD_NAMESPACE_START

/** this filter converts GBF  text to HTML text 
 */
class SWDLLEXPORT GBFHTML : public SWBasicFilter {
protected:
	class MyUserData : public BasicFilterUserData {
	public:
		MyUserData(const SWModule *module, const SWKey *key) : BasicFilterUserData(module, key) {}
		bool hasFootnotePreTag;
	};
	virtual BasicFilterUserData *createUserData(const SWModule *module, const SWKey *key) {
		return new MyUserData(module, key);
	}
	virtual bool handleToken(SWBuf &buf, const char *token, BasicFilterUserData *userData);
public:
	GBFHTML();
};

SWORD_NAMESPACE_END
#endif
