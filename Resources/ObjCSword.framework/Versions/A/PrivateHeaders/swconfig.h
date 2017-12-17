/******************************************************************************
 *
 *  swconfig.h -	definition of Class SWConfig used for saving and
 *			retrieval of configuration information
 *
 * $Id: swconfig.h 3515 2017-11-01 11:38:09Z scribe $
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

#ifndef SWCONFIG_H
#define SWCONFIG_H

#include <map>

#include <defs.h>
#include <multimapwdef.h>
#include <swbuf.h>

SWORD_NAMESPACE_START

typedef multimapwithdefault < SWBuf, SWBuf, std::less < SWBuf > >ConfigEntMap;
typedef std::map < SWBuf, ConfigEntMap, std::less < SWBuf > >SectionMap;

/** The class to read and save settings using a file on disk.
*
*/
class SWDLLEXPORT SWConfig {
public:
	/** Map of available sections
	* The map of available sections.
	*/

	/** Constructor of SWConfig
	 * @param fileName The storage path for this config.
	 */
	SWConfig(const char *fileName);
	SWConfig();
	virtual ~SWConfig();

	/** Get the section map for the config
	 */
	virtual SectionMap &getSections();
	const SectionMap &getSections() const { return const_cast<SWConfig *>(this)->getSections(); }

	/** Load the content from datastore
	 */
	virtual void load();

	/** Save the content of this config object to the datastore
	 */
	virtual void save() const;

	/** Merges into this config the values from addFrom
	 * @param addFrom The config which values should be merged to this config object. Already existing values will be overwritten.
	 */
	virtual void augment(SWConfig &addFrom);

	/** Get a specified section from config, creating the section if needed
	 * There is no const version of this method because it returns a ConfigEntMap reference, creating the requested section if it doesn't exist.
	 * @param section section name to retrieve
	 */
	ConfigEntMap &getSection(const char *section) { return getSections()[section]; }


	/** This operator provides a conventient syntax to get and store config values
	 *
	 * config[section][key] = value;
	 * value = config[section][key];
	 *
	 * The following will work:\n
	 *
	 * @code
	 * SWConfig config("/home/user/.settings");
	 * config["Colors"]["Background"] = "red";
	 * @endcode
	 */
	ConfigEntMap &operator [](const char *section) { return getSection(section); }

	/** shorthand operator for augment
	 */
	SWConfig &operator +=(SWConfig &addFrom) { augment(addFrom); return *this; }

	/** get a value from a [section] key=value
	 * @param section  the section name containing the key
	 * @param key      the key to which the value is associated
	 * @return         the value associated with the key in the provided section
	 */
	SWBuf getValue(const char *section, const char *key) {
		return (*this)[section][key];
	}

	/** set a value for a specified key in a [section]
	 * @param section  the section name to contain the key
	 * @param key      the key to which to associate the value
	 * @param value    the value to associated with the key
	 */
	void setValue(const char *section, const char *key, const char *value) {
		(*this)[section][key] = value;
	}

	/** The storage path used by this SWConfig object
	 */
	SWBuf getFileName() const;


	// ****** Deprecated methods for removal in 2.0

	/**
	 * @deprecated Use getSections() instead.
	 */
	SWDEPRECATED SectionMap Sections;

	/**
	 * @deprecated Use getFileName() instead.
	 */
	SWDEPRECATED SWBuf filename;

	/**
	 * @deprecated Use load() instead.
	 */
	SWDEPRECATED void Load() { load(); }

	/**
	 * @deprecated Use save() instead.
	 */
	SWDEPRECATED void Save() { save(); }

};
SWORD_NAMESPACE_END
#endif
