/******************************************************************************
 *  localemgr.h   - definition of class LocaleMgr used to interact with
 *				registered locales for a sword installation
 *
 * $Id: localemgr.h 1864 2005-11-20 06:06:40Z scribe $
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

#ifndef LOCALEMGR_H
#define LOCALEMGR_H

#include <map>
#include <list>

#include <defs.h>
#include <swbuf.h>

SWORD_NAMESPACE_START

class SWLocale;
 
typedef std::list<SWBuf> StringList;
typedef std::map < SWBuf, SWLocale *, std::less < SWBuf > > LocaleMap;
/**
* The LocaleMgr class handles all the different locales of Sword.
* It provides functions to get a list of all available locales,
* to get the default locale name and to get it.
* The other functions are not interesting for frontend programmers.
*
* To get the default locale name use @see getDefaultLocaleName
* To set the default locale name use @see setDefaultLocaleName
* To get the locale for a language name use @see getLocale
* To get a list of availble locales use @see getAvailableLocales
*/
class SWDLLEXPORT LocaleMgr {
private:
	void deleteLocales();
	char *defaultLocaleName;
	LocaleMgr(const LocaleMgr &);
	friend class __staticsystemLocaleMgr;
protected:
	LocaleMap *locales;
	static LocaleMgr *systemLocaleMgr;

public:

	/** Default constructor of  LocaleMgr
	* You do normally not need this constructor, use LocaleMgr::getSystemLocaleMgr() instead.
	*/
	LocaleMgr(const char *iConfigPath = 0);

	/**
	* Default destructor of LocaleMgr
	*/
	virtual ~LocaleMgr();

	/** Get the locale connected with the name "name".
	*
	* @param name The name of the locale you want to have. For example use getLocale("de") to get the locale for the German language.
	* @return Returns the locale object if the locale with the name given as parameter was found. If it wasn't found return NULL.
	*/
	virtual SWLocale *getLocale(const char *name);

	/** Get the list of available locales.
	*
	* @return Returns a list of strings, which contains the names of the available locales.
	*/
	virtual StringList getAvailableLocales();

	/** Returns translated text.
	* This function uses both parameters to return the translated version of the given text.
	*
	* @param text The text to translate into the language given by the first parameter.
	* @param localeName The name of the locale Sword should use
	* @return Returns the translated text.
	*/
	virtual const char *translate(const char *text, const char *localeName = 0);

	/** Get the default locale name. To set it use @see setDefaultLocaleName
	*
	* @return Returns the default locale name
	*/
	virtual const char *getDefaultLocaleName();

	/** Set the new standard locale of Sword.
	*
	* @param name The name of the new default locale  
	*/
	virtual void setDefaultLocaleName(const char *name);

	/** The LocaleMgr object used globally in the Sword world.
	* Do not create your own LocaleMgr, use this static object instead.
	*/
	static LocaleMgr *getSystemLocaleMgr();
	static void setSystemLocaleMgr(LocaleMgr *newLocaleMgr);

	/** Augment this localmgr with all locale.conf files in a directory
	*/
	virtual void loadConfigDir(const char *ipath);

};

SWORD_NAMESPACE_END
#endif
