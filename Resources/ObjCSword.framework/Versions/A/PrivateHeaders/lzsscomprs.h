/******************************************************************************
 *
 *  lzsscomprs.h -	definition of Class SWCompress used for data
 *			compression
 *
 * $Id: lzsscomprs.h 2935 2013-08-02 11:06:30Z scribe $
 *
 * Copyright 1999-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef LZSSCOMPRS_H
#define LZSSCOMPRS_H

#include <swcomprs.h>

#include <defs.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT LZSSCompress : public SWCompress
{
class Private;
	Private *p;
public:
	LZSSCompress ();
	virtual ~LZSSCompress();
	virtual void Encode(void);
	virtual void Decode(void);
};

SWORD_NAMESPACE_END
#endif
