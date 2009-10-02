/******************************************************************************
 *	stringmgr.h - A class which provides string handling functions which can 
 *			be reimplemented by frontends
 *
 * $Id: stringmgr.h 2098 2007-10-07 18:57:07Z scribe $
 *
 * Copyright 2005 CrossWire Bible Society (http://www.crosswire.org)
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


#ifndef STRINGMGR_H
#define STRINGMGR_H

#include <defs.h>
#include <swbuf.h>
#include <utilstr.h>

SWORD_NAMESPACE_START

/** StringMgr is a way to provide UTf8 handling by the Sword frontend
 * Each platform, if it's up-to-date, should provide functions to handle unicode and utf8. This class makes it possible to implement Unicode support on the user-side and not in Sword itself.
 */
class SWDLLEXPORT StringMgr {
public:

	/** Sets the global StringMgr handle
	* @param newStringMgr The new global StringMgr. This pointer will be deleted by this StringMgr
	*/	
	static void setSystemStringMgr(StringMgr *newStringMgr);
   
	/** Returns the global StringMgr handle
	* @return The global string handle
	*/
	static StringMgr *getSystemStringMgr();

	/** Checks whether Utf8 support is available.
	* Override the function supportsUnicode() to tell whether your implementation has utf8 support.
	* @return True if this implementation provides support for Utf8 handling or false if just latin1 handling is available
	*/
	static inline bool hasUTF8Support() {
		return getSystemStringMgr()->supportsUnicode();
	};
	
	/** Converts the param to an upper case Utf8 string
	* @param text The text encoded in utf8 which should be turned into an upper case string
	* @param max Max buffer size
	* @return text buffer (only for convenience)
	*/	
	virtual char *upperUTF8(char *text, unsigned int max = 0) const;
   
	/** Converts the param to an uppercase latin1 string
	* @param text The text encoded in latin1 which should be turned into an upper case string
	* @param max Max buffer size
	* @return text buffer (only for convenience)
	*/	
	virtual char *upperLatin1(char *text, unsigned int max = 0) const;
	

protected:
	friend class __staticsystemStringMgr;
	
	/** Default constructor. Protected to make instances on user side impossible, because this is a Singleton
	*/		
	StringMgr();
   
	/** Copy constructor
	*/	
	StringMgr(const StringMgr &);
   
	/** Destructor
	*/	
	virtual ~StringMgr();
	
	virtual bool supportsUnicode() const;

private:
	static StringMgr *systemStringMgr;
};

inline char *toupperstr(char *t, unsigned int max = 0) {
	return StringMgr::getSystemStringMgr()->upperUTF8(t, max);
}
	
inline char *toupperstr_utf8(char *t, unsigned int max = 0) {
	return StringMgr::getSystemStringMgr()->upperUTF8(t, max);
}
	
/**
 * Converts an SWBuf filled with UTF-8 to upper case
 *
 * @param b SWBuf to change to upper case
 * 
 * @return b for convenience
 */
inline SWBuf &toupperstr(SWBuf &b) {
	char *utf8 = 0;
	stdstr(&utf8, b.c_str(), 2);
	toupperstr(utf8, strlen(utf8)*2);
	b = utf8;
	delete [] utf8;
	return b;
}

SWORD_NAMESPACE_END


#endif //STRINGMGR_H
