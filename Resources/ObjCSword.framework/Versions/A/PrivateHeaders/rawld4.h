/******************************************************************************
 *
 *  rawld4.cpp -	code for class 'RawLD4'- a module that reads raw
 *			lexicon and dictionary files: *.dat *.idx
 *
 * $Id: rawld4.h 2833 2013-06-29 06:40:28Z chrislit $
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

#ifndef RAWLD4_H
#define RAWLD4_H

#include <rawstr4.h>
#include <swld.h>

#include <defs.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT RawLD4 : public RawStr4, public SWLD {
	char getEntry(long away = 0) const;

public:


	RawLD4(const char *ipath, const char *iname = 0, const char *idesc = 0,
			SWDisplay *idisp = 0, SWTextEncoding encoding = ENC_UNKNOWN,
			SWTextDirection dir = DIRECTION_LTR,
			SWTextMarkup markup = FMT_UNKNOWN, const char *ilang = 0, bool caseSensitive = false, bool strongsPadding = true);

	virtual ~RawLD4();
	virtual SWBuf &getRawEntryBuf() const;

	virtual void increment(int steps = 1);
	virtual void decrement(int steps = 1) { increment(-steps); }
	// write interface ----------------------------
	virtual bool isWritable() const;
	static char createModule(const char *path) { return RawStr4::createModule(path); }

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
