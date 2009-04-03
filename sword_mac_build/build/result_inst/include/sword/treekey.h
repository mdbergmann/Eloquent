/******************************************************************************
 *  versekey.h - code for class 'versekey'- a standard Biblical verse key
 *
 * $Id: treekey.h 2280 2009-03-07 15:34:36Z scribe $
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


#ifndef TREEKEY_H
#define TREEKEY_H

#include <swkey.h>
#include <swbuf.h>

#include <defs.h>

SWORD_NAMESPACE_START

/**
 * Class TreeKey
 * The base class for all tree-based key implementations in Sword.
 */
class SWDLLEXPORT TreeKey : public SWKey {
	static SWClass classdef;
	void init();

protected:
	// hold on to setText until we've done a snap action: getText or navigation
	// if we set, and then write out userData, we want to assure the path exists.
	// This better conforms to the SWORD write methodology: mod.setKey, mod.setEntry
	mutable SWBuf unsnappedKeyText;

	// called whenever position of this key is changed.  Should we move this
	// to a more base class?
	void positionChanged() { if (posChangeListener) posChangeListener->positionChanged(); }

public:

	class PositionChangeListener {
		TreeKey *treeKey;
	public:
		PositionChangeListener() {}
		virtual ~PositionChangeListener() {}
		virtual void positionChanged() = 0;
		TreeKey *getTreeKey() { return treeKey; }
		void setTreeKey(TreeKey *tk) { treeKey = tk; }
	} *posChangeListener;

	void setPositionChangeListener(PositionChangeListener *pcl) { posChangeListener = pcl; posChangeListener->setTreeKey(this); }

//	TreeKey (const char *ikey = 0);
//	TreeKey (const SWKey * ikey);
//	TreeKey (TreeKey const &k);
	TreeKey () { init(); };
	~TreeKey () {};


	virtual const char *getLocalName() = 0;
	virtual const char *setLocalName(const char *) = 0;

	virtual int getLevel() { long bm = getOffset(); int level = 0; do { level++; } while (parent()); setOffset(bm); return level; }

	virtual const char *getUserData(int *size = 0) const = 0;
	virtual void setUserData(const char *userData, int size = 0) = 0;

	/** Go to the root node
	*/
	virtual void root() = 0;

	/** Go to the parent of the current node
	* @return success or failure
	*/
	virtual bool parent() = 0;

	/** Go to the first child of the current node
	* @return success or failure
	*/
	virtual bool firstChild() = 0;

	/** Go to the next sibling of the current node
	* @return success or failure
	*/
	virtual bool nextSibling() = 0;

	/** Go to the previous sibling of the current node
	* @return success or failure
	*/
	virtual bool previousSibling() = 0;

	/** Does the current node have children?
	* @return whether or not it does
	*/
	virtual bool hasChildren() = 0;

	virtual void append() = 0;
	virtual void appendChild() = 0;
	virtual void insertBefore() = 0;

	virtual void remove() = 0;


	virtual void setOffset(unsigned long offset) = 0;
	virtual unsigned long getOffset() const = 0;

	virtual void setText(const char *ikey) = 0;
	virtual void setPosition(SW_POSITION p) = 0;
	virtual const char *getText() const = 0;
	virtual int compare(const SWKey &ikey) = 0;
	virtual void decrement(int steps = 1) = 0;
	virtual void increment(int steps = 1) = 0;
	virtual bool isTraversable() const { return true; }
	virtual long Index() const { return getOffset(); }
	virtual long Index(long iindex) { setOffset(iindex); return getOffset(); }

	/** Set the key to this path.  If the path doesn't exist, then
	 *	nodes are created as necessary
	 * @param keyPath path to set/create; if unsupplied, then use any unsnapped setText value.
	 */
	virtual void assureKeyPath(const char *keyPath = 0);
	virtual void save() {}

	SWKEY_OPERATORS

	};

SWORD_NAMESPACE_END
#endif
