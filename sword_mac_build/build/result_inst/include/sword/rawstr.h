/*****************************************************************************
 * rawstr.h   - code for class 'RawStr'- a module that reads raw text
 *			files:  ot and nt using indexs ??.bks ??.cps ??.vss
 *			and provides lookup and parsing functions based on
 *			class StrKey
 *
 * $Id: rawstr.h 2303 2009-04-06 13:38:34Z scribe $
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

#ifndef RAWSTR_H
#define RAWSTR_H

#include <defs.h>
#include <sysdata.h>

SWORD_NAMESPACE_START

class SWBuf;
class FileDesc;

class SWDLLEXPORT RawStr {
	static int instance;		// number of instantiated RawStr objects or derivitives
	char *path;
	mutable long lastoff;	 // for caching and optimizing
	

protected:
	FileDesc *idxfd;
	FileDesc *datfd;
	void doSetText(const char *key, const char *buf, long len = -1);
	void doLinkEntry(const char *destkey, const char *srckey);
	static const int IDXENTRYSIZE;

public:
	static char nl;
	RawStr(const char *ipath, int fileMode = -1);
	virtual ~RawStr();
	void getIDXBuf(long ioffset, char **buf) const;
	void getIDXBufDat(long ioffset, char **buf) const;
	signed char findOffset(const char *key, __u32 *start, __u16 *size, long away = 0, __u32 *idxoff = 0) const;
	void readText(__u32 start, __u16 *size, char **idxbuf, SWBuf &buf);
	static signed char createModule(const char *path);
};

SWORD_NAMESPACE_END
#endif
