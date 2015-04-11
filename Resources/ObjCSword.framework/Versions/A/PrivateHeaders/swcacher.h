/******************************************************************************
 *
 *  swcacher.h -	definition of class SWCacher used to provide an
 *			interface for objects that cache and want a standard
 *			interface for cleaning up.
 *
 * $Id: swcacher.h 2833 2013-06-29 06:40:28Z chrislit $
 *
 * Copyright 2002-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef SWCACHER_H
#define SWCACHER_H

#include <defs.h>

SWORD_NAMESPACE_START

/** used to provide an interface for objects that cache and want
 *	a standard interface for cleaning up.
 */
class SWDLLEXPORT  SWCacher {
public:
	SWCacher();
	virtual ~SWCacher();
	virtual void flush();
	virtual long resourceConsumption();
	virtual long lastAccess();
};

SWORD_NAMESPACE_END
#endif
