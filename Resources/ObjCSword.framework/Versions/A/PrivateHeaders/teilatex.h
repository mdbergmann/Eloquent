/******************************************************************************
 *
 *  teilatex.h -	Implementation of TEILaTeX
 *
 * $Id: teilatex.h 3548 2017-12-10 05:11:38Z scribe $
 *
 * Copyright 2012-2014 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef TEILATEX_H
#define TEILATEX_H

#include <swbasicfilter.h>

SWORD_NAMESPACE_START

/** this filter converts TEI text to LaTeX text
 */
class SWDLLEXPORT TEILaTeX : public SWBasicFilter {
private:
	bool renderNoteNumbers;

protected:
	class MyUserData : public BasicFilterUserData {
	public:
		bool isBiblicalText;
		SWBuf lastHi;
		bool firstCell; // for tables, indicates whether a cell is the first one in a row
		int consecutiveNewlines;
		
		SWBuf version;
		MyUserData(const SWModule *module, const SWKey *key);
	};
	virtual BasicFilterUserData *createUserData(const SWModule *module, const SWKey *key) {
		return new MyUserData(module, key);
	}
	virtual bool handleToken(SWBuf &buf, const char *token, BasicFilterUserData *userData);
public:
	TEILaTeX();
	void setRenderNoteNumbers(bool val = true) { renderNoteNumbers = val; }
};

SWORD_NAMESPACE_END
#endif
