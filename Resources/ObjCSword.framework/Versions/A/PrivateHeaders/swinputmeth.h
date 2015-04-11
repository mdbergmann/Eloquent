/******************************************************************************
 *
 *  swinputmeth.h -	Implementation of SWInputMethod
 *
 * $Id: swinputmeth.h 2833 2013-06-29 06:40:28Z chrislit $
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

#ifndef SWINPUTMETHOD_H
#define SWINPUTMETHOD_H

#include <defs.h>
SWORD_NAMESPACE_START

class SWDLLEXPORT SWInputMethod {

private:
    int state;

protected:
    virtual void setState(int state);

public:
    SWInputMethod();
    virtual ~SWInputMethod() {}

    virtual int *translate(char in) = 0;
    virtual int getState();
    virtual void clearState();
};

SWORD_NAMESPACE_END
#endif
