/******************************************************************************
 *
 *  rawverse4.h -	code for class 'RawVerse4'- a module that reads raw
 *			text files:  ot and nt using indexs ??.bks ??.cps
 *			??.vss and provides lookup and parsing functions based
 *			on class VerseKey
 *
 * $Id: rawverse4.h 3134 2014-03-17 09:30:15Z chrislit $
 *
 * Copyright 2007-2013 CrossWire Bible Society (http://www.crosswire.org)
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


#ifndef RAWVERSE4_H
#define RAWVERSE4_H


#include <defs.h>

SWORD_NAMESPACE_START

class FileDesc;
class SWBuf;

class SWDLLEXPORT RawVerse4 {


	static int instance;		// number of instantiated RawVerse objects or derivitives
protected:
	FileDesc *idxfp[2];
	FileDesc *textfp[2];

	char *path;
	void doSetText(char testmt, long idxoff, const char *buf, long len = -1);
	void doLinkEntry(char testmt, long destidxoff, long srcidxoff);

public:
	static const char nl;
	RawVerse4(const char *ipath, int fileMode = -1);
	virtual ~RawVerse4();
	void findOffset(char testmt, long idxoff, long *start,	unsigned long *end) const;
	void readText(char testmt, long start, unsigned long size, SWBuf &buf) const;
	static char createModule(const char *path, const char *v11n = "KJV");
};

SWORD_NAMESPACE_END
#endif
