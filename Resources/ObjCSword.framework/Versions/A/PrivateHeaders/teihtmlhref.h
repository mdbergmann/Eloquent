/******************************************************************************
 *
 *  teihtmlhref.h -	Implementation of TEIHTMLHREF
 *
 * $Id: teihtmlhref.h 2833 2013-06-29 06:40:28Z chrislit $
 *
 * Copyright 2008-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef TEIHTMLHREF_H
#define TEIHTMLHREF_H

#include <swbasicfilter.h>

SWORD_NAMESPACE_START

/** this filter converts TEI text to HTMLHREF text
 */
class SWDLLEXPORT TEIHTMLHREF : public SWBasicFilter {
private:
	bool renderNoteNumbers;

protected:
	class MyUserData : public BasicFilterUserData {
	public:
		bool BiblicalText;
		SWBuf lastHi;
		
		SWBuf version;
		MyUserData(const SWModule *module, const SWKey *key);
	};
	virtual BasicFilterUserData *createUserData(const SWModule *module, const SWKey *key) {
		return new MyUserData(module, key);
	}
	virtual bool handleToken(SWBuf &buf, const char *token, BasicFilterUserData *userData);
public:
	TEIHTMLHREF();
	void setRenderNoteNumbers(bool val = true) { renderNoteNumbers = val; }
};

SWORD_NAMESPACE_END
#endif
