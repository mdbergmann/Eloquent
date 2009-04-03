/******************************************************************************
 *  rawtext.h   - code for class 'RawText4'- a module that reads raw text files:
 *		  ot and nt using indexs ??.bks ??.cps ??.vss
 *
 * $Id: rawtext.h 1864 2005-11-20 06:06:40Z scribe $
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

#ifndef RAWTEXT4_H
#define RAWTEXT4_H

#include <rawverse4.h>
#include <rawstr4.h>
#include <swtext.h>

#include <defs.h>

SWORD_NAMESPACE_START

class RawStr;

class SWDLLEXPORT RawText4 : public SWText, public RawVerse4 {

public:
  
	RawText4(const char *ipath, const char *iname = 0, const char *idesc = 0, SWDisplay * idisp = 0, SWTextEncoding encoding = ENC_UNKNOWN, SWTextDirection dir = DIRECTION_LTR, SWTextMarkup markup = FMT_UNKNOWN, const char* ilang = 0, const char *versification = "KJV");
	virtual ~RawText4();
	virtual SWBuf &getRawEntryBuf();
	virtual void increment(int steps = 1);
	virtual void decrement(int steps = 1) { increment(-steps); }
	// write interface ----------------------------
	virtual bool isWritable();
	static char createModule(const char *path, const char *v11n = "KJV") { return RawVerse4::createModule(path, v11n); }
	virtual void setEntry(const char *inbuf, long len = -1);	// Modify current module entry
	virtual void linkEntry(const SWKey *linkKey);	// Link current module entry to other module entry
	virtual void deleteEntry();	// Delete current module entry
	// end write interface ------------------------

	virtual bool isLinked(const SWKey *k1, const SWKey *k2) const;

	SWMODULE_OPERATORS

};

SWORD_NAMESPACE_END
#endif
