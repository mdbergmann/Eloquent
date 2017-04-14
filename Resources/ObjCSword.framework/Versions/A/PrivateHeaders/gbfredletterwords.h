/***************************************************************************
 *
 *  gbfredletterwords.h -	Implementation of GBFRedLetterWords
 *
 * $Id: gbfredletterwords.h 3451 2017-03-29 22:42:00Z scribe $
 *
 * Copyright 2003-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef GBFREDLETTERWORDS_H
#define GBFREDLETTERWORDS_H

#include <swoptfilter.h>

SWORD_NAMESPACE_START

/** This Filter shows/hides "red letter tags" (marking the
 * words of Jesus) in a GBF text. Turn this off if you don't want
 * to have this kind of markup in the text.
 */
class SWDLLEXPORT GBFRedLetterWords : public SWOptionFilter {
public:
	GBFRedLetterWords();
	virtual ~GBFRedLetterWords();
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif
