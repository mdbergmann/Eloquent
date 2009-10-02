/******************************************************************************
 *  swfiltermgr.h   - definition of class SWFilterMgr used as an interface to
 *				manage filters on a module
 *
 * $Id: swfiltermgr.h 1864 2005-11-20 06:06:40Z scribe $
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

#ifndef SWFILTERMGR_H
#define SWFILTERMGR_H

#include <defs.h>
#include <swconfig.h>

SWORD_NAMESPACE_START

class SWModule;
class SWMgr;

/** Class to manage different kinds of filters.
*/
class SWDLLEXPORT SWFilterMgr {

private:
	SWMgr *parentMgr;

public:
  SWFilterMgr();
  virtual ~SWFilterMgr();

  virtual void setParentMgr(SWMgr *parentMgr);
  virtual SWMgr *getParentMgr();

  virtual void AddGlobalOptions(SWModule *module, ConfigEntMap &section, ConfigEntMap::iterator start,
				 ConfigEntMap::iterator end);
  virtual void AddLocalOptions(SWModule *module, ConfigEntMap &section, ConfigEntMap::iterator start,
				ConfigEntMap::iterator end);


  /**
    * Adds the encoding filters which are defined in "section" to the SWModule object "module".
    * @param module To this module the encoding filter(s) are added
    * @param section We use this section to get a list of filters we should apply to the module
    */
  virtual void AddEncodingFilters(SWModule *module, ConfigEntMap &section);


    /**
    * Adds the render filters which are defined in "section" to the SWModule object "module".
    * @param module To this module the render filter(s) are added
    * @param section We use this section to get a list of filters we should apply to the module
    */
  virtual void AddRenderFilters(SWModule *module, ConfigEntMap &section);


  /**
    * Adds the strip filters which are defined in "section" to the SWModule object "module".
    * @param module To this module the strip filter(s) are added
    * @param section We use this section to get a list of filters we should apply to the module
    */
  virtual void AddStripFilters(SWModule *module, ConfigEntMap &section);


  /**
    * Adds the raw filters which are defined in "section" to the SWModule object "module".
    * @param module To this module the raw filter(s) are added
    * @param section We use this section to get a list of filters we should apply to the module
    */
  virtual void AddRawFilters(SWModule *module, ConfigEntMap &section);

};
SWORD_NAMESPACE_END
#endif
