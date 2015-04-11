/******************************************************************************
 *
 *  osisxhtml.h -	Render filter for classed XHTML of an OSIS module
 *
 * $Id: osisxhtml.h 3257 2014-09-23 01:08:24Z scribe $
 *
 * Copyright 2011-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef OSISXHTML_H
#define OSISXHTML_H

#include <swbasicfilter.h>

SWORD_NAMESPACE_START

/** this filter converts OSIS text to classed XHTML
 */
class SWDLLEXPORT OSISXHTML : public SWBasicFilter {
private:
	bool morphFirst;
	bool renderNoteNumbers;
protected:

	class TagStack;
	virtual BasicFilterUserData *createUserData(const SWModule *module, const SWKey *key);
	virtual bool handleToken(SWBuf &buf, const char *token, BasicFilterUserData *userData);


	// used by derived classes so we have it in the header
	class MyUserData : public BasicFilterUserData {
	public:
		bool osisQToTick;
		bool inXRefNote;
		bool BiblicalText;
		int suspendLevel;
		SWBuf wordsOfChristStart;
		SWBuf wordsOfChristEnd;
		SWBuf interModuleLinkStart;
		SWBuf interModuleLinkEnd;
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
	OSISXHTML();
	void setMorphFirst(bool val = true) { morphFirst = val; }
	void setRenderNoteNumbers(bool val = true) { renderNoteNumbers = val; }
	virtual const char *getHeader() const;
};

SWORD_NAMESPACE_END
#endif
