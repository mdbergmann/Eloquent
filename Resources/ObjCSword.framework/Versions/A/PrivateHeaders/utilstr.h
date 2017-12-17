/******************************************************************************
 *
 *  utilstr.h -	prototypes for string utility functions
 *
 * $Id: utilstr.h 3515 2017-11-01 11:38:09Z scribe $
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

#ifndef UTILSTR_H
#define UTILSTR_H

#include <defs.h>
#include <sysdata.h>
#include <swbuf.h>

SWORD_NAMESPACE_START


/******************************************************************************
 * stdstr - clones a string
 *
 * ENT:	ipstr	- pointer to a string pointer to set if necessary
 *	istr	- string to set to *ipstr
 *			0 - only get
 *
 * RET:	*ipstr
 */

inline char *stdstr(char **ipstr, const char *istr, unsigned int memPadFactor = 1) {
	if (*ipstr)
		delete [] *ipstr;
	if (istr) {
		int len = (int)strlen(istr) + 1;
		*ipstr = new char [ len * memPadFactor ];
		memcpy(*ipstr, istr, len);
	}
	else *ipstr = 0;
	return *ipstr;
}

SWDLLEXPORT char *strstrip (char *istr);
SWDLLEXPORT const char *stristr (const char *s1, const char *s2);
SWDLLEXPORT int strnicmp(const char *s1, const char *s2, int len);
SWDLLEXPORT int stricmp(const char *s1, const char *s2);

/******************************************************************************
 * SW_toupper - array of uppercase values for any given Latin-1 value
 *
 * use this instead of toupper() for fast lookups on accented characters
 */
extern const unsigned char SW_toupper_array[256];
#define SW_toupper(c) SW_toupper_array[(unsigned char)c]

/******************************************************************************
 * getUniCharFromUTF8 - retrieves the next Unicode codepoint from a UTF8 string
 * 					and increments buf to start of next codepoint
 *
 * ENT:	buf - address of a utf8 buffer
 *
 * RET:	buf - incremented past last byte used in computing the current codepoint
 * 		unicode codepoint value (0 with buf incremented is invalid UTF8 byte
 */


/******************************************************************************
 * getUniCharFromUTF8 - retrieves the next Unicode codepoint from a UTF8 string
 * 					and increments buf to start of next codepoint
 *
 * ENT:	buf - address of a utf8 buffer
 *
 * RET:	buf - incremented past last byte used in computing the current codepoint
 * 		unicode codepoint value (0 with buf incremented is invalid UTF8 byte
 */

inline __u32 getUniCharFromUTF8(const unsigned char **buf, bool skipValidation = false) {
	__u32 ch = 0;

	//case: We're at the end
	if (!(**buf)) {
		return ch;
	}

	//case: ANSI
	if (!(**buf & 128)) {
		ch = **buf;
		(*buf)++;
		return ch;
	}

	//case: Invalid UTF-8 (illegal continuing byte in initial position)
	if ((**buf >> 6) == 2) {
		(*buf)++;
		return ch;
	}


	//case: 2+ byte codepoint
	int subsequent = 1;
	if ((**buf & 32) == 0) { subsequent = 1; }
	else if ((**buf & 16) == 0) { subsequent = 2; }
	else if ((**buf &  8) == 0) { subsequent = 3; }
	else if ((**buf &  4) == 0) { subsequent = 4; }
	else if ((**buf &  2) == 0) { subsequent = 5; }
	else if ((**buf &  1) == 0) { subsequent = 6; }
	else subsequent = 7; // is this legal?

	ch = **buf & (0xFF>>(subsequent + 1));

	for (int i = 1; i <= subsequent; ++i) {
		// subsequent byte did not begin with 10XXXXXX
		// move our buffer to here and error out
		// this also catches our null if we hit the string terminator
		if (((*buf)[i] >> 6) != 2) {
			*buf += i;
			return 0;
		}
		ch <<= 6;
		ch |= (*buf)[i] & 63;
	}
	*buf += (subsequent+1);

	if (!skipValidation) {
		// I THINK THIS IS STUPID BUT THE SPEC SAYS NO MORE THAN 4 BYTES
		if (subsequent > 3) ch = 0;
		// AGAIN stupid, but spec says UTF-8 can't use more than 21 bits
		if (ch > 0x1FFFFF) ch = 0;
		// This would be out of Unicode bounds
		if (ch > 0x10FFFF) ch = 0;
		// these would be values which could be represented in less bytes
		if (ch < 0x80 && subsequent > 0) ch = 0;
		if (ch < 0x800 && subsequent > 1) ch = 0;
		if (ch < 0x10000 && subsequent > 2) ch = 0;
		if (ch < 0x200000 && subsequent > 3) ch = 0;
	}

	return ch;
}


/******************************************************************************
 * getUTF8FromUniChar - retrieves us UTF8 string from a
 * 					Unicode codepoint
 *
 * ENT:	uchar - unicode codepoint value
 *
 * RET:	buf - a UTF8 string which consists of the proper UTF8 sequence of
 * 				bytes for the given Unicode codepoint
 * NOTE: for speed and thread safety, this method now requires a buffer
 * 		to work with
 */

inline SWBuf *getUTF8FromUniChar(__u32 uchar, SWBuf *appendTo) {
	unsigned long base = appendTo->size();

	// This would be out of Unicode bounds
	if (uchar > 0x10FFFF) uchar = 0xFFFD;
	char bytes = uchar < 0x80 ? 1 : uchar < 0x800 ? 2 : uchar < 0x10000 ? 3 : 4;
	appendTo->setSize(base+bytes);
	switch (bytes) {
	case 1:
		(*appendTo)[base  ] = (unsigned char)uchar;
		break;
	case 2:
		(*appendTo)[base+1] = (unsigned char)(0x80 | (uchar & 0x3f));
		uchar >>= 6;
		(*appendTo)[base  ] = (unsigned char)(0xc0 | (uchar & 0x1f));
		break;
	case 3:
		(*appendTo)[base+2] = (unsigned char)(0x80 | (uchar & 0x3f));
		uchar >>= 6;
		(*appendTo)[base+1] = (unsigned char)(0x80 | (uchar & 0x3f));
		uchar >>= 6;
		(*appendTo)[base  ] = (unsigned char)(0xe0 | (uchar & 0x0f));
		break;
	case 4:
		(*appendTo)[base+3] = (unsigned char)(0x80 | (uchar & 0x3f));
		uchar >>= 6;
		(*appendTo)[base+2] = (unsigned char)(0x80 | (uchar & 0x3f));
		uchar >>= 6;
		(*appendTo)[base+1] = (unsigned char)(0x80 | (uchar & 0x3f));
		uchar >>= 6;
		(*appendTo)[base  ] = (unsigned char)(0xf0 | (uchar & 0x07));
		break;
	}
/*
	else if (uchar < 0x4000000) {
		appendTo->setSize(base+5);
		i = uchar & 0x3f;
		(*appendTo)[base+4] = (unsigned char)(0x80 | i);
		uchar >>= 6;

		i = uchar & 0x3f;
		(*appendTo)[base+3] = (unsigned char)(0x80 | i);
		uchar >>= 6;

		i = uchar & 0x3f;
		(*appendTo)[base+2] = (unsigned char)(0x80 | i);
		uchar >>= 6;

		i = uchar & 0x3f;
		(*appendTo)[base+1] = (unsigned char)(0x80 | i);
		uchar >>= 6;

		i = uchar & 0x03;
		(*appendTo)[base] = (unsigned char)(0xf8 | i);
	}
	else if (uchar < 0x80000000) {
		appendTo->setSize(base+6);
		i = uchar & 0x3f;
		(*appendTo)[base+5] = (unsigned char)(0x80 | i);
		uchar >>= 6;

		i = uchar & 0x3f;
		(*appendTo)[base+4] = (unsigned char)(0x80 | i);
		uchar >>= 6;

		i = uchar & 0x3f;
		(*appendTo)[base+3] = (unsigned char)(0x80 | i);
		uchar >>= 6;

		i = uchar & 0x3f;
		(*appendTo)[base+2] = (unsigned char)(0x80 | i);
		uchar >>= 6;

		i = uchar & 0x3f;
		(*appendTo)[base+1] = (unsigned char)(0x80 | i);
		uchar >>= 6;

		i = uchar & 0x01;
		(*appendTo)[base] = (unsigned char)(0xfc | i);
	}
*/
	return appendTo;
}


/******************************************************************************
 * assureValidUTF8 - iterates the supplied UTF-8 buffer and checks for validity
 * 					replacing invalid bytes if necessary and returning a
 *					verified UTF8 buffer, leaving the original input
 *					unchanged.
 *
 * ENT:	buf - a utf8 buffer
 *
 * RET:	input buffer validated and any problems fixed by substituting a
 * 		replacement character for bytes not valid.
 */
SWBuf assureValidUTF8(const char *buf);

/****
 * This can be called to convert a UTF8 stream to an SWBuf which manages
 *	a wchar_t[]
 *	access buffer with (wchar_t *)SWBuf::getRawData();
 * 
 */
SWBuf utf8ToWChar(const char *buf);

/****
 * This can be called to convert a wchar_t[] to a UTF-8 SWBuf
 * 
 */
SWBuf wcharToUTF8(const wchar_t *buf);



SWORD_NAMESPACE_END
#endif
