/******************************************************************************
 *
 * $Id: thmlvariants.h 1864 2005-11-20 06:06:40Z scribe $
 *
 * Copyright 2001 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef THMLVARIANTS_H
#define THMLVARIANTS_H

#include <swoptfilter.h>

SWORD_NAMESPACE_START

/** This Filter shows/hides textual variants
 */
class SWDLLEXPORT ThMLVariants : public SWOptionFilter {
	char option;

	static const char primary[];
	static const char secondary[];
	static const char all[];

	static const char optName[];
	static const char optTip[];
	StringList options;

public:
	ThMLVariants();
	virtual ~ThMLVariants();
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
	virtual const char *getOptionName() { return optName; }
	virtual const char *getOptionTip() { return optTip; }
	virtual void setOptionValue(const char *ival);
	virtual const char *getOptionValue();
	virtual StringList getOptionValues() { return options; }
};

SWORD_NAMESPACE_END
#endif
