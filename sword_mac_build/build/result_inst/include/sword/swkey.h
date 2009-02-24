/******************************************************************************
 *  swkey.h	- code for base class 'swkey'.  swkey is the basis for all
 *				types of keys for indexing into modules (e.g. verse, word,
 *				place, etc.)
 *
 * $Id: swkey.h 2195 2008-09-11 00:20:58Z scribe $
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

#ifndef SWKEY_H
#define SWKEY_H

#include <swobject.h>

#include <defs.h>

SWORD_NAMESPACE_START

#define KEYERR_OUTOFBOUNDS 1

#define SWKEY_OPERATORS \
  SWKey &operator =(const char *ikey) { setText(ikey); return *this; } \
  SWKey &operator =(const SWKey &ikey) { copyFrom(ikey); return *this; } \
  SWKey &operator =(SW_POSITION pos) { setPosition(pos); return *this; } \
  operator const char *() const { return getText(); } \
  bool operator ==(const SWKey &ikey) { return equals(ikey); } \
  bool operator !=(const SWKey &ikey) { return !equals(ikey); } \
  virtual bool operator >(const SWKey &ikey) { return (compare(ikey) > 0); } \
  virtual bool operator <(const SWKey &ikey) { return (compare(ikey) < 0); } \
  virtual bool operator >=(const SWKey &ikey) { return (compare(ikey) > -1); }  \
  virtual bool operator <=(const SWKey &ikey) { return (compare(ikey) < 1); } \
  SWKey &operator -=(int steps) { decrement(steps); return *this; } \
  SWKey &operator +=(int steps) { increment(steps); return *this; } \
  SWKey &operator ++()    { increment(1); return *this; } \
  SWKey  operator ++(int) { SWKey temp = *this; increment(1); return temp; } \
  SWKey &operator --()    { decrement(1); return *this; } \
  SWKey  operator --(int) { SWKey temp = *this; decrement(1); return temp; }


/** For use with = operator to position key.
*/
class SW_POSITION {
	char pos;
public:
	SW_POSITION(char ipos) { pos = ipos; }
	operator char() { return pos; }
};

#define POS_TOP ((char)1)
#define POS_BOTTOM ((char)2)

#define TOP SW_POSITION(POS_TOP)
#define BOTTOM SW_POSITION(POS_BOTTOM)

/** SWKey is used for positioning an SWModule to a specific entry.
 *	It always represents a possible location into a module and can additionally represent
 *	a domain of entries (e.g. "John 3:16" in the domain "John 1:1 - Mark 5:25")
 */
class SWDLLEXPORT SWKey : public SWObject {
	long index;
	static SWClass classdef;
	void init();

protected:
	char *keytext;
	mutable char *rangeText;
	mutable bool boundSet;
	char persist;
	char error;

public:

	// misc pointer for whatever
	void *userData;

	/** initializes instance of SWKey from a string
	 * All keys can be reduced to a string representation which should be able
	 *	to be used to again set the key to the same position
	 * @param ikey string to use for initializing this new key
	 */
	SWKey(const char *ikey = 0);

	/** Copy Constructor
	 * @param k The SWKey object to copy.
	 */
	SWKey(SWKey const &k);

	/** Destructor, cleans up this instance of SWKey
	 */
	virtual ~SWKey();

	/** Returns a new exact clone of this SWKey object.  This allocates
	 * a new SWKey which must be deleted by the caller
	 * @return new clone of this key
	 */
	virtual SWKey *clone() const;

	/** Gets whether this key should persist in any module to which it is set
	 * otherwise just a copy will be used in the module.
	 * @return 1 - persists in module; 0 - a copy is attempted
	 */
	char Persist() const;

	/** Sets whether this key should persist in any module to which it is set
	 * otherwise just a copy will be used in the module.
	 * @param ipersist value which to set persist;
	 * @return 1 - persists in module; 0 - a copy is attempted
	 */
	char Persist(signed char ipersist);

	/** Gets and clears error status
	 * @return error status
	 */
	virtual char Error();
	virtual void setError(char err) { error = err; }

	/** Sets this SWKey with a character string
	 * @param ikey string used to set this key
	 */
	virtual void setText(const char *ikey);

	/** Copies as much info (position, range, etc.) as possible from another SWKey object
	 * @param ikey other SWKey object from which to copy
	 */
	virtual void copyFrom(const SWKey &ikey);

	/** returns string representation of this key 
	 */
	virtual const char *getText() const;
	virtual const char *getShortText() const { return getText(); }
	virtual const char *getRangeText() const;
	virtual const char *getOSISRefRangeText() const;
	virtual bool isBoundSet() const { return boundSet; }
	virtual void clearBound() const { boundSet = false; }

	/** Compares this key object to another SWKey object
	 * @param ikey key to compare with this one
	 * @return >0 if this key is greater than compare key;
	 *	<0 if this key is smaller than compare key;
	 *	0 if the keys are the same
	 */
	virtual int compare(const SWKey &ikey);

	/** test equality of this SWKey object's position with another SWKey
	 * @param ikey key to compare with this one
	 * @return true if the key positions are equal
	 */
	virtual bool equals(const SWKey &ikey) { return !compare(ikey); }

	virtual void setPosition(SW_POSITION);

	/** Decrements key a number of entry positions
	 * This is only valid if isTraversable is true
	 * @param steps Number of entries to jump backward
	 */
	virtual void decrement(int steps = 1);

	/** Increments key a number of entry positions
	 * This is only valid if isTraversable is true
	 * @param steps Number of entries to jump forward
	 */
	virtual void increment(int steps = 1);

	/** deprecated, use isTraversible
	 */
	char Traversable() { return (isTraversable()) ? 1:0; }

	/** Whether or not this key can be ++ -- incremented
	 */
	virtual bool isTraversable() const { return false; }

	/** Use this function to get an index position within a module.
	 * Here's a small example how to use this function and @ref Index(long).
	 * This function uses the GerLut module and chooses a random verse from the
	 * Bible and returns it.
	 * @code
	 * const char* randomVerse() {
	 *   VerseKey vk;
	 *   SWMgr mgr;
	 *   LocaleMgr::getSystemLocaleMgr()->setDefaultLocaleName("de");
	 *
	 *   SWModule* module = mgr->Modules("GerLut");
	 *   srand( time(0) );
	 *   const double newIndex = (double(rand())/RAND_MAX)*(24108+8224);
	 *   vk.Index(newIndex);
	 *   module->setKey(vk);
	 *
	 *   char* text;
	 *   sprintf(text, "%s: %s",(const char*)vk ,module->StripText(&vk));
	 *   return text;
	 * @endcode
	 */
	virtual long Index() const { return index; }

	/** See documentation for @ref Index()
	 */
	virtual long Index(long iindex) { index = iindex; return index; }

	SWKEY_OPERATORS

	};

SWORD_NAMESPACE_END
#endif
