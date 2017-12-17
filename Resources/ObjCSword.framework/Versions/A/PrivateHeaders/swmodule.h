/******************************************************************************
 *
 *  swmodule.h -	code for base class 'module'.  Module is the basis for
 *		  	all types of modules (e.g. texts, commentaries, maps,
 *		  	lexicons, etc.)
 *
 * $Id: swmodule.h 3541 2017-12-03 18:40:33Z scribe $
 *
 * Copyright 1997-2013 CrossWire Bible Society (http://www.crosswire.org)
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
#ifndef	_WIN32_WCE
#include <iostream>
#endif

#include <list>

#include <defs.h>

SWORD_NAMESPACE_START

class SWOptionFilter;
class SWFilter;

#define SEARCHFLAG_MATCHWHOLEENTRY 4096

#define SWMODULE_OPERATORS \
	operator SWBuf() { return renderText(); } \
	operator SWKey &() { return *getKey(); } \
	operator SWKey *() { return getKey(); } \
	SWModule &operator <<(const char *inbuf) { setEntry(inbuf); return *this; } \
	SWModule &operator <<(const SWKey *sourceKey) { linkEntry(sourceKey); return *this; } \
	SWModule &operator -=(int steps) { decrement(steps); return *this; } \
	SWModule &operator +=(int steps) { increment(steps); return *this; } \
	SWModule &operator ++(int) { return *this += 1; } \
	SWModule &operator --(int) { return *this -= 1; } \
	SWModule &operator =(SW_POSITION p) { setPosition(p); return *this; } \
	SWDEPRECATED operator const char *() { static SWBuf unsafeTmp = renderText(); return unsafeTmp.c_str(); }


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

class StdOutDisplay : public SWDisplay {
     char display(SWModule &imodule)
     {
     #ifndef	_WIN32_WCE
          std::cout << imodule.renderText();
     #endif
          return 0;
     }
};

protected:

	ConfigEntMap ownConfig;
	ConfigEntMap *config;
	mutable AttributeTypeList entryAttributes;
	mutable bool procEntAttr;

	mutable char error;
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

	static StdOutDisplay rawdisp;
	mutable SWBuf entryBuf;

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

	mutable int entrySize;
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
	virtual char popError();
	SWDEPRECATED virtual char Error() { return popError(); }

	/**
	 * @return  True if this module is encoded in Unicode, otherwise returns false.
	 */
	virtual bool isUnicode() const { return (encoding == (char)ENC_UTF8 || encoding == (char)ENC_SCSU); }

	// These methods are useful for modules that come from a standard SWORD install (most do).
	// SWMgr will call setConfig.  The user may use getConfig and getConfigEntry (if they
	// are not comfortable with, or don't wish to use  stl maps).
	virtual void setConfig(ConfigEntMap *config);
	virtual const ConfigEntMap &getConfig() const { return *config; }

	/**
	 * Gets a configuration property about a module.  These entries are primarily
	 * pulled from the module's .conf file, but also includes some virtual entries
	 * such as:
	 * 	PrefixPath - the absolute filesystem path to the sword module repository
	 *	location where this module is located.
	 *	AbsoluteDataPath - the full path to the root folder where the module
	 *	data is stored.
	 */
	virtual const char *getConfigEntry(const char *key) const;

	/**
	 * Returns bibliographic data for a module in the requested format
	 *
	 * @param bibFormat format of the bibliographic data
	 * @return bibliographic data in the requested format as a string (BibTeX by default)
	 */
	virtual SWBuf getBibliography(unsigned char bibFormat = BIB_BIBTEX) const;

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
	SWDEPRECATED char SetKey(const SWKey *ikey) { return setKey(ikey); }
	/**
	 * @deprecated Use setKey() instead.
	 */
	SWDEPRECATED char SetKey(const SWKey &ikey) { return setKey(ikey); }
	/**
	 * @deprecated Use setKey() instead.
	 */
	SWDEPRECATED char Key(const SWKey & ikey) { return setKey(ikey); }

	/** Gets the current module key
	 * @return the current key of this module
	 */
	virtual SWKey *getKey() const;
	/**
	 * @deprecated Use getKey() instead.
	 */
	SWDEPRECATED SWKey &Key() const { return *getKey(); }

	/**
	 * Sets/gets module KeyText
	 * @deprecated Use getKeyText/setKey
	 * @param ikeytext Value which to set keytext; [0]-only get
	 * @return pointer to keytext
	 */
	SWDEPRECATED const char *KeyText(const char *ikeytext = 0) { if (ikeytext) setKey(ikeytext); return *getKey(); }

	/**
	 * gets the key text for the module.
	 * do we really need this?
	 */

	virtual const char *getKeyText() const {
		return *getKey();
	}


	virtual long getIndex() const { return entryIndex; }
	virtual void setIndex(long iindex) { entryIndex = iindex; }
	// deprecated, use getIndex()
	SWDEPRECATED long Index() const { return getIndex(); }
	// deprecated, use setIndex(...)
	SWDEPRECATED long Index(long iindex) { setIndex(iindex); return getIndex(); }

	/** Calls this module's display object and passes itself
	 *
	 * @return error status
	 */
	virtual char display();
	SWDEPRECATED char Display() { return display(); }

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
	SWDEPRECATED SWDisplay *Disp(SWDisplay * idisp = 0) { if (idisp)	setDisplay(idisp); return getDisplay();	}

	/** Gets module name
	 *
	 * @return pointer to modname
	 */
	const char *getName() const;
	SWDEPRECATED const char *Name() const { return getName(); }

	/** Sets module name
	 *
	 * @param imodname Value which to set modname; [0]-only get
	 * @return pointer to modname
	 */
	SWDEPRECATED const char *Name(const char *imodname) { stdstr(&modname, imodname); return getName(); }

	/** Gets module description
	 *
	 * @return pointer to moddesc
	 */
	const char *getDescription() const;
	SWDEPRECATED const char *Description() const { return getDescription(); }

	/** Sets module description
	 *
	 * @param imoddesc Value which to set moddesc; [0]-only get
	 * @return pointer to moddesc
	 */
	SWDEPRECATED const char *Description(const char *imoddesc) { stdstr(&moddesc, imoddesc); return getDescription(); }

	/** Gets module type
	 *
	 * @return pointer to modtype
	 */
	const char *getType() const;
	SWDEPRECATED const char *Type() const { return getType(); }

	/** Sets module type
	 *
	 * @param imodtype Value which to set modtype; [0]-only get
	 * @return pointer to modtype
	 */
	SWDEPRECATED const char *Type(const char *imodtype) { setType(imodtype); return getType(); }
	void setType(const char *imodtype) { stdstr(&modtype, imodtype); }

	/** Sets/gets module direction
	 *
	 * @return new direction
	 */
	virtual char getDirection() const;
	SWDEPRECATED char Direction(signed char newdir = -1) { char retVal = getDirection(); if (newdir != -1) return direction = newdir; return retVal; }

	/** Gets module encoding
	 *
	 * @return Encoding
	 */
	char getEncoding() const { return encoding; }
	SWDEPRECATED char Encoding(signed char enc = -1) { char retVal = getEncoding(); if (enc != -1) encoding = enc; return retVal; }

	/** Gets module markup
	 *
	 * @return Markup
	 */
	char getMarkup() const { return markup; }
	SWDEPRECATED char Markup(signed char imarkup = -1) { char retVal = getMarkup(); if (imarkup != -1) markup = imarkup; return retVal; }

	/** Gets module language
	 *
	 * @return pointer to modlang
	 */
	const char *getLanguage() const { return modlang; }
	SWDEPRECATED const char *Lang(char *imodlang = 0) { if (imodlang != 0) stdstr(&modlang, imodlang); return getLanguage(); }


	// search interface -------------------------------------------------

	/** Searches a module for a string
	 *
	 * @param istr string for which to search
	 * @param searchType type of search to perform
	 *			>=0 - regex; (for backward compat, if > 0 then used as additional REGEX FLAGS)
	 *			-1  - phrase
	 *			-2  - multiword
	 *			-3  - entryAttrib (eg. Word//Lemma./G1234/)	 (Lemma with dot means check components (Lemma.[1-9]) also)
	 *			-4  - Lucene
	 *			-5  - multilemma window; set 'flags' param to window size (NOT DONE)
	 * @param flags options flags for search
	 * @param scope Key containing the scope. VerseKey or ListKey are useful here.
	 * @param justCheckIfSupported If set, don't search but instead set this variable to true/false if the requested search is supported,
	 * @param percent Callback function to get the current search status in %.
	 * @param percentUserData Anything that you might want to send to the precent callback function.
	 *
	 * @return ListKey set to verses that contain istr
	 */
	virtual ListKey &search(const char *istr, int searchType = 0, int flags = 0,
			SWKey *scope = 0,
			bool *justCheckIfSupported = 0,
			void (*percent) (char, void *) = &nullPercent,
			void *percentUserData = 0);

	// for backward compat-- deprecated
	SWDEPRECATED ListKey &Search(const char *istr, int searchType = 0, int flags = 0, SWKey * scope = 0, bool * justCheckIfSupported = 0, void (*percent) (char, void *) = &nullPercent, void *percentUserData = 0) {	return search(istr, searchType, flags, scope, justCheckIfSupported, percent, percentUserData);	}


	/** Allocates a key of specific type for module
	 * The different reimplementations of SWModule (e.g. SWText) support SWKey implementations,
	 * which support special.  This functions returns a SWKey object which works with the current
	 * implementation of SWModule. For example for the SWText class it returns a VerseKey object.
	 * @see VerseKey, ListKey, SWText, SWLD, SWCom
	 * @return pointer to allocated key. Caller is responsible for deleting the object
	 */
	virtual SWKey *createKey() const;
	SWDEPRECATED SWKey *CreateKey() const { return createKey(); }

	/** This function is reimplemented by the different kinds
	 * of module objects
	 * @return the raw module text of the current entry
	 */
	virtual SWBuf &getRawEntryBuf() const = 0;

	const char *getRawEntry() const { return getRawEntryBuf().c_str(); }

	// write interface ----------------------------
	/** Is the module writable? :)
	 * @return yes or no
	 */
	virtual bool isWritable() const { return false; }

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
	virtual void filterBuffer(OptionFilterList *filters, SWBuf &buf, const SWKey *key) const;

	/** FilterBuffer a text buffer
	 * @param filters the FilterList of filters to iterate
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void filterBuffer(FilterList *filters, SWBuf &buf, const SWKey *key) const;

	/** Adds a RenderFilter to this module's renderFilters queue.
	 *	Render Filters are called when the module is asked to produce
	 *	renderable text.
	 * @param newFilter the filter to add
	 * @return *this
	 */
	virtual SWModule &addRenderFilter(SWFilter *newFilter) {
		renderFilters->push_back(newFilter);
		return *this;
	}
	SWDEPRECATED SWModule &AddRenderFilter(SWFilter *newFilter) { return addRenderFilter(newFilter); }

	/** Retrieves a container of render filters associated with this
	 *	module.
	 * @return container of render filters
	 */
	virtual const FilterList &getRenderFilters() const {
		return *renderFilters;
	}

	/** Removes a RenderFilter from this module's renderFilters queue
	 * @param oldFilter the filter to remove
	 * @return *this
	 */
	virtual SWModule &removeRenderFilter(SWFilter *oldFilter) {
		renderFilters->remove(oldFilter);
		return *this;
	}
	SWDEPRECATED SWModule &RemoveRenderFilter(SWFilter *oldFilter) {	return removeRenderFilter(oldFilter); }

	/** Replaces a RenderFilter in this module's renderfilters queue
	 * @param oldFilter the filter to remove
	 * @param newFilter the filter to add in its place
	 * @return *this
	 */
	virtual SWModule &replaceRenderFilter(SWFilter *oldFilter, SWFilter *newFilter) {
		FilterList::iterator iter;
		for (iter = renderFilters->begin(); iter != renderFilters->end(); iter++) {
			if (*iter == oldFilter)
				*iter = newFilter;
		}
		return *this;
	}
	SWDEPRECATED SWModule &ReplaceRenderFilter(SWFilter *oldFilter, SWFilter *newFilter) { return replaceRenderFilter(oldFilter, newFilter); }

	/** RenderFilter run a buf through this module's Render Filters
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void renderFilter(SWBuf &buf, const SWKey *key) const {
		filterBuffer(renderFilters, buf, key);
	}

	/** Adds an EncodingFilter to this module's @see encodingFilters queue.
	 *	Encoding Filters are called immediately when the module is read
	 *	from data source, to assure we have desired internal data stream
	 *	(e.g. UTF-8 for text modules)
	 * @param newFilter the filter to add
	 * @return *this
	 */
	virtual SWModule &addEncodingFilter(SWFilter *newFilter) {
		encodingFilters->push_back(newFilter);
		return *this;
	}
	SWDEPRECATED SWModule &AddEncodingFilter(SWFilter *newFilter) { return addEncodingFilter(newFilter); }

	/** Removes an EncodingFilter from this module's encodingFilters queue
	 * @param oldFilter the filter to remove
	 * @return *this
	 */
	virtual SWModule &removeEncodingFilter(SWFilter *oldFilter) {
		encodingFilters->remove(oldFilter);
		return *this;
	}
	SWDEPRECATED SWModule &RemoveEncodingFilter(SWFilter *oldFilter) { return removeEncodingFilter(oldFilter); }

	/** Replaces an EncodingFilter in this module's encodingfilters queue
	 * @param oldFilter the filter to remove
	 * @param newFilter the filter to add in its place
	 * @return *this
	 */
	virtual SWModule &replaceEncodingFilter(SWFilter *oldFilter, SWFilter *newFilter) {
		FilterList::iterator iter;
		for (iter = encodingFilters->begin(); iter != encodingFilters->end(); iter++) {
			if (*iter == oldFilter)
				*iter = newFilter;
		}
		return *this;
	}
	SWDEPRECATED SWModule &ReplaceEncodingFilter(SWFilter *oldFilter, SWFilter *newFilter) { return replaceEncodingFilter(oldFilter, newFilter); }

	/** encodingFilter run a buf through this module's Encoding Filters
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void encodingFilter(SWBuf &buf, const SWKey *key) const {
		filterBuffer(encodingFilters, buf, key);
	}

	/** Adds a StripFilter to this module's stripFilters queue.
	 *	Strip filters are called when a module is asked to render
	 *	an entry without any markup (like when searching).
	 * @param newFilter the filter to add
	 * @return *this
	 */
	virtual SWModule &addStripFilter(SWFilter *newFilter) {
		stripFilters->push_back(newFilter);
		return *this;
	}
	SWDEPRECATED SWModule &AddStripFilter(SWFilter *newFilter) { return addStripFilter(newFilter);	}

	/** Adds a RawFilter to this module's rawFilters queue
	 * @param newFilter the filter to add
	 * @return *this
	 */
	virtual SWModule &addRawFilter(SWFilter *newFilter) {
		rawFilters->push_back(newFilter);
		return *this;
	}
	SWDEPRECATED SWModule &AddRawFilter(SWFilter *newFilter) { return addRawFilter(newFilter); }

	/** StripFilter run a buf through this module's Strip Filters
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void stripFilter(SWBuf &buf, const SWKey *key) const {
		filterBuffer(stripFilters, buf, key);
	}


	/** RawFilter a text buffer
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void rawFilter(SWBuf &buf, const SWKey *key) const {
		filterBuffer(rawFilters, buf, key);
	}

	/** Adds an OptionFilter to this module's optionFilters queue.
	 *	Option Filters are used to turn options in the text on
	 *	or off, or so some other state (e.g. Strong's Number,
	 *	Footnotes, Cross References, etc.)
	 * @param newFilter the filter to add
	 * @return *this
	 */
	virtual SWModule &addOptionFilter(SWOptionFilter *newFilter) {
		optionFilters->push_back(newFilter);
		return *this;
	}
	SWDEPRECATED SWModule &AddOptionFilter(SWOptionFilter *newFilter) { return addOptionFilter(newFilter); }

	/** OptionFilter a text buffer
	 * @param buf the buffer to filter
	 * @param key key location from where this buffer was extracted
	 */
	virtual void optionFilter(SWBuf &buf, const SWKey *key) const {
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
	virtual const char *stripText(const char *buf = 0, int len = -1);
	SWDEPRECATED const char *StripText(const char *buf = 0, int len = -1) { return stripText(buf, len); }

	/** Produces renderable text of the current module entry or supplied text
	 *
	 * @param buf buffer to massage instead of current module entry;
	 *	if buf is 0, the current module position text will be used
	 * @param len max len to process
	 * @param render for internal use
	 * @return result buffer
	 */
	SWBuf renderText(const char *buf, int len = -1, bool render = true) const;
    SWBuf renderText();
	SWDEPRECATED const char *RenderText(const char *buf = 0, int len = -1, bool render = true) { return renderText(buf, len, render); }

	/** Produces any header data which might be useful which is associated with the
	 *	processing done with this filter.  A typical example is a suggested
	 *	CSS style block for classed containers.
	 */
	virtual const char *getRenderHeader() const;

	/** Produces plain text, without markup, of the module entry at the supplied key
	 * @param tmpKey desired module entry
	 * @return result buffer
	 */
	virtual const char *stripText(const SWKey *tmpKey);

	/** Produces renderable text of the module entry at the supplied key
	 * @param tmpKey key to use to grab text
	 * @return this module's text at specified key location massaged by Render filters
	 */
	SWBuf renderText(const SWKey *tmpKey);

	/** Whether or not to only hit one entry when iterating encounters
	 *	consecutive links when iterating
	 * @param val = true means only include entry once in iteration
	 */
	virtual void setSkipConsecutiveLinks(bool val) { skipConsecutiveLinks = val; }

	/** Whether or not to only hit one entry when iterating encounters
	 *	consecutive links when iterating
	 */
	virtual bool isSkipConsecutiveLinks() { return skipConsecutiveLinks; }
	SWDEPRECATED bool getSkipConsecutiveLinks() { return isSkipConsecutiveLinks(); }
	
	virtual bool isLinked(const SWKey *, const SWKey *) const { return false; }
	virtual bool hasEntry(const SWKey *) const { return false; }

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
	virtual void setProcessEntryAttributes(bool val) const { procEntAttr = val; }
	SWDEPRECATED void processEntryAttributes(bool val) const { setProcessEntryAttributes(val); }

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
