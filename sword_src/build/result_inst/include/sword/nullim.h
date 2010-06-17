#ifndef NULLIM_H
#define NULLIM_H

#include <swinputmeth.h>
#include <defs.h>
SWORD_NAMESPACE_START

class SWDLLEXPORT NullIM : public SWInputMethod {

public:
	NullIM();
	int * translate(char ch);
};

SWORD_NAMESPACE_END
#endif
