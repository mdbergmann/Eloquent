/******************************************************************************
 *	versekey.h - code for class 'versekey'- a standard Biblical verse key
 *
 * $Id: versekey.h 1864 2005-11-20 06:06:40Z scribe $
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


#ifndef VERSETREEKEY_H
#define VERSETREEKEY_H

#include <versekey.h>
#include <treekey.h>
#include <swmacs.h>
#include <listkey.h>

#include <defs.h>

SWORD_NAMESPACE_START

/**
 * Class VerseKey
 * The SWKey implementation used for verse based modules like Bibles or commentaries.
 */
class SWDLLEXPORT VerseTreeKey : public VerseKey, public TreeKey::PositionChangeListener {

	static SWClass classdef;
	TreeKey *treeKey;
//	vector<struct sbook> books;

	void init(TreeKey *treeKey);
	void syncVerseToTree();
	long lastGoodOffset;

protected:
	virtual int getBookAbbrev(const char *abbr);

public:

	/**
	* VerseKey Constructor - initializes Instance of VerseKey
	*
	* @param treeKey a TreeKey which will form the basis of this VerseTreeKey
	* @param ikey text key (will take various forms of 'BOOK CH:VS'.
	* See parse() for more detailed information)
	*/
	VerseTreeKey(TreeKey *treeKey, const char *ikey = 0);
	
	/**
	* VerseKey Constructor - initializes instance of VerseKey
	*
	* @param treeKey a TreeKey which will form the basis of this VerseTreeKey
	* @param ikey base key (will take various forms of 'BOOK CH:VS'.
	*	See parse() for more detailed information)
	*/	
	VerseTreeKey(TreeKey *treeKey, const SWKey *ikey);
	
	/** VerseKey Constructor - initializes instance of VerseKey
	* with boundariess - see also LowerBound()
	* and UpperBound()
	* @param treeKey a TreeKey which will form the basis of this VerseTreeKey
	* @param min the lower boundary of the new	VerseKey
	* @param max the upper boundary of the new	VerseKey
	*/	
	VerseTreeKey(TreeKey *treeKey, const char *min, const char *max);
	
	/**	VerseKey Copy Constructor - will create a new	VerseKey
	* based on an existing one
	*
	* @param k the	VerseKey to copy from
	*/
	VerseTreeKey(const VerseTreeKey &k);
	

	/**	VerseKey Destructor
	* Cleans up an instance of VerseKey
	*/
	virtual ~VerseTreeKey();

	/** Creates a new	SWKey based on the current	VerseKey
	* see also the Copy Constructor
	*/
	virtual SWKey *clone() const;
	
	virtual bool isTraversable() const { return true; }

	virtual TreeKey *getTreeKey();

	// TreeKey::PositionChangeListener interface
	virtual void positionChanged();
	bool internalPosChange;

	virtual void decrement(int steps = 1);
	virtual void increment(int steps = 1);
	
	virtual void Normalize(char autocheck = 0);

	virtual void setPosition(SW_POSITION newpos);
	virtual long NewIndex() const;
	// OPERATORS --------------------------------------------------------------------


	SWKEY_OPERATORS

	virtual SWKey & operator = (const VerseKey & ikey) { copyFrom(ikey); return *this; }
//	virtual void copyFrom(const VerseTreeKey &ikey);
};

SWORD_NAMESPACE_END

#endif //VERSETREEKEY_H
