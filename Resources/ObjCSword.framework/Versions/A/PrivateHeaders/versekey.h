/******************************************************************************
 *
 *  versekey.h -	code for class 'VerseKey'- a standard Biblical verse
 *			key
 *
 * $Id: versekey.h 2833 2013-06-29 06:40:28Z chrislit $
 *
 * Copyright 1997-2013 CrossWire Bible Society (http://www.crosswire.org)
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
#include <versificationmgr.h>

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

	const VersificationMgr::System *refSys;

	/** flag for auto normalization
	*/
	char autonorm;

	/** flag for intros on/off
	*/
	char intros;

	/** initializes this VerseKey()
	*/
	void init(const char *v11n = "KJV");

	// bounds caching is mutable, thus const
	void initBounds() const;

	// private with no bounds check
	void setFromOther(const VerseKey &vk);

	void checkBounds();

	// internal upper/lower bounds optimizations
	mutable long lowerBound, upperBound;	// if autonorms is on
	mutable VerseKey *tmpClone;

	typedef struct { int test; int book; int chap; int verse; char suffix; } VerseComponents;

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
	 * VerseKey::getBookFromAbbrev - Attempts to find a book no from a name or
	 *                           abbreviation
	 *
	 * ENT:	@param abbr - key for which to search;
	 * RET:	@return book number or < 0 = not valid
	 */
	virtual int getBookFromAbbrev(const char *abbr) const;

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

	/** sets the lower boundary for this VerseKey
	*
	* @param lb the new lower boundary for this VerseKey
	*/
	void setLowerBound(const VerseKey &lb);
	SWDEPRECATED VerseKey &LowerBound(const VerseKey &lb) { setLowerBound(lb); return getLowerBound(); }

	/** sets the upper boundary for this VerseKey
	* @param ub the new upper boundary for this VerseKey
	* @return the upper boundary the key was set to
	*/
	void setUpperBound(const VerseKey &ub);
	SWDEPRECATED VerseKey &UpperBound(const VerseKey &ub) { setUpperBound(ub); return getUpperBound(); }

	/** gets the lower boundary of this VerseKey
	* @return the lower boundary of this VerseKey
	*/
	VerseKey &getLowerBound() const;
	SWDEPRECATED VerseKey &LowerBound() const { return getLowerBound(); }

	/** gets the upper boundary of this VerseKey
	* @return the upper boundary of this VerseKey
	*/
	VerseKey &getUpperBound() const;
	SWDEPRECATED VerseKey &UpperBound() const { return getUpperBound(); }

	/** clears the boundaries of this VerseKey
	*/
	void clearBounds();
	SWDEPRECATED void ClearBounds() { clearBounds(); }

	/** Creates a new SWKey based on the current VerseKey
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
	virtual char getTestament() const;
	/**
	* @deprecated Use getTestament() instead.
	*/
	SWDEPRECATED char Testament() const { return getTestament(); }	// deprecated
	virtual int getTestamentMax() const { return 2; }

	/** Gets book
	*
	* @return value of book
	*/
	virtual char getBook() const;
	/**
	* @deprecated Use getBook() instead.
	*/
	SWDEPRECATED char Book() const { return getBook(); }	// deprecated
	virtual int getBookMax() const { return BMAX[testament-1]; }

	/** Gets chapter
	*
	* @return value of chapter
	*/
	virtual int getChapter() const;
	/**
	* @deprecated Use getChapter() instead.
	*/
	SWDEPRECATED int Chapter() const { return getChapter(); }	// deprecated
	virtual int getChapterMax() const;

	/** Gets verse
	*
	* @return value of verse
	*/
	virtual int getVerse() const;
	/**
	* @deprecated Use getVerse() instead.
	*/
	SWDEPRECATED int Verse() const { return getVerse(); }		// deprecated
	virtual int getVerseMax() const;

	/** Gets verse suffix
	*
	* @return value of verse suffix
	*/
	virtual char getSuffix() const;

	/** Sets testament
	*
	* @param itestament value which to set testament
	*/
	virtual void setTestament(char itestament);
	/**
	* @deprecated Use setTestament() instead.
	*/
	SWDEPRECATED char Testament(char itestament) { char retVal = getTestament(); setTestament(itestament); return retVal; } // deprecated

	/** Sets book
	*
	* @param ibook value which to set book
	*/
	virtual void setBook(char ibook);
	/**
	* @deprecated Use setBook() instead.
	*/
	SWDEPRECATED char Book(char ibook) { char retVal = getBook(); setBook(ibook); return retVal; } // deprecated

	/** Sets chapter
	*
	* @param ichapter value which to set chapter
	*/
	virtual void setChapter(int ichapter);
	/**
	* @deprecated Use setChapter() instead.
	*/
	SWDEPRECATED int Chapter(int ichapter) { char retVal = getChapter(); setChapter(ichapter); return retVal; } // deprecated

	/** Sets verse
	*
	* @param iverse value which to set verse
	*/
	virtual void setVerse(int iverse);
	/**
	* @deprecated Use setVerse() instead.
	*/
	SWDEPRECATED int Verse(int iverse) { char retVal = getVerse(); setVerse(iverse); return retVal; } // deprecated;

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
	virtual void normalize(bool autocheck = false);
	SWDEPRECATED void Normalize(char autocheck = 0) { normalize(autocheck!=0); }

	/** Sets flag that tells VerseKey to
	* automatically normalize itself when modified
	*
	* @param iautonorm value which to set autonorm
	* [MAXPOS(char)] - only get
	* @return if unchanged -> value of autonorm,
	* if changed -> previous value of autonorm
	*/
	virtual void setAutoNormalize(bool iautonorm);
	virtual bool isAutoNormalize() const;

	/**
	* @deprecated Use setAutoNormalize() instead.
	*/
	SWDEPRECATED char AutoNormalize(char iautonorm) { char retVal = isAutoNormalize()?1:0; setAutoNormalize(iautonorm!=0); return retVal; }	// deprecated
	/**
	* @deprecated Use isAutoNormalize() instead.
	*/
	SWDEPRECATED char AutoNormalize() const { return isAutoNormalize()?1:0; }	// deprecated


	/** Sets/gets flag that tells VerseKey to include
	* chapter/book/testament/module intros
	*
	* @deprecated Use setIntros() and isIntros() instead.
	* @param iheadings value which to set intros
	* [MAXPOS(char)] - only get
	* @return if unchanged -> value of intros,
	* if changed -> previous value of intros
	*/
	SWDEPRECATED char Headings(char iheadings = MAXPOS(char)) { char retVal = isIntros(); if (iheadings != MAXPOS(char)) setIntros(iheadings!=0); return retVal; }

	/** The Intros property determine whether or not to include
	* chapter/book/testament/module intros
	*/
	virtual void setIntros(bool val);
	virtual bool isIntros() const;


	/** Gets index based upon current verse
	*
	* @return offset
	*/
	virtual long getIndex() const;


	/** Sets index based upon current verse
	*
	* @param iindex value to set index to
	* @return offset
	*/
	virtual void setIndex(long iindex);


	/** Gets index into current testament based upon current verse
	*
	* @return offset
	*/
	virtual long getTestamentIndex() const;

	/**
	* @deprecated Use getTestamentIndex()
	*/
	SWDEPRECATED long TestamentIndex() const { return getTestamentIndex(); }	// deprecated, use getTestamentIndex()

	virtual const char *getOSISRef() const;
	virtual const char *getOSISBookName() const;

	/** Tries to parse a string and convert it into an OSIS reference
	 * @param inRef reference string to try to parse
	 * @param defaultKey @see ParseVerseList(..., defaultKey, ...)
	 */
	static const char *convertToOSIS(const char *inRef, const SWKey *defaultKey);

	/******************************************************************************
	 * VerseKey::parseVerseList - Attempts to parse a buffer into separate
	 *				verse entries returned in a ListKey
	 *
	 * ENT:	buf		- buffer to parse;
	 *	defaultKey	- if verse, chap, book, or testament is left off,
	 *				pull info from this key (ie. Gen 2:3; 4:5;
	 *				Gen would be used when parsing the 4:5 section)
	 *	expandRange	- whether or not to expand eg. John 1:10-12 or just
	 *				save John 1:10
	 *
	 * RET:	ListKey reference filled with verse entries contained in buf
	 *
	 * COMMENT: This code works but wreaks.  Rewrite to make more maintainable.
	 */
	virtual ListKey parseVerseList(const char *buf, const char *defaultKey = 0, bool expandRange = false, bool useChapterAsVerse = false);
	SWDEPRECATED ListKey ParseVerseList(const char *buf, const char *defaultKey = 0, bool expandRange = false, bool useChapterAsVerse = false) { return parseVerseList(buf, defaultKey, expandRange, useChapterAsVerse); }
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
