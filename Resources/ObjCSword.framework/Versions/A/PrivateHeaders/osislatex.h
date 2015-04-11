/******************************************************************************
 *
 *  osislatex.h -	Render filter for LaTeX of an OSIS module
 *
 * $Id: osislatex.h 3074 2014-03-05 00:30:21Z chrislit $
 *
 * Copyright 2011-2014 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef OSISLATEX_H
#define OSISLATEX_H

#include <swbasicfilter.h>

SWORD_NAMESPACE_START

/** this filter converts OSIS text to classed XHTML
 */
class SWDLLEXPORT OSISLaTeX : public SWBasicFilter {
private:
	bool morphFirst;
	bool renderNoteNumbers;
protected:

	class TagStack;
	// used by derived classes so we have it in the header
	virtual BasicFilterUserData *createUserData(const SWModule *module, const SWKey *key);
	virtual bool handleToken(SWBuf &buf, const char *token, BasicFilterUserData *userData);


	class MyUserData : public BasicFilterUserData {
	public:
		bool osisQToTick;
		bool inXRefNote;
		bool BiblicalText;
		int suspendLevel;
		SWBuf wordsOfChristStart;
		SWBuf wordsOfChristEnd;
		TagStack *quoteStack;
		TagStack *hiStack;
		TagStack *titleStack;
		TagStack *lineStack;
		int consecutiveNewlines;
		SWBuf lastTransChange;
		SWBuf w;
		SWBuf fn;
		SWBuf version;

		MyUserData(const SWModule *module, const SWKey *key);
		~MyUserData();
		void outputNewline(SWBuf &buf);
	};
public:
	OSISLaTeX();
	void setMorphFirst(bool val = true) { morphFirst = val; }
	void setRenderNoteNumbers(bool val = true) { renderNoteNumbers = val; }
	virtual const char *getHeader() const;
};

SWORD_NAMESPACE_END
#endif
