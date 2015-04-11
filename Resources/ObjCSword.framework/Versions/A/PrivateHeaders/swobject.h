/******************************************************************************
 *
 *  swobject.h -	definition for SWObject used as lowest base class for
 *			many SWORD objects
 *
 * $Id: swobject.h 2833 2013-06-29 06:40:28Z chrislit $
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

#ifndef SWOBJECT_H
#define SWOBJECT_H

#include <defs.h>

SWORD_NAMESPACE_START
#define SWDYNAMIC_CAST(className, object) (className *)((object)?((object->getClass()->isAssignableFrom(#className))?object:0):0)

/**
* Class used for SWDYNAMIC_CAST to save the inheritance order.
*/
class SWDLLEXPORT SWClass {
private:
	const char **descends;

public:
	SWClass(const char **descends) {
		this->descends = descends;
	}

	bool isAssignableFrom(const char *className) const;
};

/** Base class for major Sword classes.
* SWObject is the base class for major Sword classes like SWKey.
* It is used because dynamic_cast is not available on all plattforms supported
* by Sword. Use SWDYNAMIC_CAST(classname, object) instead of dynamic_cast<classname>(object).
*/
class SWDLLEXPORT SWObject {
protected:
	SWClass * myclass;
     
public:
	/** Use this to get the class definition and inheritance order.
	* @return The class definition of this object
	*/
	const SWClass *getClass () const {
		return myclass;
	}
};

SWORD_NAMESPACE_END
#endif
