/******************************************************************************
 *	swordapi.h	- This file contains an api usable by non-C++
 *					environments
 *
 * $Id: flatapi.h 2324 2009-04-20 18:40:15Z scribe $
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

#ifndef SWORDAPI_H
#define SWORDAPI_H

#include <defs.h>
#include <inttypes.h>
#ifdef __cplusplus
#endif

extern "C" {

#define SWHANDLE intptr_t


//-----------------------------------------------------------------
// stringlist_iterator methods

void SWDLLEXPORT stringlist_iterator_next(SWHANDLE hsli);
const char * SWDLLEXPORT stringlist_iterator_val(SWHANDLE hsli);

//-----------------------------------------------------------------
// listkey_iterator methods

void SWDLLEXPORT listkey_iterator_next(SWHANDLE lki);
const char * SWDLLEXPORT listkey_iterator_val(SWHANDLE hsli);
	
//-----------------------------------------------------------------
// modmap methods
//
void SWDLLEXPORT ModList_iterator_next(SWHANDLE hmmi);
SWHANDLE SWDLLEXPORT ModList_iterator_val(SWHANDLE hmmi);


//-----------------------------------------------------------------
// SWMgr methods
//
SWHANDLE SWDLLEXPORT SWMgr_new(char filterType);
// SWConfig *, SWConfig *, bool, SWFilterMgr *
SWHANDLE SWDLLEXPORT SWMgr_newEx(SWHANDLE hiconfig, SWHANDLE hisysconfig, char autoload, SWHANDLE hfilterMgr);
void     SWDLLEXPORT SWMgr_delete(SWHANDLE hmgr);
SWHANDLE SWDLLEXPORT SWMgr_getConfig(SWHANDLE hmgr);
SWHANDLE SWDLLEXPORT SWMgr_getModulesIterator(SWHANDLE hmgr);
SWHANDLE SWDLLEXPORT SWMgr_getModuleByName(SWHANDLE hmgr, const char *name);
const char *   SWDLLEXPORT SWMgr_getPrefixPath(SWHANDLE hmgr);
const char *   SWDLLEXPORT SWMgr_getConfigPath(SWHANDLE hmgr);
void     SWDLLEXPORT SWMgr_setGlobalOption(SWHANDLE hmgr, const char *option, const char *value);
const char *   SWDLLEXPORT SWMgr_getGlobalOption(SWHANDLE hmgr, const char *option);
const char *   SWDLLEXPORT SWMgr_getGlobalOptionTip(SWHANDLE hmgr, const char *option);
// ret: forward_iterator
SWHANDLE SWDLLEXPORT SWMgr_getGlobalOptionsIterator(SWHANDLE hmgr);
// ret: forward_iterator
SWHANDLE SWDLLEXPORT SWMgr_getGlobalOptionValuesIterator(SWHANDLE hmgr, const char *option);
void     SWDLLEXPORT SWMgr_setCipherKey(SWHANDLE hmgr, const char *modName, const char *key);


//-----------------------------------------------------------------
// SWModule methods

void  SWDLLEXPORT SWModule_terminateSearch(SWHANDLE hmodule);
SWHANDLE SWDLLEXPORT SWModule_doSearch(SWHANDLE hmodule, const char *searchString, int type, int params,  void (*percent) (char, void *), void *percentUserData);
char  SWDLLEXPORT SWModule_error(SWHANDLE hmodule);
int   SWDLLEXPORT SWModule_getEntrySize(SWHANDLE hmodule);
void  SWDLLEXPORT SWModule_setKeyText(SWHANDLE hmodule, const char *key);
const char * SWDLLEXPORT SWModule_getKeyText(SWHANDLE hmodule);
const char * SWDLLEXPORT SWModule_getName(SWHANDLE hmodule);
const char * SWDLLEXPORT SWModule_getDescription(SWHANDLE hmodule);
const char * SWDLLEXPORT SWModule_getType(SWHANDLE hmodule);
void  SWDLLEXPORT SWModule_previous(SWHANDLE hmodule);
void  SWDLLEXPORT SWModule_next(SWHANDLE hmodule);
void  SWDLLEXPORT SWModule_begin(SWHANDLE hmodule);
const char * SWDLLEXPORT SWModule_getStripText(SWHANDLE hmodule);
const char * SWDLLEXPORT SWModule_getRenderText(SWHANDLE hmodule);
const char * SWDLLEXPORT SWModule_getEntryAttributes(SWHANDLE hmodule, const char *level1, const char *level2, const char *level3);
const char * SWDLLEXPORT SWModule_getPreverseHeader(SWHANDLE hmodule, const char *key, int pvHeading);
const char * SWDLLEXPORT SWModule_getFootnoteType(SWHANDLE hmodule, const char *key, const char *note);
const char * SWDLLEXPORT SWModule_getFootnoteBody(SWHANDLE hmodule, const char *key, const char *note);
const char * SWDLLEXPORT SWModule_getFootnoteRefList(SWHANDLE hmodule, const char *key, const char *note);

SWHANDLE SWDLLEXPORT listkey_getVerselistIterator(const char *list, const char *key, const char *v11n = "KJV");

}
#ifdef __cplusplus
#endif

#endif
