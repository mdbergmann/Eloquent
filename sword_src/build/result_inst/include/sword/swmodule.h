/******************************************************************************
 *  swmodule.h  - code for base class 'module'.  Module is the basis for all
 *		  types of modules (e.g. texts, commentaries, maps, lexicons,
 *		  etc.)
 *
 * $Id: swmodule.h 2318 2009-04-10 21:22:16Z scribe $
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

#ifndef SWMODULE_H
#define SWMODULE_H

#include <swdisp.h>
#include <listkey.h>
#include <swconfig.h>

#include <swcacher.h>
#include <swsearchable.h>

#include <list>

#include <defs.h>

SWORD_NAMESPACE_START

class SWOptionFilter;
class SWFilter;

#define SEARCHFLAG_MATCHWHOLEENTRY 4096

#define SWMODULE_OPERATORS \
	operator const char *() { return RenderText(); } \
	operator SWKey &() { return *getKey(); } \
	operator SWKey *() { return getKey(); } \
	SWModule &operator <<(const char *inbuf) { setEntry(inbuf); return *this; } \
	SWModule &operator <<(const SWKey *sourceKey) { linkEntry(sourceKey); return *this; } \
	SWModule &operator -=(int steps) { decrement(steps); return *this; } \
	SWModule &operator +=(int steps) { increment(steps); return *this; } \
	SWModule &operator ++(int) { return *this += 1; } \
	SWModule &operator --(int) { return *this -= 1; } \
	SWModule &operator =(SW_POSITION p) { setPosition(p); return *this; }


typedef std::list < SWFilter * >FilterList;
typedef std::list < SWOptionFilter * >OptionFilterList;
typedef std::map < SWBuf, SWBuf, std::less < SWBuf > > AttributeValue;
typedef std::map < SWBuf, AttributeValue, std::less < SWBuf > > AttributeList;
typedef std::map < SWBuf, AttributeList, std::less < SWBuf > > AttributeTypeList;

#define SWTextDirection char
#define SWTextEncoding char
#define SWTextMarkup char

/**
 * The class SWModule is the base class for all modules used in Sword.
 * It provides functions to look up a text passage, to search in the module,
 * to switch on/off the state of optional things like Strong's numbers or
 * footnotes.
 *
 * SWModule has also functions to write to the data files.
 */

// TODO: should all SWModule decendents be SWCachers?  Only some really
// cache data.  But if we don't do this, then we need another mechanism to
// check if we are an SWCacher.  Maybe make SWModule extend SWObject (which
// it probably should anyway.  But then we need to add all the cheezy
// heirarchy info to all the decendent classes for our SWDYNAMIC_CAST and
// then we can see if we implement SWCacher so we know whether or not to add
// to the yet to be developed cachemgr.
// Just leave for now.  This lets us always able to call module->flush()
// to manually flush a cache, and doesn't hurt if there is no work done.

class SWDLLEXPORT SWModule : public SWCacher, public SWSearchable {

protected:

	ConfigEntMap ownConfig;
	ConfigEntMap *config;
	mutable AttributeTypeList entryAttributes;
	mutable bool procEntAttr;

	char error;
	bool skipConsecutiveLinks;

	/** the current key */
	SWKey *key;

	ListKey listKey;
	char *modname;
	char *moddesc;
	char *modtype;
	char *modlang;

	char direction;
	char markup;
	char encoding;

	/** this module's display object */
	SWDisplay *disp;

	static SWDisplay rawdisp;
	SWBuf entryBuf;

	/** filters to be executed to remove all markup (for searches) */
	FilterList *stripFilters;

	/** filters to be executed immediately upon fileread */
	FilterList *rawFilters;

	/** filters to be executed to format for display */
	FilterList *renderFilters;

	/** filters to be executed to change markup to user prefs */
	OptionFilterList *optionFilters;

	/** filters to be executed to decode text for display */
	FilterList *encodingFilters;

	int entrySize;
	mutable long entryIndex;	 // internal common storage for index

	static void prepText(SWBuf &buf);


public:

	/**
	 * Set this bool to false to terminate the search which is executed by this module (search()).
	 * This is useful for threaded applications to terminate the search from another thread.
	 */
	bool terminateSearch;

	/** SWModule c-tor
	 *
	 * @param imodname Internal name for module; see also getName()
	 * @param imoddesc Name to display to user for module; see also getDescription()
	 * @param idisp Display object to use for displaying; see also getDisplay()
	 * @param imodtype Type of module (e.g. Biblical Text, Commentary, etc.); see also getType()
	 * @param encoding Encoding of the module (e.g. UTF-8)
	 * @param dir Direction of text flow (e.g. Right to Left for Hebrew)
	 * @param markup Source Markup of the module (e.g. OSIS)
	 * @param modlang Language of the module (e.g. en)
	 */
	SWModule(const char *imodname = 0, const char *imoddesc = 0, SWDisplay * idisp = 0, const char *imodtype = 0, SWTextEncoding encoding = ENC_UNKNOWN, SWTextDirection dir = DIRECTION_LTR, SWTextMarkup markup = FMT_UNKNOWN, const char *modlang = 0);

	/** SWModule d-tor
	 */
	virtual ~SWModule();

	/** Gets and clears error status
	 *
	 * @return error status
	 */
	virtual char Error();

	/**
	 * @return  True if this module is encoded in Unicode, otherwise returns false.
	 */
	virtual bool isUnicode() const { return (encoding == (char)ENC_UTF8); }

	// These methods are useful for modules that come from a standard SWORD install (most do).
	// SWMgr will call setConfig.  The user may use getConfig and getConfigEntry (if they
	// are not comfortable with, or don't wish to use  stl maps).
	virtual void setConfig(ConfigEntMap *config);
	virtual const ConfigEntMap &getConfig() const { return *config; }
	virtual const char *getConfigEntry(const char *key) const;

	/**
	 * @return The size of the text entry for the module's current key position.
	 */
	virtual int getEntrySize() const { return entrySize; }

	/**
	 * Sets a key to this module for position to a particular record
	 *
	 * @param ikey key with which to set this module
	 * @return error status
	 */
	virtual char setKey(const SWKey *ikey);

	/**
	 * Sets a key to this module for position to a particular record
	 * @param ikey The SWKey which should be used as new key.
	 * @return Error status
	 */
	char setKey(const SWKey &ikey) { return setKey(&ikey); }
	/**
	 * @deprecated Use setKey() instead.
	 */
	char SetKey(const SWKey *ikey) { return setKey(ikey); }
	/**
	 * @deprecated Use setKey() instead.
	 */
	char SetKey(const SWKey &ikey) { return setKey(ikey); }
	/**
	 * @deprecated Use setKey() instead.
	 */
	char Key(const SWKey & ikey) { return setKey(ikey); }

	/** Gets the current module key
	 * @return the current key of this module
	 */
	virtual SWKey *getKey() const;
	/**
	 * @deprecated Use getKey() instead.
	 */
	SWKey &Key() const { return *getKey(); }

	/**
	 * Sets/gets module KeyText
	 * @deprecated Use getKeyText/setKey
	 * @param ikeytext Value which to set keytext; [0]-only get
	 * @return pointer to keytext
	 */
	virtual const char *KeyText(const char *ikeytext = 0) {
		if (ikeytext) setKey(ikeytext);
		return *getKey();
	}

	/**
	 * gets the key text for the module.
	 * do we really need this?
	 */

	virtual const char *getKeyText() const {
		return *getKey();
	}


	virtual long Index() const { return entryIndex; }
	virtual long Index(long iindex) { entryIndex = iindex; return entryIndex; }

	/** Calls this module's display object and passes itself
	 *
	 * @return error status
	 */
	virtual char Display();

	/** Gets display driver
	 *
	 * @return pointer to SWDisplay class for this module
	 */
	virtual SWDisplay *getDisplay() const;

	/** Sets display driver
	 *
	 * @param idisp pointer to SWDisplay class to assign to this module
	 */
	virtual void setDisplay(SWDisplay * idisp);

	/**
	 * @deprecated Use get/setDisplay() instead.
	 */
	SWDisplay *Disp(SWDisplay * idisp = 0) {
		if (idisp)
			setDisplay(idisp);
		return getDisplay();
	}

	/** Gets module name
	 *
	 * @return pointer to modname
	 */
	virtual char *Name() const;

	/** Sets module name
	 *
	 * @param imodname Value which to set modname; [0]-only get
	 * @return pointer to modname
	 */
	virtual char *Name(const char *imodname);

	/** Gets module description
	 *
	 * @return pointer to moddesc
	 */
	virtual char *Description() const;

	/** Sets module description
	 *
	 * @param imoddesc Value which to set moddesc; [0]-only get
	 * @return pointer to moddesc
	 */
	virtual char *Description(const char *imoddesc);

	/** Gets module type
	 *
	 * @return pointer to modtype
	 */
	virtual char *Type() const;

	/** Sets module type
	 *
	 * @param imodtype Value which to set modtype; [0]-only get
	 * @return pointer to modtype
	 */
	virtual char *Type(const char *imodtype);

	/** Sets/gets module direction
	 *
	 * @param newdir Value which to set direction; [-1]-only get
	 * @return new direction
	 */
	virtual char Direction(signed char newdir = -1);

	/** Sets/gets module encoding
	 *
	 * @param enc Value which to set encoding; [-1]-only get
	 * @return Encoding
	 */
	virtual char Encoding(signed char enc = -1);

	/** Sets/gets module markup
	 *
	 * @param markup Vvalue which to set markup; [-1]-only get
	 * @return Markup
	 */
	virtual char Markup(signed char markup = -1);

	/** Sets/gets module language
	 *
	 * @param imodlang Value which to set modlang; [0]-only get
	 * @return pointer to modlang
	 */
	virtual char *Lang(const char *imodlang = 0);


	// search interface -------------------------------------------------

	/** Searches a module for a string
	 *
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
			void *percentUserData = 0);

	// for backward compat-- deprecated
	virtual ListKey &Search(const char *istr, int searchType = 0, int flags = 0,
			SWKey * scope = 0,
			bool * justCheckIfSupported = 0,
			void (*percent) (char, void *) = &nullPercent,
			void *percentUserData = 0) {
		return search(istr, searchType, flags, scope, justCheckIfSupported, percent, percentUserData);
	}


	/** Allocates a key of specific type for module
	 * The different reimplementatiosn of SWModule (e.g. SWText) support SWKey implementations, which support special.
	 * This functions returns a SWKey object which works with the current implementation of SWModule. For example for the SWText class it returns a VerseKey object.
	 * @see VerseKey, ListKey, SWText, SWLD, SWCom
	 * @return pointer to allocated key
	 */
	virtual SWKey *CreateKey() const;

	/** This function is reimplemented by the different kinds
	 * of module objects
	 * @return the raw module text of the current entry
	 */
	virtual SWBuf &getRawEntryBuf() = 0;

	virtual const char *getRawEntry() { return getRawEntryBuf().c_str(); }

	// write interface ----------------------------
	/** Is the module writable? :)
	 * @return yes or no
	 */
	virtual bool isWritable() { return false; }

	/** Creates a new, empty module
	 * @param path path where to create the new module
	 * @return error
	 */
	static signed char createModule(const char *path);

	/** Modify the current module entry text - only if module isWritable()
	 */
	virtual void setEntry(const char *inbuf, long len= -1);

	/** Link the current module entry to another module entry - only if
	 *	module isWritable()
	 */
	virtual void linkEntry(const SWKey *sourceKey);

	/** Delete current module entry - only if module isWritable()
	 */
	virtual void deleteEntry() {}

	// end write interface ------------------------

	/** Decrements module key a number of entries
	 * @param steps Number of entries to jump backward
	 */
	virtual void decrement(int steps = 1);

	/** Increments module key a number of entries
	 * @param steps Number of entries to jump forward
	 */
	virtual void increment(int steps = 1);

	/** Positions this modules to a logical position entry
	 * @param pos position (e.g. TOP, BOTTOM)
	 */
	virtual void setPosition(SW_POSITION pos);

	/** OptionFilterBuffer a text buffer
	 * @param filters the FilterList of filters to iterate
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void filterBuffer(OptionFilterList *filters, SWBuf &buf, const SWKey *key);

	/** FilterBuffer a text buffer
	 * @param filters the FilterList of filters to iterate
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void filterBuffer(FilterList *filters, SWBuf &buf, const SWKey *key);

	/** Adds a RenderFilter to this module's renderFilters queue.
	 *	Render Filters are called when the module is asked to produce
	 *	renderable text.
	 * @param newfilter the filter to add
	 * @return *this
	 */
	virtual SWModule &AddRenderFilter(SWFilter *newfilter) {
		renderFilters->push_back(newfilter);
		return *this;
	}

	/** Retrieves a container of render filters associated with this
	 *	module.
	 * @return container of render filters
	 */
	virtual const FilterList &getRenderFilters() const {
		return *renderFilters;
	}

	/** Removes a RenderFilter from this module's renderFilters queue
	 * @param oldfilter the filter to remove
	 * @return *this
	 */
	virtual SWModule &RemoveRenderFilter(SWFilter *oldfilter) {
		renderFilters->remove(oldfilter);
		return *this;
	}

	/** Replaces a RenderFilter in this module's renderfilters queue
	 * @param oldfilter the filter to remove
	 * @param newfilter the filter to add in its place
	 * @return *this
	 */
	virtual SWModule &ReplaceRenderFilter(SWFilter *oldfilter, SWFilter *newfilter) {
		FilterList::iterator iter;
		for (iter = renderFilters->begin(); iter != renderFilters->end(); iter++) {
			if (*iter == oldfilter)
				*iter = newfilter;
		}
		return *this;
	}

	/** RenderFilter run a buf through this module's Render Filters
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void renderFilter(SWBuf &buf, const SWKey *key) {
		filterBuffer(renderFilters, buf, key);
	}

	/** Adds an EncodingFilter to this module's @see encodingFilters queue.
	 *	Encoding Filters are called immediately when the module is read
	 *	from data source, to assure we have desired internal data stream
	 *	(e.g. UTF-8 for text modules)
	 * @param newfilter the filter to add
	 * @return *this
	 */
	virtual SWModule &AddEncodingFilter(SWFilter *newfilter) {
		encodingFilters->push_back(newfilter);
		return *this;
	}

	/** Removes an EncodingFilter from this module's encodingFilters queue
	 * @param oldfilter the filter to remove
	 * @return *this
	 */
	virtual SWModule &RemoveEncodingFilter(SWFilter *oldfilter) {
		encodingFilters->remove(oldfilter);
		return *this;
	}

	/** Replaces an EncodingFilter in this module's encodingfilters queue
	 * @param oldfilter the filter to remove
	 * @param newfilter the filter to add in its place
	 * @return *this
	 */
	virtual SWModule &ReplaceEncodingFilter(SWFilter *oldfilter, SWFilter *newfilter) {
		FilterList::iterator iter;
		for (iter = encodingFilters->begin(); iter != encodingFilters->end(); iter++) {
			if (*iter == oldfilter)
				*iter = newfilter;
		}
		return *this;
	}

	/** encodingFilter run a buf through this module's Encoding Filters
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void encodingFilter(SWBuf &buf, const SWKey *key) {
		filterBuffer(encodingFilters, buf, key);
	}

	/** Adds a StripFilter to this module's stripFilters queue.
	 *	Strip filters are called when a module is asked to render
	 *	an entry without any markup (like when searching).
	 * @param newfilter the filter to add
	 * @return *this
	 */
	virtual SWModule &AddStripFilter(SWFilter *newfilter) {
		stripFilters->push_back(newfilter);
		return *this;
	}

	/** Adds a RawFilter to this module's rawFilters queue
	 * @param newfilter the filter to add
	 * @return *this
	 */
	virtual SWModule &AddRawFilter(SWFilter *newfilter) {
		rawFilters->push_back(newfilter);
		return *this;
	}

	/** StripFilter run a buf through this module's Strip Filters
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void stripFilter(SWBuf &buf, const SWKey *key) {
		filterBuffer(stripFilters, buf, key);
	}


	/** RawFilter a text buffer
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void rawFilter(SWBuf &buf, const SWKey *key) {
		filterBuffer(rawFilters, buf, key);
	}

	/** Adds an OptionFilter to this module's optionFilters queue.
	 *	Option Filters are used to turn options in the text on
	 *	or off, or so some other state (e.g. Strong's Number,
	 *	Footnotes, Cross References, etc.)
	 * @param newfilter the filter to add
	 * @return *this
	 */
	virtual SWModule &AddOptionFilter(SWOptionFilter *newfilter) {
		optionFilters->push_back(newfilter);
		return *this;
	}

	/** OptionFilter a text buffer
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void optionFilter(SWBuf &buf, const SWKey *key) {
		filterBuffer(optionFilters, buf, key);
	}

	/** Produces plain text, without markup, of the current module entry,
	 *	or supplied text
	 *
	 * @param buf buf to massage instead of current module entry;
	 *	if buf is 0, the current text will be used
	 * @param len max len to process
	 * @return result buffer
	 */
	virtual const char *StripText(const char *buf = 0, int len = -1);

	/** Produces renderable text of the current module entry or supplied text
	 *
	 * @param buf buffer to massage instead of current module entry;
	 *	if buf is 0, the current module position text will be used
	 * @param len max len to process
	 * @param render for internal use
	 * @return result buffer
	 */
	virtual const char *RenderText(const char *buf = 0, int len = -1, bool render = true);

	/** Produces plain text, without markup, of the module entry at the supplied key
	 * @param tmpKey desired module entry
	 * @return result buffer
	 */
	virtual const char *StripText(const SWKey *tmpKey);

	/** Produces renderable text of the module entry at the supplied key
	 * @param tmpKey key to use to grab text
	 * @return this module's text at specified key location massaged by Render filters
	 */
	virtual const char *RenderText(const SWKey *tmpKey);

	/** Whether or not to only hit one entry when iterating encounters
	 *	consecutive links when iterating
	 * @param val = true means only include entry once in iteration
	 */
	virtual void setSkipConsecutiveLinks(bool val) { skipConsecutiveLinks = val; }

	/** Whether or not to only hit one entry when iterating encounters
	 *	consecutive links when iterating
	 */
	virtual bool getSkipConsecutiveLinks() { return skipConsecutiveLinks; }
	
	virtual bool isLinked(const SWKey *k1, const SWKey *k2) const { return false; }
	virtual bool hasEntry(const SWKey *k) const { return false; }

	/** Entry Attributes are special data pertaining to the current entry.
	 *	To see what Entry Attributes exists for a specific entry of a module,
	 *	the example examples/cmdline/lookup.cpp is a good utility which
	 *	displays this information.  It is also useful as an example of how
	 *	to access such.
	 */
	virtual AttributeTypeList &getEntryAttributes() const { return entryAttributes; }

	/** Processing Entry Attributes can be expensive.  This method allows
	 * turning the processing off if they are not desired.  Some internal
	 * engine processing turns them off (like searching) temporarily for
	 * optimization.
	 */
	virtual void processEntryAttributes(bool val) const { procEntAttr = val; }

	/** Whether or not we're processing Entry Attributes
	 */
	virtual bool isProcessEntryAttributes() const { return procEntAttr; }


	// SWSearchable Interface Impl -----------------------------------------------
	virtual signed char createSearchFramework(
			void (*percent) (char, void *) = &nullPercent,
			void *percentUserData = 0);
	virtual void deleteSearchFramework();
	virtual bool hasSearchFramework();

	// OPERATORS -----------------------------------------------------------------
	SWMODULE_OPERATORS

};

SWORD_NAMESPACE_END
#endif
