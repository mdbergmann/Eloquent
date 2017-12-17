/******************************************************************************
 *
 *  sysdata.h -	
 *
 * $Id: sysdata.h 3455 2017-04-24 08:50:31Z scribe $
 * 
 * Copyright 2001-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef SIZEDTYPES_H
#define SIZEDTYPES_H
/*
 * __xx is ok: it doesn't pollute the POSIX namespace. Use these in the
 * header files exported to user space
 */
#ifdef USE_AUTOTOOLS
#include "config.h"
#endif


typedef signed char __s8;
typedef unsigned char __u8;

typedef signed short __s16;
typedef unsigned short __u16;

typedef signed int __s32;
typedef unsigned int __u32;

#ifdef OS_ANDROID
#elif defined(__GNUC__)
__extension__ typedef __signed__ long long __s64;
__extension__ typedef unsigned long long __u64;
#elif defined(__BORLANDC__)
typedef signed __int64 __s64;
typedef unsigned __int64 __u64;
#else
typedef signed long long __s64;
typedef unsigned long long __u64;
#endif

#undef __swswap16
#undef __swswap32
#undef __swswap64

#define __swswap16(x) \
	((__u16)( \
		(((__u16)(x) & (__u16)0x00ffU) << 8) | \
		(((__u16)(x) & (__u16)0xff00U) >> 8) ))

		
#define __swswap32(x) \
	((__u32)( \
		(((__u32)(x) & (__u32)0x000000ffUL) << 24) | \
		(((__u32)(x) & (__u32)0x0000ff00UL) <<  8) | \
		(((__u32)(x) & (__u32)0x00ff0000UL) >>  8) | \
		(((__u32)(x) & (__u32)0xff000000UL) >> 24) ))

		
#define __swswap64(x) \
	((__u64)( \
		(__u64)(((__u64)(x) & (__u64)0x00000000000000ffULL) << 56) | \
		(__u64)(((__u64)(x) & (__u64)0x000000000000ff00ULL) << 40) | \
		(__u64)(((__u64)(x) & (__u64)0x0000000000ff0000ULL) << 24) | \
		(__u64)(((__u64)(x) & (__u64)0x00000000ff000000ULL) <<  8) | \
		   (__u64)(((__u64)(x) & (__u64)0x000000ff00000000ULL) >>  8) | \
		(__u64)(((__u64)(x) & (__u64)0x0000ff0000000000ULL) >> 24) | \
		(__u64)(((__u64)(x) & (__u64)0x00ff000000000000ULL) >> 40) | \
		(__u64)(((__u64)(x) & (__u64)0xff00000000000000ULL) >> 56) ))
		



#ifndef WORDS_BIGENDIAN

#define swordtoarch16(x) (x)
#define swordtoarch32(x) (x)
#define swordtoarch64(x) (x)
#define archtosword16(x) (x)
#define archtosword32(x) (x)
#define archtosword64(x) (x)

#else 

#define swordtoarch16(x) __swswap16(x)
#define swordtoarch32(x) __swswap32(x)
#define swordtoarch64(x) __swswap64(x)
#define archtosword16(x) __swswap16(x)
#define archtosword32(x) __swswap32(x)
#define archtosword64(x) __swswap64(x)


#endif


#endif
