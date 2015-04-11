/******************************************************************************
 *
 *  entriesblk.h -	Implementation of EntriesBlock
 *
 * $Id: entriesblk.h 2833 2013-06-29 06:40:28Z chrislit $
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

#ifndef ENTRIESBLK_H
#define ENTRIESBLK_H

#include <sysdata.h>
#include <defs.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT EntriesBlock {
	static const int METAHEADERSIZE;
	static const int METAENTRYSIZE;

private:
	char *block;
	void setCount(int count);
	void getMetaEntry(int index, unsigned long *offset, unsigned long *size);
	void setMetaEntry(int index, unsigned long offset, unsigned long size);

public:
	EntriesBlock(const char *iBlock, unsigned long size);
	EntriesBlock();
	~EntriesBlock();

	int getCount();
	int addEntry(const char *entry);
	const char *getEntry(int entryIndex);
	unsigned long getEntrySize(int entryIndex);
	void removeEntry(int entryIndex);
	const char *getRawData(unsigned long *size);
};


SWORD_NAMESPACE_END
#endif
