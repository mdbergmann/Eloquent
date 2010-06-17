/******************************************************************************
 * listkey.h	- code for base class 'listkey'.  listkey is the basis for all
 *				types of keys for indexing into modules
 *				(e.g. verse, word,
 *				place, etc.)
 *
 * $Id: listkey.h 2195 2008-09-11 00:20:58Z scribe $
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

#ifndef SWLSTKEY_H
#define SWLSTKEY_H

#include <swkey.h>

#include <defs.h>

SWORD_NAMESPACE_START

  /** ListKey is the basis for all
  * types of keys that have lists of specified indexes
  * (e.g. a list of verses, place, etc.)
  */
class SWDLLEXPORT ListKey : public SWKey {

	static SWClass classdef;
	void init();

protected:
	int arraypos;
	int arraymax;
	int arraycnt;
	SWKey **array;

public:

	/** initializes instance of ListKey
	 *
	 * @param ikey text key
	 */
	ListKey(const char *ikey = 0);
	ListKey(ListKey const &k);

	/** cleans up instance of ListKey
	 */
	virtual ~ListKey();

	virtual SWKey *clone() const;
	
	/** Clears out elements of list
	 */
	virtual void clear();

	/** deprecated, use clear(), instead
	 */
	virtual void ClearList() { clear(); }

	/** Returns number of elements in list
	 * @return number of elements in list
	 */
	virtual int Count();
	
	/** Removes current element from list
	 */
	virtual void Remove();
	
	/** Sets key to element number
	 *
	 * @param ielement element number to set to
	 * @return error status
	 */
	virtual char SetToElement(int ielement, SW_POSITION = TOP);
	
	/** Gets a key element number
	 *
	 * @param pos element number to get (or default current)
	 * @return Key or null on error
	 */
	virtual SWKey *getElement(int pos = -1);
	
	// deprecated, use above function
	virtual SWKey *GetElement(int pos = -1) { return getElement(pos); }

	/** Adds an element to the list
	 * @param ikey the element to add
	 */
	ListKey & operator <<(const SWKey &ikey) { add(ikey); return *this; }
	virtual void add(const SWKey &ikey);

	/** Equates this ListKey to another ListKey object
	 *
	 * @param ikey other ListKey object
	 */
	virtual void copyFrom(const ListKey & ikey);
	virtual void copyFrom(const SWKey & ikey) { SWKey::copyFrom(ikey); }

	/** Positions this key
	 *
	 * @param pos position
	 * @return *this
	 */
	virtual void setPosition(SW_POSITION pos);
	
	/** Decrements a number of elements
	 */
	virtual void decrement(int step = 1);
	
	/** Increments a number of elements
	 */
	virtual void increment(int step = 1);

	virtual bool isTraversable() const { return true; }
	virtual long Index() const { return arraypos; }
	virtual const char *getRangeText() const;
	virtual const char *getOSISRefRangeText() const;

	/**
	 * Returns the index for the new one given as as parameter.
	 * The first parameter is the new index.
	 */
	virtual long Index(long index) { SetToElement(index); return Index (); }
	virtual const char *getText() const;
	virtual void setText(const char *ikey);
	virtual void sort();

	SWKEY_OPERATORS
	ListKey & operator =(const ListKey &key) { copyFrom(key); return *this; }
};

SWORD_NAMESPACE_END
#endif
