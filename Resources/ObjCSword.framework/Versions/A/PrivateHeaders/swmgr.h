/******************************************************************************
 *
 *  swmgr.h -	definition of class SWMgr used to interact with an install
 *		base of sword modules.
 *
 * $Id: swmgr.h 3541 2017-12-03 18:40:33Z scribe $
 *
 * Copyright 1997-2014 CrossWire Bible Society (http://www.crosswire.org)
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

/** @mainpage The SWORD Project - API documentation
 * This is the API documentation for The SWORD Project.
 * It describes the structure of the SWORD library and documents the functions of the classes.
 * From time to time this documentation gives programming examples, too.
 *
 * SWORD provides a simple to use engine for working with many types of texts including Bibles,
 *	commentaries, lexicons, glossaries, daily devotionals, and others.
 *
 * Some main classes:
 *
 * SWMgr gives access to an installed library of modules (books).
 * SWModule represents an individual module
 * SWKey represents a location into a module (e.g. "John 3:16")
 *
 * An API Primer can be found at:
 *
 * http://crosswire.org/sword/develop/swordapi/apiprimer.jsp
 *
 * If you're interested in working on a client which uses SWORD, please first have a look at
 *	some of the existing ones.  They can always use help, and will also prove to be good examples
 *	if you decide to start a new project.
 *
 * Well known frontends are:
 *	-BibleTime
 *	-BPBible
 *	-Eloquent
 *	-PocketSword
 *	-The SWORD Projectfor Windows
 *	-Xiphos
 * See http://crosswire.org/applications.jsp for links to each and a more
 * complete list.
 */

#ifndef SWMGR_H
#define SWMGR_H

#include <map>
#include <list>
#include <swbuf.h>
#include <swconfig.h>

#include <defs.h>

SWORD_NAMESPACE_START

class SWModule;
class SWFilter;
class SWOptionFilter;
class SWFilterMgr;
class SWBuf;
class SWKey;

typedef std::map < SWBuf, SWModule *, std::less < SWBuf > >ModMap;
typedef std::map < SWBuf, SWFilter * >FilterMap;
typedef std::map < SWBuf, SWOptionFilter * >OptionFilterMap;
typedef std::list < SWBuf >StringList;
typedef std::list < SWFilter* >FilterList;
typedef std::list < SWOptionFilter* >OptionFilterList;

class FileDesc;
class SWOptionFilter;

/** SWMgr exposes an installed module set
 *
 * SWMgr exposes an installed module set and can be asked to configure the desired
 *	markup and options which modules will produce.
 *
 * @version $Id: swmgr.h 3541 2017-12-03 18:40:33Z scribe $
 */
class SWDLLEXPORT SWMgr {
private:
	bool mgrModeMultiMod;
	bool augmentHome;
	void commonInit(SWConfig *iconfig, SWConfig *isysconfig, bool autoload, SWFilterMgr *filterMgr, bool multiMod = false);

protected:
	SWFilterMgr *filterMgr;		//made protected because because BibleTime needs it
	SWConfig *myconfig;		//made protected because because BibleTime needs it
	SWConfig *mysysconfig;
	SWConfig *homeConfig;
	/**
	 * Deprecated. Use createAllModules instead
	 */
	SWDEPRECATED void CreateMods(bool multiMod = false) { createAllModules(multiMod); };
	SWDEPRECATED void DeleteMods() { deleteAllModules(); }
	char configType;		// 0 = file; 1 = directory
	OptionFilterMap optionFilters;
	FilterMap cipherFilters;
	SWFilter *gbfplain;
	SWFilter *thmlplain;
	SWFilter *osisplain;
	SWFilter *teiplain;
	SWOptionFilter *transliterator;
	FilterList cleanupFilters;
	FilterMap extraFilters;
	StringList options;
	/**
	 * method to create all modules from configuration.
	 *
	 * Override to add any special processing before or after
	 * calling SWMgr::createAllModules
	 *
	 * e.g., augmenting a localConfig.conf to SWMgr::config
	 * that might store CipheyKey or Font preferences per module
	 * before actual construction of modules
	 *
	 */
	virtual void createAllModules(bool multiMod = false);
	/**
	 * called to delete all contructed modules.  Undoes createAllModules
	 * override to clean anything up before or after all modules are
	 * deleted
	 */
	virtual void deleteAllModules();

	/**
	 * called to create exactly one module from a config entry
	 * override to do any extra work before or after each module
	 * is created
	 */
	virtual SWModule *createModule(const char *name, const char *driver, ConfigEntMap &section);

	/**
	 * call by every constructor to initialize SWMgr object
	 * override to include any addition common initialization
	 */
	virtual void init();


	/**
	 * Deprecated.  Use addGlobalOptionFilters instead.
	 */
	SWDEPRECATED virtual void AddGlobalOptions(SWModule *module, ConfigEntMap &section, ConfigEntMap::iterator start, ConfigEntMap::iterator end) { addGlobalOptionFilters(module, section); }
	/**
	 * Adds appropriate global option filters to a module.  Override to add any special
	 *	global option filters. Global option filters typically update SourceType markup
	 *	to turn on and off specific features of a text when a user has optionally chosen
	 *	to show or hide that feature, e.g. Strongs, Footnotes, Headings, etc.
	 *	Global options can also have more than On and Off values, but these are the most
	 *	common.
	 *	A set of all global options included from an entire library of installed modules
	 *	can be obtained from getGlobalOptions and presented to the user.  Values to
	 *	which each global option may be set can be obtain from getGlobalOptionValues,
	 *	and similar.  See that family of methods for more information.
	 * See the module.conf GlobalOptionFilter= entries.
	 * @param module module to which to add encoding filters
	 * @param section configuration information for module
	 */
	virtual void addGlobalOptionFilters(SWModule *module, ConfigEntMap &section);

	/**
	 * Deprecated.  Use addLocalOptionFilters instead.
	 */
	SWDEPRECATED virtual void AddLocalOptions(SWModule *module, ConfigEntMap &section, ConfigEntMap::iterator start, ConfigEntMap::iterator end) { addLocalOptionFilters(module, section); }
	/**
	 * Adds appropriate local option filters to a module.  Override to add any special
	 *	local option filters.  Local options are similar to global options in that
	 *	they may be toggled on or off or set to some value from a range of choices
	 *	but local option
	 * See the module.conf LocalOptionFilter= entries.
	 * @param module module to which to add encoding filters
	 * @param section configuration information for module
	 */
	virtual void addLocalOptionFilters(SWModule *module, ConfigEntMap &section);

	/**
	 * Deprecated.  Use addEncodingFilters instead
	 */
	SWDEPRECATED virtual void AddEncodingFilters(SWModule *module, ConfigEntMap &section) { addEncodingFilters(module, section); }
	/**
	 * Adds appropriate encoding filters to a module.  Override to add any special
	 *	encoding filters.
	 * See the module.conf Encoding= entry.
	 * @param module module to which to add encoding filters
	 * @param section configuration information for module
	 */
	virtual void addEncodingFilters(SWModule *module, ConfigEntMap &section);

	/**
	 * Deprecated.  Use addRenderFilters instead.
	 */
	SWDEPRECATED virtual void AddRenderFilters(SWModule *module, ConfigEntMap &section) { addRenderFilters(module, section); }
	/**
	 * Add appropriate render filters to a module.  Override to add any special
	 *	render filters. Render filters are used for preparing a text for
	 *	display and typically convert markup from SourceType
	 *	to desired display markup.
	 * See the module.conf SourceType= entry.
	 * @param module module to which to add render filters
	 * @param section configuration information for module
	 */
	virtual void addRenderFilters(SWModule *module, ConfigEntMap &section);

	/**
	 * Deprecated.  Use addStripFilters instead.
	 */
	SWDEPRECATED virtual void AddStripFilters(SWModule *module, ConfigEntMap &section) { addStripFilters(module, section); }
	/**
	 * Adds appropriate strip filters to a module.  Override to add any special
	 *	strip filters. Strip filters are used for preparing text for searching
	 *	and typically strip out all markup and leave only searchable words
	 * See the module.conf SourceType= entry.
	 * @param module module to which to add strip filters
	 * @param section configuration information for module
	 */
	virtual void addStripFilters(SWModule *module, ConfigEntMap &section);

	/**
	 * Deprecated.  Use addLocalStripFilters instead.
	 */
	SWDEPRECATED virtual void AddStripFilters(SWModule *module, ConfigEntMap &section, ConfigEntMap::iterator start, ConfigEntMap::iterator end) { addLocalStripFilters(module, section); }
	/**
	 * Adds manually specified strip filters specified in module configuration
	 * as LocalStripFilters.  These might take care of special cases of preparation
	 * for searching, e.g., removing ()[] and underdot symbols from manuscript modules
	 * @param module module to which to add local strip filters
	 * @param section configuration information for module
	 */
	virtual void addLocalStripFilters(SWModule *module, ConfigEntMap &section);

	/**
	 * Deprecated.  Use addRawFilters instead.
	 */
	SWDEPRECATED virtual void AddRawFilters(SWModule *module, ConfigEntMap &section) { addRawFilters(module, section); }
	/**
	 * Add appropriate raw filters to a module.  Override to add any special
	 *	raw filters.  Raw filters are used to manipulate a buffer
	 *	immediately after it has been read from storage.  For example,
	 *	any decryption that might need to be done.
	 * See the module.conf CipherKey= entry.
	 * @param module module to which to add raw filters
	 * @param section configuration information for module
	 */
	virtual void addRawFilters(SWModule *module, ConfigEntMap &section);


	// still to be normalized below ...
	//
	StringList augPaths;
	virtual char AddModToConfig(FileDesc *conffd, const char *fname);
	virtual void loadConfigDir(const char *ipath);

public:

	// constants which represent module types used in SWModule::getType
	static const char *MODTYPE_BIBLES;
	static const char *MODTYPE_COMMENTARIES;
	static const char *MODTYPE_LEXDICTS;
	static const char *MODTYPE_GENBOOKS;
	static const char *MODTYPE_DAILYDEVOS;


	static bool isICU;
	static const char *globalConfPath;

	/**
	 * Deprecated.  Used FileMgr::getSystemFileMgr()->getHomeDir() instead.
	 */
	SWDEPRECATED static SWBuf getHomeDir();

	/**
	 * Perform all the logic to discover a SWORD configuration and libraries on a system
	 */
	static void findConfig(char *configType, char **prefixPath, char **configPath, StringList *augPaths = 0, SWConfig **providedSysConf = 0);

	/**
	 * The configuration of a loaded library of SWORD modules
	 * e.g., from /usr/share/sword/mods.d/
	 * 	augmented with ~/.sword/mods.d/
	 * 
	 * This represents all discovered modules and their configuration
	 * compiled into a single SWConfig object with each [section]
	 * representing each module. e.g. [KJV]
	 */
	SWConfig *config;

	/**
	 * The configuration file for SWORD
	 * e.g., /etc/sword.conf
	 */
	SWConfig *sysConfig;

	/** The path to main module set and locales
	 */
	char *prefixPath;

	/** path to main module set configuration 
	 */
	char *configPath;


	/**
	 * Deprecated.  Use getModules instead.
	 */
	ModMap Modules;
	/** The map of available modules.
	 *	This map exposes the installed modules.
	 *
	 *	Here's an example how to iterate over all
	 *	the installed modules and check the module name
	 *	and type of each module and do something special
	 *	if the module type is a Bible.
	 *
	 * @code
	 *
	 * for (ModMap::iterator it = getModules().begin(); it != getModules().end(); ++it) {
	 *
	 * 	SWBuf modName = it->first;
	 * 	SWModule *mod = it->second;
	 *
	 * 	SWBuf modType = mod->getType();
	 *
	 * 	if (modType == SWMgr::MODTYPE_BIBLES) {
	 * 		// do something with mod
	 * 	}
	 * }
	 * @endcode
	 */
	ModMap &getModules();
	const ModMap &getModules() const { return const_cast<SWMgr *>(this)->getModules(); }

	/** Gets a specific module by name.  e.g. SWModule *kjv = myManager.getModule("KJV");
	 * @param modName the name of the module to retrieve
	 * @return the module, if found, otherwise 0
	 */
	SWModule *getModule(const char *modName) { ModMap::iterator it = getModules().find(modName); return ((it != getModules().end()) ? it->second : 0); }
	const SWModule *getModule(const char *modName) const { ModMap::const_iterator it = getModules().find(modName); return ((it != getModules().end()) ? it->second : 0); }


	/** Constructs an instance of SWMgr
	 *
	 * @param iconfig manually supply a configuration.  If not supplied, SWMgr will look on the system
	 *	using a complex hierarchical search.  See README for detailed specifics.
	 * @param isysconfig manually supply a an isysconfig (e.g. /etc/sword.conf)
	 * @param autoload whether or not to immediately load modules on construction of this SWMgr.
	 *	If you reimplemented SWMgr you can set this to false and call SWMgr::load() after you have
	 *	completed the contruction and setup of your SWMgr subclass.
	 * @param filterMgr an SWFilterMgr subclass to use to manager filters on modules
	 *	SWMgr TAKES OWNERSHIP FOR DELETING THIS OBJECT
	 *	For example, this will create an SWMgr and cause its modules to produce HTMLHREF formatted output
	 *	when asked for renderable text:
	 *
	 *	SWMgr *myMgr = new SWMgr(0, 0, true, new MarkupFilterMgr(FMT_HTMLHREF));
	 */
	SWMgr(SWConfig *iconfig = 0, SWConfig *isysconfig = 0, bool autoload = true, SWFilterMgr *filterMgr = 0, bool multiMod = false);

	/**
	 */
	SWMgr(SWFilterMgr *filterMgr, bool multiMod = false);

	/**
	 * @param iConfigPath provide a custom path to use for module set location, instead of
	 *	searching the system for it.
	 */
	SWMgr(const char *iConfigPath, bool autoload = true, SWFilterMgr *filterMgr = 0, bool multiMod = false, bool augmentHome = true);

	/** The destructor of SWMgr.
	 * This function cleans up the modules and deletes the created object.
	 * Destroying the SWMgr causes all retrieved SWModule object to be invalid, so
	 *	be sure to destroy only when retrieved objects are no longer needed.
	 */
	virtual ~SWMgr();

	/**
	 * Adds books from a new path to the library
	 * @param path the path in which to search for books
	 * @param multiMod whether or not to keep multiple copies of the same book if found in different paths
	 *		default - false, uses last found version of the book
	 */
	virtual void augmentModules(const char *path, bool multiMod = false);

	void deleteModule(const char *);

	/** Looks for any newly installed module.conf file in the path provided,
	 *	displays the copyright information to the user, and then copies the
	 *	module.conf to the main module set's mods.d directory
	 * @param dir where to search for new modules
	 */
	virtual void InstallScan(const char *dir);

	/**
	 * Deprecated.  Use load
	 */
	SWDEPRECATED virtual signed char Load() { return load(); }
	/** Loads installed library of SWORD modules.
	 * Should only be manually called if SWMgr was constructed
	 *	without autoload; otherwise, this will be called on SWMgr construction
	 * Reimplement this function to supply special functionality when modules are
	 * initially loaded. This includes
	 * discovery of config path with SWMgr::fileconfig,
	 * loading of composite SWMgr::config,
	 * and construction of all modules from config using SWMgr::createAllModules
	 */
	virtual signed char load();

	/** Change the values of global options (e.g. Footnotes, Strong's Number, etc.)
	 * @param option The name of the option, for which you want to change the
	 * value. Well known and often used values are "Footnotes" or "Strong's Numbers"
	 * @param value new value. Common values are "On" and "Off"
	 */
	virtual void setGlobalOption(const char *option, const char *value);

	/** Get the current value of the given option
	 * @param option the name of the option, who's value is desired
	 * @return the value of the given option
	 */
	virtual const char *getGlobalOption(const char *option);

	/** Gets a brief description for the given option
	 * @param option the name of the option, who's tip is desired
	 * @return description text
	 * @see setGlobalOption, getGlobalOption, getGlobalOptions
	 */
	virtual const char *getGlobalOptionTip(const char *option);

	/** Gets a list of all available option names
	 * @return list of option names
	 */
	virtual StringList getGlobalOptions();

	/** Gets a list of legal values to which a specific option 
	 *	may be set
	 * @param option the name of the option, who's legal values are desired
	 * @return a list of legal values for the given option
	 */
	virtual StringList getGlobalOptionValues(const char *option);

	/** Filters a buffer thru a named filter
	 * @param filterName
	 * @param text buffer to filter
	 * @param key context key if filter needs this for processing
	 * @param module context module if filter needs this for processing
	 * @return error status
	 */
	virtual char filterText(const char *filterName, SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);

	/**
	 * Sets the cipher key for the given module. This function updates the key
	 * at runtime, but it does not write to the config file.
	 * This method is NOT the recommended means for applying a CipherKey
	 * to a module.
	 *
	 * Typically CipherKey entries and other per module user configuration
	 * settings are all saved in a separate localConfig.conf that is updated
	 * by a UI or other client of the library. e.g.,
	 *
	 *
	 * [KJV]
	 * Font=Arial
	 * LocalOptionFilter=SomeSpecialFilterMyUIAppliesToTheKJV
	 *
	 * [ISV]
	 * CipherKey=xyzzy
	 *
	 * [StrongsGreek]
	 * SomeUISetting=false
	 *
	 *
	 * Then these extra config settings in this separate file are applied
	 * just before module creation by overriding SWMgr::createAllModules and
	 * augmenting SWMgr::config with code like this:
	 *
	 * @code
	 * void createAllModules(bool multiMod) {
	 *
	 * 	// after SWMgr::config is loaded
	 *	// see if we have our own local settings
	 * 	SWBuf myExtraConf = "~/.myapp/localConf.conf";
	 * 	bool exists = FileMgr::existsFile(extraConf);
	 * 	if (exists) {
	 * 		SWConfig addConfig(extraConf);
	 * 		this->config->augment(addConfig);
	 * 	}
	 *
	 * 	// now that we've augmented SWMgr::config with our own custom
	 * 	// settings, proceed on with creating modules
	 *
	 * 	SWMgr::createAllModules(multiMod);
	 *
	 * }
	 * @endcode
	 *
	 * The above convention is preferred to using this setCipherKey method
	 *
	 * @param modName For this module we change the unlockKey
	 * @param key This is the new unlock key we use for the module.
	 */
	virtual signed char setCipherKey(const char *modName, const char *key);
};

SWORD_NAMESPACE_END
#endif
