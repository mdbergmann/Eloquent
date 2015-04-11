/*****************************************************************************
 *
 *  zstr.h -	code for class 'zStr'- a module that reads compressed text
 *	       	files.
 *		and provides lookup and parsing functions based on
 *		class StrKey
 *
 * $Id: zstr.h 2980 2013-09-14 21:51:47Z scribe $
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
	mutable EntriesBlock *cacheBlock;
	mutable long cacheBlockIndex;
	mutable bool cacheDirty;
	char *path;
	bool caseSensitive;
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

	void getCompressedText(long block, long entry, char **buf) const;
	void flushCache() const;
	void getKeyFromDatOffset(long ioffset, char **buf) const;
	void getKeyFromIdxOffset(long ioffset, char **buf) const;

public:
	zStr(const char *ipath, int fileMode = -1, long blockCount = 100, SWCompress *icomp = 0, bool caseSensitive = false);
	virtual ~zStr();
	signed char findKeyIndex(const char *ikey, long *idxoff, long away = 0) const;
	void getText(long index, char **idxbuf, char **buf) const;
	void setText(const char *ikey, const char *buf, long len = -1);
	void linkEntry(const char *destkey, const char *srckey);
	virtual void rawZFilter(SWBuf &buf, char direction = 0) const { (void) buf; (void) direction; }
	static signed char createModule (const char *path);
};

SWORD_NAMESPACE_END
#endif
