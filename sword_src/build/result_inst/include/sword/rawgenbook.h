/******************************************************************************
 *  rawtext.h   - code for class 'RawText'- a module that reads raw text files:
 *		  ot and nt using indexs ??.bks ??.cps ??.vss
 *
 * $Id: rawgenbook.h 2303 2009-04-06 13:38:34Z scribe $
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

#ifndef RAWGENBOOK_H
#define RAWGENBOOK_H

#include <swgenbook.h>

#include <defs.h>

SWORD_NAMESPACE_START

class FileDesc;

class SWDLLEXPORT RawGenBook : public SWGenBook {
	char *path;
	FileDesc *bdtfd;
	bool verseKey;

public:
  
    
	RawGenBook(const char *ipath, const char *iname = 0, const char *idesc = 0,
			SWDisplay * idisp = 0, SWTextEncoding encoding = ENC_UNKNOWN,
			SWTextDirection dir = DIRECTION_LTR,
			SWTextMarkup markup = FMT_UNKNOWN, const char* ilang = 0, const char *keyType = "TreeKey");
	virtual ~RawGenBook();
	virtual SWBuf &getRawEntryBuf();
	// write interface ----------------------------
	virtual bool isWritable();
	static char createModule(const char *ipath);
	virtual void setEntry(const char *inbuf, long len = -1);	// Modify current module entry
	virtual void linkEntry(const SWKey * linkKey);	// Link current module entry to other module entry
	virtual void deleteEntry();	// Delete current module entry
	virtual SWKey *CreateKey() const;
	// end write interface ------------------------

	virtual bool hasEntry(const SWKey *k) const;

	// OPERATORS -----------------------------------------------------------------
	
	SWMODULE_OPERATORS

};

SWORD_NAMESPACE_END
#endif
