/******************************************************************************
 *
 *  versification.h -	definition of class VersificationMgr used for managing
 *			versification systems
 *
 * $Id: versificationmgr.h 3240 2014-07-12 16:27:35Z scribe $
 *
 * Copyright 2008-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#include <list>
#include <defs.h>
#include <swcacher.h>
#include <swbuf.h>


#ifndef VERSIFICATIONMGR_H
#define VERSIFICATIONMGR_H


SWORD_NAMESPACE_START

typedef std::list <SWBuf>StringList;

struct sbook;
class TreeKey;


struct abbrev
{
	const char *ab;
	const char *osis;
};

struct sbook {
	/**Name of book
	*/
	const char *name;

	/**OSIS name
	*/
	const char *osis;

	/**Preferred Abbreviation
	*/
	const char *prefAbbrev;

	/**Maximum chapters in book
	*/
	unsigned char chapmax;
	/** Array[chapmax] of maximum verses in chapters
	*/
	int *versemax;
};


class SWDLLEXPORT VersificationMgr : public SWCacher {


public:
	class System;

private:
	friend class __staticsystemVersificationMgr;

	class Private;
	Private *p;

	void init();

protected:
	static VersificationMgr *systemVersificationMgr;

public:
	class SWDLLEXPORT Book {
		friend class System;
		friend struct BookOffsetLess;
		class Private;
		Private *p;

		/** book name */
		SWBuf longName;

		/** OSIS Abbreviation */
		SWBuf osisName;

		/** Preferred Abbreviation */
		SWBuf prefAbbrev;

		/** Maximum chapters in book */
		unsigned int chapMax;

		void init();

	public:
		Book() { init(); }
		Book(const Book &other);
		Book &operator =(const Book &other);
		Book(const char *longName, const char *osisName, const char *prefAbbrev, int chapMax) {
			this->longName = longName;
			this->osisName = osisName;
			this->prefAbbrev = prefAbbrev;
			this->chapMax = chapMax;
			init();
		}
		~Book();
		const char *getLongName() const { return longName.c_str(); }
		const char *getOSISName() const { return osisName.c_str(); }
		const char *getPreferredAbbreviation() const { return prefAbbrev.c_str(); }
		int getChapterMax() const { return chapMax; }
		int getVerseMax(int chapter) const;
	};

	class SWDLLEXPORT System {
		class Private;
		Private *p;
		SWBuf name;
		int BMAX[2];
		long ntStartOffset;
		void init();
	public:
		System() { this->name = ""; init(); }
		System(const System &other);
		System &operator =(const System &other);
		System(const char *name) { this->name = name; init(); }
		~System();
		const char *getName() const { return name.c_str(); }
		const Book *getBookByName(const char *bookName) const;
		int getBookNumberByOSISName(const char *bookName) const;
		const Book *getBook(int number) const;
		int getBookCount() const;
		void loadFromSBook(const sbook *ot, const sbook *nt, int *chMax, const unsigned char *mappings=NULL);
		long getOffsetFromVerse(int book, int chapter, int verse) const;
		char getVerseFromOffset(long offset, int *book, int *chapter, int *verse) const;
		const int *getBMAX() const { return BMAX; };
		long getNTStartOffset() const { return ntStartOffset; }
		void translateVerse(const System *dstSys, const char **book, int *chapter, int *verse, int *verse_end) const;
	};
	VersificationMgr() { init(); }
	~VersificationMgr();
	static VersificationMgr *getSystemVersificationMgr();
	static void setSystemVersificationMgr(VersificationMgr *newVersificationMgr);
	const StringList getVersificationSystems() const;
	const System *getVersificationSystem(const char *name) const;
	void registerVersificationSystem(const char *name, const sbook *ot, const sbook *nt, int *chMax, const unsigned char *mappings=NULL);
	void registerVersificationSystem(const char *name, const TreeKey *);
};

SWDLLEXPORT extern const struct abbrev builtin_abbrevs[];

SWORD_NAMESPACE_END
#endif
