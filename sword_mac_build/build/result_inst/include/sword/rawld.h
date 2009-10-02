/******************************************************************************
 *  rawld.cpp - code for class 'RawLD'- a module that reads raw lexicon and
 *				dictionary files: *.dat *.idx
 *
 * $Id: rawld.h 2303 2009-04-06 13:38:34Z scribe $
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

#ifndef RAWLD_H
#define RAWLD_H

#include <rawstr.h>
#include <swld.h>

#include <defs.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT RawLD : public RawStr, public SWLD {
	char getEntry(long away = 0);

public:


	RawLD(const char *ipath, const char *iname = 0, const char *idesc = 0,
			SWDisplay * idisp = 0, SWTextEncoding encoding = ENC_UNKNOWN,
			SWTextDirection dir = DIRECTION_LTR,
			SWTextMarkup markup = FMT_UNKNOWN, const char* ilang = 0);

	virtual ~RawLD();
	virtual SWBuf &getRawEntryBuf();

	virtual void increment(int steps = 1);
	virtual void decrement(int steps = 1) { increment(-steps); }
	// write interface ----------------------------
	virtual bool isWritable();
	static char createModule(const char *path) { return RawStr::createModule (path); }

	virtual void setEntry(const char *inbuf, long len = -1);	// Modify current module entry
	virtual void linkEntry(const SWKey *linkKey);	// Link current module entry to other module entry
	virtual void deleteEntry();	// Delete current module entry
	// end write interface ------------------------
	virtual long getEntryCount() const;
	virtual long getEntryForKey(const char *key) const;
	virtual char *getKeyForEntry(long entry) const;


	// OPERATORS -----------------------------------------------------------------
	
	SWMODULE_OPERATORS

};

SWORD_NAMESPACE_END
#endif
