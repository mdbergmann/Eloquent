/******************************************************************************
 *
 *  defs.h -	Global defines, mostly platform-specific stuff
 *
 * $Id: defs.h 3029 2014-02-25 13:00:49Z scribe $
 *
 * Copyright 2000-2013 CrossWire Bible Society (http://www.crosswire.org)
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
// ----------------------------------------------------------------------------
// 
// ----------------------------------------------------------------------------
#ifndef SWORDDEFS_H
#define SWORDDEFS_H

// TODO: What is this? jansorg, why does NO_SWORD_NAMESPACE still define
// a C++ namespace, and then force using it?  This makes no sense to me.
// see commit 1195
#ifdef NO_SWORD_NAMESPACE
 #define SWORD_NAMESPACE_START namespace sword {
 #define SWORD_NAMESPACE_END }; using namespace sword;
#elif defined(__cplusplus)
 #define SWORD_NAMESPACE_START namespace sword {
 #define SWORD_NAMESPACE_END }
#else
 #define SWORD_NAMESPACE_START 
 #define SWORD_NAMESPACE_END 
#endif

SWORD_NAMESPACE_START

#define SWTRY try
#define SWCATCH(x) catch (x)

#ifdef _WIN32_WCE
#define SWTRY
#define SWCATCH(x) if (0)
#define GLOBCONFPATH "/Program Files/sword/sword.conf"
#endif

#ifdef ANDROID
#define _NO_IOSTREAM_
#undef SWTRY
#undef SWCATCH
#define SWTRY
#define SWCATCH(x) if (0)
#endif

// _declspec works in BC++ 5 and later, as well as VC++
#if defined(_MSC_VER)

#  ifdef SWMAKINGDLL
#    define SWDLLEXPORT _declspec( dllexport )
#    define SWDLLEXPORT_DATA(type) _declspec( dllexport ) type
#    define SWDLLEXPORT_CTORFN
#  elif defined(SWUSINGDLL)
#    define SWDLLEXPORT _declspec( dllimport )
#    define SWDLLEXPORT_DATA(type) _declspec( dllimport ) type
#    define SWDLLEXPORT_CTORFN
#  else
#    define SWDLLEXPORT
#    define SWDLLEXPORT_DATA(type) type
#    define SWDLLEXPORT_CTORFN
#  endif

#  define SWDEPRECATED __declspec(deprecated("** WARNING: deprecated method **"))


#elif defined(__SWPM__)

#  ifdef SWMAKINGDLL
#    define SWDLLEXPORT _Export
#    define SWDLLEXPORT_DATA(type) _Export type
#    define SWDLLEXPORT_CTORFN
#  elif defined(SWUSINGDLL)
#    define SWDLLEXPORT _Export
#    define SWDLLEXPORT_DATA(type) _Export type
#    define SWDLLEXPORT_CTORFN
#  else
#    define SWDLLEXPORT
#    define SWDLLEXPORT_DATA(type) type
#    define SWDLLEXPORT_CTORFN
#  endif

#  define SWDEPRECATED 


#elif defined(__GNUWIN32__)

#  ifdef SWMAKINGDLL
#    define SWDLLEXPORT __declspec( dllexport )
#    define SWDLLEXPORT_DATA(type) __declspec( dllexport ) type
#    define SWDLLEXPORT_CTORFN
#  elif defined(SWUSINGDLL)
#    define SWDLLEXPORT __declspec( dllimport )
#    define SWDLLEXPORT_DATA(type) __declspec( dllimport ) type
#    define SWDLLEXPORT_CTORFN
#  else
#    define SWDLLEXPORT
#    define SWDLLEXPORT_DATA(type) type
#    define SWDLLEXPORT_CTORFN
#  endif

#  define SWDEPRECATED  __attribute__((__deprecated__))


#elif defined(__BORLANDC__)
#  ifdef SWMAKINGDLL
#    define SWDLLEXPORT _export
#    define SWDLLEXPORT_DATA(type) __declspec( dllexport ) type
#    define SWDLLEXPORT_CTORFN
#  elif defined(SWUSINGDLL)
#    define SWDLLEXPORT __declspec( dllimport )
#    define SWDLLEXPORT_DATA(type) __declspec( dllimport ) type
#    define SWDLLEXPORT_CTORFN
#  else
#    define SWDLLEXPORT
#    define SWDLLEXPORT_DATA(type) type
#    define SWDLLEXPORT_CTORFN
#  endif

#define COMMENT SLASH(/)
#define SLASH(s) /##s
#  define SWDEPRECATED COMMENT


#elif defined(__GNUC__)
#  define SWDLLEXPORT
#  define SWDLLEXPORT_DATA(type) type
#  define SWDLLEXPORT_CTORFN
#  define SWDEPRECATED  __attribute__((__deprecated__))


#else
#  define SWDLLEXPORT
#  define SWDLLEXPORT_DATA(type) type
#  define SWDLLEXPORT_CTORFN
#  define SWDEPRECATED
#endif


// For ostream, istream ofstream
#if defined(__BORLANDC__) && defined( _RTLDLL )
#  define SWDLLIMPORT __import
#else
#  define SWDLLIMPORT
#endif



#ifdef __cplusplus
enum {DIRECTION_LTR = 0, DIRECTION_RTL, DIRECTION_BIDI};
enum {FMT_UNKNOWN = 0, FMT_PLAIN, FMT_THML, FMT_GBF, FMT_HTML, FMT_HTMLHREF, FMT_RTF, FMT_OSIS, FMT_WEBIF, FMT_TEI, FMT_XHTML, FMT_LATEX};
enum {ENC_UNKNOWN = 0, ENC_LATIN1, ENC_UTF8, ENC_SCSU, ENC_UTF16, ENC_RTF, ENC_HTML};
enum {BIB_BIBTEX = 0, /* possible future formats: BIB_MARCXML, BIB_MARC21, BIB_DCMI BIB_OSISHEADER, BIB_SBL_XHTML, BIB_MLA_XHTML, BIB_APA_XHTML, BIB_CHICAGO_XHTML */};
#endif

SWORD_NAMESPACE_END
#endif //SWORDDEFS_H
