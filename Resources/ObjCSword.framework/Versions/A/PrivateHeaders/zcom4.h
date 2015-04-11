/******************************************************************************
 *
 *  zcom4.h - 	code for class 'zCom4'- a module that reads compressed text
 *     	       	files: ot and nt using indexs ??.vss
 *
 * $Id: zcom4.h 3141 2014-03-19 01:24:04Z chrislit $
 *
 * Copyright 1996-2014 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef ZCOM4_H
#define ZCOM4_H

#include <swcom.h>

#include <defs.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT zCom4 : public zVerse4, public SWCom {

	VerseKey *lastWriteKey;
	bool sameBlock(VerseKey * lastWriteKey, VerseKey * key);
	int blockType;


public:

	zCom4(const char *ipath, const char *iname = 0, const char *idesc = 0,
			int blockType = CHAPTERBLOCKS, SWCompress *icomp = 0,
			SWDisplay *idisp = 0, SWTextEncoding encoding = ENC_UNKNOWN,
			SWTextDirection dir = DIRECTION_LTR,
			SWTextMarkup markup = FMT_UNKNOWN, const char *ilang = 0,
			const char *versification = "KJV");
	virtual ~zCom4();
	virtual SWBuf &getRawEntryBuf() const;
	virtual void increment(int steps = 1);
	virtual void decrement(int steps = 1) { increment(-steps); }

	// write interface ----------------------------
	virtual bool isWritable() const;
	static char createModule(const char *path, int blockBound, const char *v11n = "KJV") {
		return zVerse4::createModule(path, blockBound, v11n);
	}
	virtual void setEntry(const char *inbuf, long len = -1);	// Modify current module entry
	virtual void linkEntry(const SWKey * linkKey);	// Link current module entry to other module entry
	virtual void deleteEntry();	// Delete current module entry
	// end write interface ------------------------

	virtual void rawZFilter(SWBuf &buf, char direction = 0) const { rawFilter(buf, (SWKey *)(long)direction); }// hack, use key as direction for enciphering

	// swcacher interface ----------------------
	virtual void flush() { flushCache(); }
	// end swcacher interface ----------------------

	virtual bool isLinked(const SWKey *k1, const SWKey *k2) const;
	virtual bool hasEntry(const SWKey *k) const;
	
	SWMODULE_OPERATORS

};

SWORD_NAMESPACE_END

#endif
