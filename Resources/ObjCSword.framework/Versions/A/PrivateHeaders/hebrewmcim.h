/******************************************************************************
 *
 *  hebrewmcim.h -	Implementation of HebrewMCIM
 *
 * $Id: hebrewmcim.h 2833 2013-06-29 06:40:28Z chrislit $
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

#ifndef HEBREWMCIM_H
#define HEBREWMCIM_H

/**
 * Title: Keyboard mapping for Michigan-Claremont Hebrew input
 * Description:
 * Copyright:    Copyright (c) 2001 CrossWire Bible Society under the terms of the GNU GPL
 * Company:
 * @author Troy A. Griffitts
 * @version 1.0
 */

#include <swinputmeth.h>
#include <map>
#include <defs.h>
SWORD_NAMESPACE_START


class SWDLLEXPORT HebrewMCIM : public SWInputMethod {

    void init();
    int subst[255];
    map<int, int> subst2[12];
    map<int, int*> multiChars;

public:
    HebrewMCIM();
    int *translate(char in);
};

SWORD_NAMESPACE_END
#endif
