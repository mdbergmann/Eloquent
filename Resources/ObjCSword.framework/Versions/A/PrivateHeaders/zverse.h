/******************************************************************************
 *
 *  zverse.h -		code for class 'zVerse'- a module that reads raw text
 *			files:  ot and nt using indexs ??.bks ??.cps ??.vss
 *			and provides lookup and parsing functions based on
 *			class VerseKey
 *
 * $Id: zverse.h 3136 2014-03-17 09:38:48Z chrislit $
 *
 * Copyright 2000-2013 CrossWire Bible Society (http://www.crosswire.org)
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


#ifndef ZVERSE_H
#define ZVERSE_H

#include <defs.h>

SWORD_NAMESPACE_START

class FileDesc;
class SWCompress;
class SWBuf;

class SWDLLEXPORT zVerse {
	SWCompress *compressor;

protected:
	static int instance;		// number of instantiated zVerse objects or derivitives

	FileDesc *idxfp[2];
	FileDesc *textfp[2];
	FileDesc *compfp[2];
	char *path;
	void doSetText(char testmt, long idxoff, const char *buf, long len = 0);
	void doLinkEntry(char testmt, long destidxoff, long srcidxoff);
	void flushCache() const;
	mutable char *cacheBuf;
	mutable unsigned int cacheBufSize;
	mutable char cacheTestament;
	mutable long cacheBufIdx;
	mutable bool dirtyCache;

public:

#define	VERSEBLOCKS 2
#define	CHAPTERBLOCKS 3
#define	BOOKBLOCKS 4

	static const char uniqueIndexID[];

	// fileMode default = RDONLY
	zVerse(const char *ipath, int fileMode = -1, int blockType = CHAPTERBLOCKS, SWCompress * icomp = 0);
	virtual ~zVerse();

	void findOffset(char testmt, long idxoff, long *start, unsigned short *size, unsigned long *buffnum) const;
	void zReadText(char testmt, long start, unsigned short size, unsigned long buffnum, SWBuf &buf) const;
	virtual void rawZFilter(SWBuf &buf, char direction = 0) const { (void) buf; (void) direction; }
	static char createModule(const char *path, int blockBound, const char *v11n = "KJV");
};

SWORD_NAMESPACE_END
#endif
