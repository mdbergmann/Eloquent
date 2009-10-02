/*****************************************************************************
 * rawstr.h   - code for class 'RawStr'- a module that reads raw text
 *			files:  ot and nt using indexs ??.bks ??.cps ??.vss
 *			and provides lookup and parsing functions based on
 *			class StrKey
 *
 * $Id: rawstr4.h 2303 2009-04-06 13:38:34Z scribe $
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

#ifndef RAWSTR4_H
#define RAWSTR4_H

#include <defs.h>
#include <sysdata.h>

SWORD_NAMESPACE_START

class FileDesc;
class SWBuf;

class SWDLLEXPORT RawStr4 {
	static int instance;		// number of instantiated RawStr4 objects or derivitives
	char *path;
	mutable long lastoff;		// for caching and optimizations

protected:
	static const int IDXENTRYSIZE;
	
	FileDesc *idxfd;
	FileDesc *datfd;
	void doSetText(const char *key, const char *buf, long len = -1);
	void doLinkEntry(const char *destkey, const char *srckey);
public:
	char nl;
	RawStr4(const char *ipath, int fileMode = -1);
	virtual ~RawStr4();
	void getIDXBuf(long ioffset, char **buf) const;
	void getIDXBufDat(long ioffset, char **buf) const;
	signed char findOffset(const char *key, __u32 *start, __u32 *size, long away = 0, __u32 *idxoff = 0) const;
	void readText(__u32 start, __u32 *size, char **idxbuf, SWBuf &buf);
	static signed char createModule(const char *path);
};

SWORD_NAMESPACE_END
#endif
