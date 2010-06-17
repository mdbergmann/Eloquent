/*****************************************************************************
 * zstr.h   - code for class 'zStr'- a module that reads compressed text
 *			files.
 *			and provides lookup and parsing functions based on
 *			class StrKey
 *
 * $Id: zstr.h 2303 2009-04-06 13:38:34Z scribe $
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

#ifndef ZSTR_H
#define ZSTR_H

#include <defs.h>

SWORD_NAMESPACE_START

class SWCompress;
class EntriesBlock;
class FileDesc;
class SWBuf;

class SWDLLEXPORT zStr {

private:
	static int instance;		// number of instantiated zStr objects or derivitives
	EntriesBlock *cacheBlock;
	long cacheBlockIndex;
	bool cacheDirty;
	char *path;
	mutable long lastoff;		// for caching and optimization
	long blockCount;
	SWCompress *compressor;

protected:
	FileDesc *idxfd;
	FileDesc *datfd;
	FileDesc *zdxfd;
	FileDesc *zdtfd;
	static const int IDXENTRYSIZE;
	static const int ZDXENTRYSIZE;

	void getCompressedText(long block, long entry, char **buf);
	void flushCache();
	void getKeyFromDatOffset(long ioffset, char **buf) const;
	void getKeyFromIdxOffset(long ioffset, char **buf) const;

public:
	char nl;
	zStr(const char *ipath, int fileMode = -1, long blockCount = 100, SWCompress *icomp = 0);
	virtual ~zStr();
	signed char findKeyIndex(const char *ikey, long *idxoff, long away = 0) const;
	void getText(long index, char **idxbuf, char **buf);
	void setText(const char *ikey, const char *buf, long len = -1);
	void linkEntry(const char *destkey, const char *srckey);
	virtual void rawZFilter(SWBuf &buf, char direction = 0) {}
	static signed char createModule (const char *path);
};

SWORD_NAMESPACE_END
#endif
