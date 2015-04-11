/******************************************************************************
 *
 *  zipcomprs.h -	definition of Class ZipCompress used for data
 *			compression
 *
 * $Id: zipcomprs.h 2850 2013-07-02 09:57:20Z chrislit $
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

#ifndef ZIPCOMPRS_H
#define ZIPCOMPRS_H

#include <swcomprs.h>

#include <defs.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT ZipCompress : public SWCompress {

protected:
public:
	ZipCompress();
	virtual ~ZipCompress();

	virtual void Encode(void);
	virtual void Decode(void);
};

SWORD_NAMESPACE_END
#endif
