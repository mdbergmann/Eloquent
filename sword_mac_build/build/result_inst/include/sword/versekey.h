/******************************************************************************
 *	versekey.h - code for class 'versekey'- a standard Biblical verse key
 *
 * $Id: versekey.h 2377 2009-05-04 08:04:55Z scribe $
 *
 * Copyright 1998 CrossWire Bible Society (http://www.crosswire.org)
 *	CrossWire Bible Society
 *	P. O. Box 2528
 *	Tempe, AZ	85280-2528
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation version 2.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the GNU
 * General Public License for more details.
 *
 */


#ifndef VERSEKEY_H
#define VERSEKEY_H

#include <swkey.h>
#include <swmacs.h>
#include <listkey.h>
#include <versemgr.h>

#include <defs.h>

SWORD_NAMESPACE_START

#define POS_MAXVERSE ((char)3)
#define POS_MAXCHAPTER ((char)4)
#define POS_MAXBOOK ((char)5)

#define MAXVERSE SW_POSITION(POS_MAXVERSE)
#define MAXCHAPTER SW_POSITION(POS_MAXCHAPTER)
#define MAXBOOK SW_POSITION(POS_MAXBOOK)



/**
 * Class VerseKey
 * The SWKey implementation used for verse based modules like Bibles or commentaries.
 */
class SWDLLEXPORT VerseKey : public SWKey {

	static SWClass classdef;

	/** number of instantiated VerseKey objects or derivitives
	*/
	static int instance;
	ListKey internalListKey;

	const VerseMgr::System *refSys;

	/** flag for auto normalization
	*/
	char autonorm;

	/** flag for headings on/off
	*/
	char headings;

	/** initialize and allocate books array
	*/
	void initstatics();

	/** initializes this VerseKey()
	*/
	void init(const char *v11n = "KJV");

	// bounds caching is mutable, thus const
	void initBounds() const;

	// private with no bounds check
	void setFromOther(const VerseKey &vk);

	/** Binary search to find the index closest, but less
	* than the given value.
	*
	* @param array long * to array to search
	* @param size number of elements in the array
	* @param value value to find
	* @return the index into the array that is less than but closest to value
	*/
	int findindex(long *array, int size, long value);

	// internal upper/lower bounds optimizations
	mutable long lowerBound, upperBound;	// if autonorms is on
	mutable VerseKey *tmpClone;

	typedef struct { int test; int book; int chap; int verse; } VerseComponents;

	mutable VerseComponents lowerBoundComponents, upperBoundComponents;	// if autonorms is off, we can't optimize with index

protected:

	/** The Testament: 0 - Module Heading; 1 - Old; 2 - New
	*/
	signed char testament;
	signed char book;
	signed int chapter;
	signed int verse;
	signed char suffix;

	/************************************************************************
	 * VerseKey::getBookAbbrev - Attempts to find a book no from a name or
	 *                           abbreviation
	 *
	 * ENT:	@param abbr - key for which to search;
	 * RET:	@return book number or < 0 = not valid
	 */
	virtual int getBookAbbrev(const char *abbr) const;

	/** Refresh keytext based on testament|book|chapter|verse
	* default auto normalization to true
	* default display headings option is false
	*/
	void freshtext() const;
	/**	Parse a character array into testament|book|chapter|verse
	*
	*/
	virtual char parse(bool checkNormalize = true);
public:
#if 0
	static long otbks[];
	static long otcps[];
	static long ntbks[];
	static long ntcps[];
#endif
	int BMAX[2];

	/**
	* VerseKey Constructor - initializes Instance of VerseKey
	*
	* @param ikey text key (will take various forms of 'BOOK CH:VS'.
	* See parse() for more detailed information)
	*/
	VerseKey(const char *ikey = 0);

	/**
	* VerseKey Constructor - initializes instance of VerseKey
	*
	* @param ikey base key (will take various forms of 'BOOK CH:VS'.
	*	See parse() for more detailed information)
	*/
	VerseKey(const SWKey *ikey);

	/** VerseKey Constructor - initializes instance of VerseKey
	* with boundariess - see also LowerBound()
	* and UpperBound()
	* @param min the lower boundary of the new	VerseKey
	* @param max the upper boundary of the new	VerseKey
	*/
	VerseKey(const char *min, const char *max, const char *v11n = "KJV");

	/**	VerseKey Copy Constructor - will create a new VerseKey
	* based on an existing SWKey
	*
	* @param k the	VerseKey to copy from
	*/
	VerseKey(const SWKey &k);

	/**	VerseKey Copy Constructor - will create a new VerseKey
	* based on an existing one
	*
	* @param k the	VerseKey to copy from
	*/
	VerseKey(const VerseKey &k);

	/**	VerseKey Destructor
	* Cleans up an instance of VerseKey
	*/
	virtual ~VerseKey();

	/** sets the lower boundary for this	VerseKey
	* and returns the new boundary
	*
	* @param ub the new upper boundary for this	VerseKey
	* @return the lower boundary the key was set to
	*/
	VerseKey &LowerBound(const VerseKey &ub);

	/** sets the upper boundary for this	VerseKey
	* and returns the new boundary
	* @param ub the new upper boundary for this	VerseKey
	* @return the upper boundary the key was set to
	*/
	VerseKey &UpperBound(const VerseKey &ub);

	/** gets the lower boundary of this	VerseKey
	* @return the lower boundary of this	VerseKey
	*/
	VerseKey &LowerBound() const;

	/** gets the upper boundary of this	VerseKey
	* @return the upper boundary of this	VerseKey
	*/
	VerseKey &UpperBound() const;

	/** clears the boundaries of this	VerseKey
	*/
	void ClearBounds();

	/** Creates a new	SWKey based on the current	VerseKey
	* see also the Copy Constructor
	*/
	virtual SWKey *clone() const;

	/** refreshes keytext before returning if cast to
	* a (char *) is requested
	*/
	virtual const char *getText() const;
	virtual const char *getShortText() const;
	virtual void setText(const char *ikey, bool checkNormalize) { SWKey::setText(ikey); parse(checkNormalize); }
	virtual void setText(const char *ikey) { SWKey::setText(ikey); parse(); }
	virtual void copyFrom(const SWKey &ikey);

	/** Equates this VerseKey to another VerseKey
	*/
	virtual void copyFrom(const VerseKey &ikey);

	/** Only repositions this VerseKey to another VerseKey
	*/
	virtual void positionFrom(const SWKey &ikey);

	/** Positions this key
	*
	* @param newpos Position to set to.
	* @return *this
	*/
	virtual void setPosition(SW_POSITION newpos);

	/** Decrements key a number of verses
	*
	* @param steps Number of verses to jump backward
	* @return *this
	*/
	virtual void decrement(int steps = 1);

	/** Increments key a number of verses
	*
	* @param steps Number of verses to jump forward
	* @return *this
	*/
	virtual void increment(int steps = 1);
	virtual bool isTraversable() const { return true; }

	/** Get/Set position of this key by Book Name
	 */
	virtual const char *getBookName() const;
	virtual void setBookName(const char *bname);

	virtual const char *getBookAbbrev() const;
	/** Gets testament
	*
	* @return value of testament
	*/
	virtual char Testament() const { return getTestament(); }	// deprecated
	virtual char getTestament() const;

	/** Gets book
	*
	* @return value of book
	*/
	virtual char Book() const { return getBook(); }	// deprecated
	virtual char getBook() const;

	/** Gets chapter
	*
	* @return value of chapter
	*/
	virtual int Chapter() const { return getChapter(); }	// deprecated
	virtual int getChapter() const;
	virtual int getChapterMax() const;

	/** Gets verse
	*
	* @return value of verse
	*/
	virtual int Verse() const { return getVerse(); }		// deprecated
	virtual int getVerse() const;
	virtual int getVerseMax() const;

	/** Gets verse suffix
	*
	* @return value of verse suffix
	*/
	virtual char getSuffix() const;

	/** Sets/gets testament
	*
	* @param itestament value which to set testament
	* [MAXPOS(char)] - only get
	* @return if unchanged -> value of testament,
	* if changed -> previous value of testament
	*/
	virtual char Testament(char itestament) { char retVal = getTestament(); setTestament(itestament); return retVal; } // deprecated
	virtual void setTestament(char itestament);

	/** Sets/gets book
	*
	* @param ibook value which to set book
	* [MAXPOS(char)] - only get
	* @return if unchanged -> value of book,
	* if changed -> previous value of book
	*/
	virtual char Book(char ibook) { char retVal = getBook(); setBook(ibook); return retVal; } // deprecated
	virtual void setBook(char ibook);

	/** Sets/gets chapter
	*
	* @param ichapter value which to set chapter
	* [MAXPOS(int)] - only get
	* @return if unchanged -> value of chapter,
	* if changed -> previous value of chapter
	*/
	virtual int Chapter(int ichapter) { char retVal = getChapter(); setChapter(ichapter); return retVal; } // deprecated
	virtual void setChapter(int ichapter);

	/** Sets/gets verse
	*
	* @param iverse value which to set verse
	* [MAXPOS(int)] - only get
	* @return if unchanged -> value of verse,
	* if changed -> previous value of verse
	*/
	virtual int Verse(int iverse) { char retVal = getVerse(); setVerse(iverse); return retVal; } // deprecated;
	virtual void setVerse(int iverse);

	/** Sets/gets verse suffix
	*
	* @param isuffix value which to set verse suffix
	*/
	virtual void setSuffix(char isuffix);

	/** checks limits and normalizes if necessary (e.g.
	* Matthew 29:47 = Mark 2:2).	If last verse is
	* exceeded, key is set to last Book CH:VS
	*
	* @return *this
	*/
	virtual void Normalize(char autocheck = 0);

	/** Sets/gets flag that tells VerseKey to
	* automatically normalize itself when modified
	*
	* @param iautonorm value which to set autonorm
	* [MAXPOS(char)] - only get
	* @return if unchanged -> value of autonorm,
	* if changed -> previous value of autonorm
	*/
	virtual char AutoNormalize(char iautonorm) { char retVal = isAutoNormalize()?1:0; setAutoNormalize(iautonorm); return retVal; }	// deprecated
	virtual char AutoNormalize() const { return isAutoNormalize()?1:0; }	// deprecated

	virtual bool isAutoNormalize() const;
	virtual void setAutoNormalize(bool iautonorm);

	/** Sets/gets flag that tells VerseKey to include
	* chapter/book/testament/module headings
	*
	* @param iheadings value which to set headings
	* [MAXPOS(char)] - only get
	* @return if unchanged -> value of headings,
	* if changed -> previous value of headings
	*/
	virtual char Headings(char iheadings = MAXPOS(char));

	/** Gets index based upon current verse
	*
	* @return offset
	*/
	virtual long Index() const;

	/** Sets index based upon current verse
	*
	* @param iindex value to set index to
	* @return offset
	*/
	virtual long Index(long iindex);

	/** Gets index into current testament based upon current verse
	*
	* @return offset
	*/
	virtual long TestamentIndex() const;

	virtual const char *getOSISRef() const;
	virtual const char *getOSISBookName() const;

	/** Tries to parse a string and convert it into an OSIS reference
	 * @param inRef reference string to try to parse
	 * @param defaultKey @see ParseVerseList(..., defaultKey, ...)
	 */
	static const char *convertToOSIS(const char *inRef, const SWKey *defaultKey);

	virtual ListKey ParseVerseList(const char *buf, const char *defaultKey = 0, bool expandRange = false, bool useChapterAsVerse = false);
	virtual const char *getRangeText() const;
	virtual const char *getOSISRefRangeText() const;
	/** Compares another	SWKey object
	*
	* @param ikey key to compare with this one
	* @return >0 if this	VerseKey is greater than compare	SWKey,
	* <0 if this	VerseKey is smaller than compare	SWKey,
	* 0 if the keys are the same
	*/
	virtual int compare(const SWKey &ikey);

	/** Compares another	VerseKey object
	*
	* @param ikey key to compare with this one
	* @return >0 if this	VerseKey is greater than compare	VerseKey,
	* <0 if this	VerseKey is smaller than compare	VerseKey,
	* 0 if the keys are the same
	*/
	virtual int _compare(const VerseKey &ikey);

	virtual void setVersificationSystem(const char *name);
	virtual const char *getVersificationSystem() const;

	// DEBUG
	void validateCurrentLocale() const;


	// OPERATORS --------------------------------------------------------------------


	SWKEY_OPERATORS

	virtual SWKey &operator =(const VerseKey &ikey) { positionFrom(ikey); return *this; }
};

SWORD_NAMESPACE_END

#endif //VERSEKEY_H
