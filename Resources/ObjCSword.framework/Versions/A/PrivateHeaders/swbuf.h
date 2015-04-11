/******************************************************************************
 *
 *  swbuf.h -	code for SWBuf used as a transport and utility for data buffers
 *
 * $Id: swbuf.h 2980 2013-09-14 21:51:47Z scribe $
 *
 * Copyright 2003-2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef SWBUF_H
#define SWBUF_H

#include <defs.h>
#include <stdlib.h>
#include <string.h>
#ifdef __BORLANDC__
#include <mem.h>
#endif

SWORD_NAMESPACE_START


#define JUNKBUFSIZE 65534

/**
* This class is used as a transport and utility for data buffers.
*
* @warning This class does not perform pointer validity checks (for speed reasons). 
*	Therefore, never try to pass an invalid string (const char* 0) as an argument-
*	it will crash your program. You need to perform the checks yourself!
*/
class SWDLLEXPORT SWBuf {
	char *buf;
	char *end;
	char *endAlloc;
	char fillByte;
	unsigned long allocSize;

	inline void assureMore(size_t pastEnd) {
		if (size_t(endAlloc-end) < pastEnd) {
			assureSize(allocSize + pastEnd);
		}
	}

	inline void assureSize(size_t checkSize) {
		if (checkSize > allocSize) {
			long size = (end - buf);
			checkSize += 128;
			buf = (char *)((allocSize) ? realloc(buf, checkSize) : malloc(checkSize));
			allocSize = checkSize;
			end = (buf + size);
			*end = 0;
			endAlloc = buf + allocSize - 1;
		}
	}

	inline void init(size_t initSize) {
		fillByte = ' ';
		allocSize = 0;
		buf = nullStr;
		end = buf;
		endAlloc = buf;
		if (initSize)
			assureSize(initSize);
	}


public:

	static char *nullStr;

	/******************************************************************************
	* SWBuf Constructor - Creates an empty SWBuf object
	*
	*/
	inline SWBuf() {
		init(0);
	}

	/**
	* SWBuf Constructor - Creates an SWBuf initialized
	* 		to a value from a const char *
 	*
 	*/
	SWBuf(const char *initVal, unsigned long initSize = 0);
//	SWBuf(unsigned long initSize);

	/**
	* SWBuf Constructor - Creates an SWBuf initialized
	* 		to a value from a char
	*
	*/
	SWBuf(char initVal, unsigned long initSize = 0);

	/**
	* SWBuf Constructor - Creates an SWBuf initialized
	* 		to a value from another SWBuf
	*
	*/
	SWBuf(const SWBuf &other, unsigned long initSize = 0);

	/******************************************************************************
	* SWBuf Destructor - Cleans up instance of SWBuf
	*/
	inline ~SWBuf() {
		if ((buf) && (buf != nullStr))
			free(buf);
	}

	/**
	* SWBuf::setFillByte - Set the fillByte character
	*
	* @param ch This character is used when the SWBuf is (re)sized.
	*   The memory will be filled with this character. \see setSize() \see resize()
	*/
	inline void setFillByte(char ch) { fillByte = ch; }

	/**
	* SWBuf::getFillByte - Get the fillByte character
	*
	* @return The character used for filling memory. \see setFillByte.
	*/
	inline char getFillByte() { return fillByte; }

	/**
	* @return a pointer to the buffer content (null-terminated string)
	*/
	inline const char *c_str() const{ return buf; }

	/**
	*	@param pos The position of the requested character.
	* @return The character at the specified position
	*/
	inline char &charAt(unsigned long pos) { return ((pos <= (unsigned long)(end - buf)) ? buf[pos] : (*nullStr)); }

	/** 
	* @return size() and length() return only the number of characters of the string.
	* Add one for the following null and one for each char to be appended!
	*/
	inline unsigned long size() const { return length(); }

	/** 
	 * set's the size of the buffer.  This is a quick inline method which checks
	 * for changes before actually calling setSize().
	 * @param newSize new size of the buffer
	 */
	inline void size(unsigned long newSize) { if (end - buf - newSize) setSize(newSize); }

	/**
	* @return size() and length() return only the number of characters of the string.
	*/
	inline unsigned long length() const { return end - buf; }

	/**
	* SWBuf::set - sets this buf to a new value
	* If the allocated memory is bigger than the new string, it will NOT be resized.
	* @param newVal the value to set this buffer to. 
	*/
	inline void set(const SWBuf &newVal) {
		unsigned long len = newVal.length() + 1;
		assureSize(len);
//		const char *n = newVal.c_str();
//		for (end = buf;len;len--) *end++ = *n++;
		memcpy(buf, newVal.c_str(), len);
		end = buf + (len - 1);
	}

	/**
	* SWBuf::set - sets this buf to a new value.
	* If the allocated memory is bigger than the new string, it will NOT be resized.
	* @param newVal the value to set this buffer to. 
	*/
	inline void set(const char *newVal) {
		if (newVal) {
			unsigned long len = strlen(newVal) + 1;
			assureSize(len);
			memcpy(buf, newVal, len);
			end = buf + (len - 1);
		}
		else {
			assureSize(1);
			end = buf;
			*end = 0;
		}
	}

	/**
	* SWBuf::setFormatted - sets this buf to a formatted string.
	* If the allocated memory is bigger than the new string, it will NOT be resized.
	*
	* @warning This function can only write at most JUNKBUFSIZE to the string per call.
	*
	* @warning This function is not very fast. For loops with many iterations you might
	*  consider replacing it by other calls. 
	*  Example: 
	*    \code SWBuf buf.setFormatted("<%s>", stringVal); \endcode 
	*  should be replaced by: 
	*    \code buf.set("<"); buf.append(stringVal); buf.append(">"); \endcode
	*  This will produce much faster results.
	*
	* @param format The format string. Same syntax as printf, for example.
	* @param ... Add all arguments here.
	*/
	SWBuf &setFormatted(const char *format, ...);

	/**
	* SWBuf::setSize - Size this buffer to a specific length.
	* @param len The new size of the buffer. One byte for the null will be added.
	*/
	void setSize(unsigned long len);
	/**
	* SWBuf::resize - Resize this buffer to a specific length.
	* @param len The new size of the buffer. One byte for the null will be added.
	*/
	inline void resize(unsigned long len) { setSize(len); }

	/**
	* SWBuf::append - appends a value to the current value of this SWBuf.
	* If the allocated memory is not enough, it will be resized accordingly.
	* @param str Append this.
	* @param max Append only max chars.
	*/
	SWBuf &append(const char *str, long max = -1);

	/**
	* SWBuf::append - appends a value to the current value of this SWBuf
	* If the allocated memory is not enough, it will be resized accordingly.
	* @param str Append this.
	* @param max Append only max chars.
	*/
	inline SWBuf &append(const SWBuf &str, long max = -1) { return append(str.c_str(), max); }

	/**
	* SWBuf::append - appends a value to the current value of this SWBuf
	* If the allocated memory is not enough, it will be resized accordingly.
	* @param ch Append this.
	*/
	inline SWBuf &append(char ch) {
		assureMore(1);
		*end++ = ch;
		*end = 0;
		return *this;
	}
	inline SWBuf &append(const unsigned char ch) {
		assureMore(1);
		*end++ = ch;
		*end = 0;
		return *this;
	}

	/**
	* SWBuf::append - appends a wide charachter value to the current value of this SWBuf
	* If the allocated memory is not enough, it will be resized accordingly.
	* NOTE: This is dangerous, as wchar_t is currently different sizes on different
	* platforms (stupid windoze; stupid c++ spec for not mandating 4byte).
	* @param ch Append this.
	*/
	inline SWBuf &append(wchar_t wch) {
		assureMore(sizeof(wchar_t)*2);
		for (unsigned int i = 0; i < sizeof(wchar_t); i++) *end++ = ((char *)&wch)[i];
		for (unsigned int i = 0; i < sizeof(wchar_t); i++) end[i] = 0;
		return *this;
	}

	/**
	* SWBuf::appendFormatted - appends formatted strings to the current value of this SWBuf.
	*
	* @warning This function can only write at most JUNKBUFSIZE to the string per call.
	*
	* @warning This function is not very fast. For loops with many iterations you might
	*  consider replacing it by other calls. 
	*  Example: 
	*    \code SWBuf buf.appendFormatted("<%s>", stringVal); \endcode 
	*  should be replaced by: 
	*    \code buf.append("<"); buf.append(stringVal); buf.append(">"); \endcode
	*  This will produce much faster results.
	*
	* @param format The format string. Same syntax as printf, for example.
	* @param ... Add all arguments here.
	*/
	SWBuf &appendFormatted(const char *format, ...);
	
	/** 
	* SWBuf::insert - inserts the given string at position into this string
	* @param pos The position where to insert. pos=0 inserts at the beginning, pos=1 after the first char, etc. Using pos=length() is the same as calling append(s)
	* @param str string to be inserted
	* @param start start from this position in the string to be inserted
	* @param max Insert only max chars.
	*/
	void insert(unsigned long pos, const char* str, unsigned long start = 0, signed long max = -1);

	/** 
	* SWBuf::insert - inserts the given string at position into this string
	* @param pos The position where to insert. pos=0 inserts at the beginning, pos=1 after the first char, etc. Using pos=length() is the same as calling append(s)
	* @param str string to be inserted
	* @param start start from this position in the string to be inserted
	* @param max Insert only max chars.
	*/
	inline void insert(unsigned long pos, const SWBuf &str, unsigned long start = 0, signed long max = -1) {
		insert(pos, str.c_str(), start, max);
	};

	/** 
	* SWBuf::insert - inserts the given character at position into this string
	* @param pos The position where to insert. pos=0 inserts at the beginning, pos=1 after the first char, etc. Using pos=length() is the same as calling append(s)
	* @param c Insert this.
	*/
	inline void insert(unsigned long pos, char c) {
		insert(pos, SWBuf(c));
	}

	/** SWBuf::getRawData
	*
	* @warning be careful! Probably setSize needs to be called in conjunction before and maybe after
	*
	* @return Pointer to the allocated memory of the SWBuf.
	*/
	inline char *getRawData() { return buf; }

	inline operator const char *() const { return c_str(); }
	inline char &operator[](unsigned long pos) { return charAt(pos); }
	inline char &operator[](long pos) { return charAt((unsigned long)pos); }
	inline char &operator[](unsigned int pos) { return charAt((unsigned long)pos); }
	inline char &operator[](int pos) { return charAt((unsigned long)pos); }
	inline SWBuf &operator =(const char *newVal) { set(newVal); return *this; }
	inline SWBuf &operator =(const SWBuf &other) { set(other); return *this; }
	inline SWBuf &operator +=(const char *str) { append(str); return *this; }
	inline SWBuf &operator +=(char ch) { append(ch); return *this; }

	/**
	 * Decrease the buffer size, discarding the last characters
	 * @param len how many bytes to decrease the buffer size
	 */
	inline SWBuf &operator -=(unsigned long len) { setSize(length()-len); return *this; }

	/**
	 * Decrease the buffer size, discarding the last character
	 */
	inline SWBuf &operator --(int) { operator -=(1); return *this; }

	/**
	 * Shift the buffer to the left, discarding the first bytes, decreasing the buffer size
	 */
	inline SWBuf &operator <<(unsigned long n) { if (n && length()) { n = (n<=length())?n:(length()-1); memmove(buf, buf+n, length()-n); (*this)-=n; } return *this; }

	/**
	 * Shift the buffer to the right, increasing the buffer size
	 */
	inline SWBuf &operator >>(unsigned long n) { setSize(length()+n); memmove(buf+n, buf, length()-n); return *this; }

	/**
	 * Concatenate another buffer to the end of this buffer
	 */
	inline SWBuf operator +(const SWBuf &other) const {
		SWBuf retVal = buf;
		retVal += other;
		return retVal;
	}

	/**
	 * Concatenate a byte to the end of this buffer
	 */
	inline SWBuf operator +(char ch) const { return (*this) + SWBuf(ch); }

	/**
	 * Trim whitespace from the start of this buffer, shifting the buffer left as necessary
	 */
	inline SWBuf &trimStart() { while (size() && (strchr("\t\r\n ", *(buf)))) *this << 1; return *this; }

	/**
	 * Trim whitespace from the end of this buffer, decreasing the size as necessary
	 */
	inline SWBuf &trimEnd() { while (size() && (strchr("\t\r\n ", *(end-1)))) setSize(size()-1); return *this; }

	/**
	 * Trim whitespace from the start and end of this buffer, shifting left and decreasing size as necessary
	 */
	inline SWBuf &trim() { trimStart(); return trimEnd(); }


	/**
	 * Strip a prefix from this buffer up to a separator byte.
	 * Returns the prefix and modifies this buffer, shifting left to remove prefix
	 * @param separator to use (e.g. ':')
	 * @param endOfStringAsSeparator - also count end of string as separator.
	 *                                 this is useful for tokenizing entire string like:
	 *                                 x|y|z
	 *                                 if true it will also include 'z'.
	 *
	 * @return prefix if separator character found; otherwise, null and leaves buffer unmodified
	 */
	inline const char *stripPrefix(char separator, bool endOfStringAsSeparator = false) { const char *m = strchr(buf, separator); if (!m && endOfStringAsSeparator) { if (*buf) { operator >>(1); *buf=0; end = buf; return buf + 1;} else return buf; } if (m) { int len = m-buf; char *hold = new char[len]; memcpy(hold, buf, len); *this << (len+1); memcpy(end+1, hold, len); delete [] hold; end[len+1] = 0; } return (m) ? end+1 : 0; }  // safe.  we know we don't actually realloc and shrink buffer when shifting, so we can place our return val at end.

	// this could be nicer, like replacing a contiguous series of target bytes with single replacement; offering replacement const char *
	/**
	 * Replace with a new byte value all occurances in this buffer of any byte value specified in a set
	 * @param targets a set of bytes, any of which will be replaced
	 * @param newByte value to use as replacement.
	 *
	 * Example: replaceBytes("abc", 'z');  // replaces all occurances of 'a', 'b', and 'c' with 'z'
	 */
	inline SWBuf &replaceBytes(const char *targets, char newByte) { for (unsigned int i = 0; (i < size()); i++) { if (strchr(targets, buf[i])) buf[i] = newByte; } return *this; }

	/**
	 * @return returns true if this buffer starts with the specified prefix
	 */
	inline bool startsWith(const SWBuf &prefix) const { return !strncmp(c_str(), prefix.c_str(), prefix.size()); }

	/**
	 * @return returns true if this buffer ends with the specified postfix
	 */
	inline bool endsWith(const SWBuf &postfix) const { return (size() >= postfix.size())?!strncmp(end-postfix.size(), postfix.c_str(), postfix.size()):false; }

	/**
	 * @return returns the index of a substring if it is found in this buffer; otherwise, returns < 0
	 */
	inline long indexOf(const SWBuf &needle) const { const char *ch = strstr(buf, needle.c_str()); return (ch) ? ch - buf : -1; }
	
	inline int compare(const SWBuf &other) const { return strcmp(c_str(), other.c_str()); }
	inline bool operator ==(const SWBuf &other) const { return compare(other) == 0; }
	inline bool operator !=(const SWBuf &other) const { return compare(other) != 0; }
	inline bool operator > (const SWBuf &other) const { return compare(other) > 0; }
	inline bool operator < (const SWBuf &other) const { return compare(other) < 0; }
	inline bool operator <=(const SWBuf &other) const { return compare(other) <= 0; }
	inline bool operator >=(const SWBuf &other) const { return compare(other) >= 0; }

	/**
	 * @return returns true if this buffer starts with the specified prefix
	 */
	inline bool startsWith(const char *prefix) const { return !strncmp(c_str(), prefix, strlen(prefix)); }

	/**
	 * @return returns true if this buffer ends with the specified postfix
	 */
	inline bool endsWith(const char *postfix) const { unsigned int psize = strlen(postfix); return (size() >= psize)?!strncmp(end-psize, postfix, psize):false; }

	// be sure we've been given a valid pointer to compare.  If not, we return !=; specifically less-than, for lack of better options
	inline int compare(const char *other) const { return (other?strcmp(c_str(), other):-1); }
	inline bool operator ==(const char *other) const { return compare(other) == 0; }
	inline bool operator !=(const char *other) const { return compare(other) != 0; }
	inline bool operator > (const char *other) const { return other && compare(other) > 0; }
	inline bool operator < (const char *other) const { return other && compare(other) < 0; }
	inline bool operator <=(const char *other) const { return other && compare(other) <= 0; }
	inline bool operator >=(const char *other) const { return other && compare(other) >= 0; }
};



SWORD_NAMESPACE_END
#endif
