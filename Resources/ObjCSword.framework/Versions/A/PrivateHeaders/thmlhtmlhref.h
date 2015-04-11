/******************************************************************************
 *
 *  thmlhtmlhref.h -	Implementation of ThMLHTMLHREF
 *
 * $Id: thmlhtmlhref.h 2833 2013-06-29 06:40:28Z chrislit $
 *
 * Copyright 2001-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef _THMLHTMLHREF_H
#define _THMLHTMLHREF_H

#include <swbasicfilter.h>
#include <utilxml.h>

SWORD_NAMESPACE_START

/** this filter converts ThML text to HTML text with hrefs
 */
class SWDLLEXPORT ThMLHTMLHREF : public SWBasicFilter {
	SWBuf imgPrefix;
	bool renderNoteNumbers;
protected:
	class MyUserData : public BasicFilterUserData {
	public:
		MyUserData(const SWModule *module, const SWKey *key);//: BasicFilterUserData(module, key) {}
		bool inscriptRef;
		bool SecHead;
		bool BiblicalText;
		SWBuf version;
		XMLTag startTag;
	};
	virtual BasicFilterUserData *createUserData(const SWModule *module, const SWKey *key) {
		return new MyUserData(module, key);
	}
	virtual bool handleToken(SWBuf &buf, const char *token, BasicFilterUserData *userData);
public:
	ThMLHTMLHREF();
	virtual const char *getImagePrefix() { return imgPrefix.c_str(); }
	virtual void setImagePrefix(const char *newImgPrefix) { imgPrefix = newImgPrefix; }
	void setRenderNoteNumbers(bool val = true) { renderNoteNumbers = val; }
};
SWORD_NAMESPACE_END
#endif /* _THMLHTMLHREF_H */
