/******************************************************************************
 *  swsearchable.h	- definition of class SWSearchable used to provide an
 *	interface for objects that be searched.
 *
 * $Id: swsearchable.h 2054 2007-05-25 17:31:39Z scribe $
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

#ifndef SWSEARCHABLE_H
#define SWSEARCHABLE_H

#include <defs.h>

SWORD_NAMESPACE_START

class ListKey;
class SWKey;

/** used to provide an interface for objects that be searched.
 */
class SWDLLEXPORT SWSearchable {
public:
	SWSearchable();
	virtual ~SWSearchable();

	/**
	* This is the default callback function for searching.
	* This function is a placeholder and does nothing.
	* You can define your own function for search progress
	* evaluation, and pass it over to Search().
	*/
	static void nullPercent(char percent, void *userData);

	// search interface -------------------------------------------------

	/**
	 * Searches a module for a string
	 * @param istr string for which to search
	 * @param searchType type of search to perform
	 *			>=0 - regex
	 *			-1  - phrase
	 *			-2  - multiword
	 *			-3  - entryAttrib (eg. Word//Strongs/G1234/)
	 *			-4  - Lucene
	 * @param flags options flags for search
	 * @param scope Key containing the scope. VerseKey or ListKey are useful here.
	 * @param justCheckIfSupported if set, don't search,
	 * only tell if this function supports requested search.
	 * @param percent Callback function to get the current search status in %.
	 * @param percentUserData User data that is given to the callback function as parameter.
	 *
	 * @return ListKey set to verses that contain istr
	 */

	virtual ListKey &search(const char *istr, int searchType = 0, int flags = 0,
			SWKey * scope = 0,
			bool * justCheckIfSupported = 0,
			void (*percent) (char, void *) = &nullPercent,
			void *percentUserData = 0) = 0;

	/**
	 * ask the object to build any indecies it wants for optimal searching
	 */
	virtual signed char createSearchFramework(
			void (*percent) (char, void *) = &nullPercent,
			void *percentUserData = 0);	// special search framework

	virtual void deleteSearchFramework();
	
	/**
	 * was SWORD compiled with code to optimize searching for this driver?
	 */
	virtual bool hasSearchFramework() { return false; }

	/**
	 * Check if the search is optimally supported (e.g. if index files are
	 * presnt and working)
	 * This function checks whether the search framework may work in the
	 * best way.
	 * @return true if the the search is optimally supported, false if
	 * it's not working in the best way.
	 */
	virtual bool isSearchOptimallySupported(const char *istr, int searchType, int flags, SWKey *scope);
};

SWORD_NAMESPACE_END
#endif
