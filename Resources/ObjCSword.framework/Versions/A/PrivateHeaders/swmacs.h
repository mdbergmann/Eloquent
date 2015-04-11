/******************************************************************************
 *
 *  swmacs.h -	generic macros
 *
 * $Id: swmacs.h 2833 2013-06-29 06:40:28Z chrislit $
 *
 * Copyright 1996-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef SWMACS_H
#define SWMACS_H

#include <defs.h>

SWORD_NAMESPACE_START
// Maximum positive value of a signed numeric type
#define MAXPOS(x) ((x)((unsigned x)(1L << (sizeof(x)*8-1)) - 1))

SWORD_NAMESPACE_END
#endif
