/******************************************************************************
 *
 *  zld.cpp -	code for class 'zLD'- a module that reads compressed lexicon
 *		and dictionary files
 *
 * $Id: zld.h 2833 2013-06-29 06:40:28Z chrislit $
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

#ifndef ZLD_H
#define ZLD_H

#include <zstr.h>
#include <swld.h>

#include <defs.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT zLD : public zStr, public SWLD {
	char getEntry(long away = 0) const;

public:


	zLD(const char *ipath, const char *iname = 0, const char *idesc = 0, long blockCount = 200, SWCompress *icomp = 0, SWDisplay * idisp = 0, SWTextEncoding encoding = ENC_UNKNOWN, SWTextDirection dir = DIRECTION_LTR, SWTextMarkup markup = FMT_UNKNOWN, const char* ilang = 0, bool caseSensitive = false, bool strongsPadding = true);
	virtual ~zLD();
	virtual SWBuf &getRawEntryBuf() const;

	virtual void increment(int steps = 1);
	virtual void decrement(int steps = 1) { increment(-steps); }

	// write interface ----------------------------
	virtual bool isWritable() const;
	static char createModule(const char *path) {
		return zStr::createModule(path);
	}

	virtual void setEntry(const char *inbuf, long len = -1);	// Modify current module entry
	virtual void linkEntry(const SWKey *linkKey);	// Link current module entry to other module entry
	virtual void deleteEntry();	// Delete current module entry
	// end write interface ------------------------

	virtual void rawZFilter(SWBuf &buf, char direction = 0) const { rawFilter(buf, (SWKey *)(long)direction); }// hack, use key as direction for enciphering
  
	// swcacher interface ----------------------
	virtual void flush() { flushCache(); }
	// end swcacher interface ----------------------

	virtual long getEntryCount() const;
	virtual long getEntryForKey(const char *key) const;
	virtual char *getKeyForEntry(long entry) const;


	// OPERATORS -----------------------------------------------------------------
	
	SWMODULE_OPERATORS

};

SWORD_NAMESPACE_END
#endif
