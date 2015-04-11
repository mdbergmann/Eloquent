/******************************************************************************
 *
 *  osismorphsegmentation.h -	Implementation of OSISMorphSegmentation
 *
 * $Id: osismorphsegmentation.h 2833 2013-06-29 06:40:28Z chrislit $
 *
 * Copyright 2006-2013 CrossWire Bible Society (http://www.crosswire.org)
 * CrossWire Bible Society
 * P. O. Box 2528
 * Tempe, AZ  85280-2528
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

#ifndef OSISMORPHSEGMENTATION_H
#define OSISMORPHSEGMENTATION_H

#include <swoptfilter.h>

SWORD_NAMESPACE_START

/*  This filters toggles splitting of morphemes
 *  (for morpheme segmented Hebrew in the WLC)
 */

class SWDLLEXPORT OSISMorphSegmentation : public SWOptionFilter {

public:
	OSISMorphSegmentation();
	virtual ~OSISMorphSegmentation();

	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif
