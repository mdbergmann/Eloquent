/******************************************************************************
 *
 *  xzcomprs.h -	XzCompress, a driver class that provides xz (LZMA2)
 *			compression
 *
 * $Id: xzcomprs.h 3249 2014-08-24 01:55:08Z scribe $
 *
 * Copyright 2000-2014 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef XZCOMPRS_H
#define XZCOMPRS_H

#include <swcomprs.h>

#include <defs.h>
#include <sysdata.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT XzCompress : public SWCompress {

protected:
public:
	XzCompress();
	virtual ~XzCompress();

	virtual void Encode(void);
	virtual void Decode(void);
	virtual void setLevel(int l);
private:
	__u64 memlimit; // memory usage limit during decompression
};

SWORD_NAMESPACE_END
#endif
