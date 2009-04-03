/******************************************************************************
 *  swld.h   - code for base class 'SWLD'.  SWLD is the basis for all
 *				types of Lexicon and Dictionary modules (hence the 'LD').
 *
 * $Id: swld.h 2294 2009-03-29 14:48:47Z scribe $
 *
 * Copyright 1998 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef SWLD_H
#define SWLD_H

#include <swmodule.h>

#include <defs.h>

SWORD_NAMESPACE_START

  /** the basis for all types of Lexicon and
  * Dictionary modules (hence the 'LD').
  */
class SWDLLEXPORT SWLD : public SWModule {
protected:
	char *entkeytxt;
	static void strongsPad(char *buf);
public:
	/** Initializes data for instance of SWLD
	*/
	SWLD(const char *imodname = 0, const char *imoddesc = 0,
			SWDisplay * idisp = 0, SWTextEncoding encoding = ENC_UNKNOWN,
			SWTextDirection dir = DIRECTION_LTR,
			SWTextMarkup markup = FMT_UNKNOWN, const char* ilang = 0);
	
	virtual ~SWLD();
	virtual SWKey *CreateKey() const;

	/** Sets/gets module KeyText, getting from saved text if key is persistent
	*
	* @param ikeytext value which to set keytext;
	*  [0] - only get
	* @return pointer to keytext
	*/
	virtual const char *KeyText(const char *ikeytext = 0);
	virtual void setPosition(SW_POSITION pos);


	virtual long getEntryCount() = 0;
	virtual long getEntryForKey(const char *key) = 0;
	virtual char *getKeyForEntry(long entry) = 0;
	

	// OPERATORS -----------------------------------------------------------------
	
	SWMODULE_OPERATORS

};

SWORD_NAMESPACE_END
#endif
