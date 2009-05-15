/******************************************************************************
 *
 * $Id: osishtmlhref.h 2391 2009-05-08 02:02:16Z chrislit $
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

#ifndef OSISHTMLHREF_H
#define OSISHTMLHREF_H

#include <swbasicfilter.h>

SWORD_NAMESPACE_START

/** this filter converts OSIS text to HTML text with hrefs
 */
class SWDLLEXPORT OSISHTMLHREF : public SWBasicFilter {
private:
	bool morphFirst;
protected:
	// used by derived classes so we have it in the header
	class QuoteStack;
	class SWDLLEXPORT MyUserData : public BasicFilterUserData {
	public:
		bool osisQToTick;
		bool inBold;
		bool inXRefNote;
		bool BiblicalText;
		int suspendLevel;
		SWBuf wordsOfChristStart;
		SWBuf wordsOfChristEnd;
                QuoteStack *quoteStack;
		SWBuf lastTransChange;
		SWBuf w;
		SWBuf fn;
		SWBuf version;
		MyUserData(const SWModule *module, const SWKey *key);
		~MyUserData();
	};
	virtual BasicFilterUserData *createUserData(const SWModule *module, const SWKey *key) {
		return new MyUserData(module, key);
	}
	virtual bool handleToken(SWBuf &buf, const char *token, BasicFilterUserData *userData);
public:
	OSISHTMLHREF();
	void setMorphFirst(bool val = true) { morphFirst = val; }
};

SWORD_NAMESPACE_END
#endif
