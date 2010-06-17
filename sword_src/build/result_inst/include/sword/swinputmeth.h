/**
 * Title:
 * Description:
 * Copyright:    Copyright (c) 2001 CrossWire Bible Society under the terms of the GNU GPL
 * Company:
 * @author Troy A. Griffitts
 * @version 1.0
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
