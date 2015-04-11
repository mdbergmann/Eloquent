/******************************************************************************
 *
 *  multimapwdef.h -	Implementation of multimapwithdefault
 *
 * $Id: multimapwdef.h 2935 2013-08-02 11:06:30Z scribe $
 *
 * Copyright 2002-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef MULTIMAPWDEF_H
#define MULTIMAPWDEF_H

#include <map>

SWORD_NAMESPACE_START

// multmap that still lets you use [] to reference FIRST
// entry of a key if multiples exist
template <class Key, class T, class Compare>
class multimapwithdefault : public std::multimap<Key, T, Compare> {
public:
	typedef std::pair<const Key, T> value_type;
	T& getWithDefault(const Key& k, const T& defaultValue) {
		if (find(k) == this->end()) {
			insert(value_type(k, defaultValue));
		}
		return (*(find(k))).second;
	}

	T& operator[](const Key& k) {
		if (this->find(k) == this->end()) {
			this->insert(value_type(k, T()));
		}
		return (*(this->find(k))).second;
	}
	bool has(const Key& k, const T &val) const {
		typename std::multimap<Key, T, Compare>::const_iterator start = this->lower_bound(k);
		typename std::multimap<Key, T, Compare>::const_iterator end = this->upper_bound(k);
		for (; start!=end; start++) {
			if (start->second == val)
				return true;
		}
		return false;
	}
};

SWORD_NAMESPACE_END
#endif
