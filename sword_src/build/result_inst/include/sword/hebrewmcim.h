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
