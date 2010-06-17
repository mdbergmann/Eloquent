/******************************************************************************
 *  swbasicfilter.h	- definition of class SWBasicFilter.  An SWFilter
 *  				impl that provides some basic methods that
 *  				many filter will need and can use as a starting
 *  				point. 
 *
 * $Id: swbasicfilter.h 1984 2006-10-08 05:06:52Z scribe $
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

#ifndef SWBASICFILTER_H
#define SWBASICFILTER_H

#include <swfilter.h>
#include <swbuf.h>

SWORD_NAMESPACE_START


// not a protected inner class because MSVC++ sucks and can't handle it
class SWDLLEXPORT BasicFilterUserData {
public:
	BasicFilterUserData(const SWModule *module, const SWKey *key) { this->module = module; this->key = key; suspendTextPassThru = false; supressAdjacentWhitespace = false; }
	virtual ~BasicFilterUserData() {}
	const SWModule *module;
	const SWKey *key;
	SWBuf lastTextNode;
	SWBuf lastSuspendSegment;
	bool suspendTextPassThru;
	bool supressAdjacentWhitespace;
};

/** A filter providing commonly used functionality.
 * This filter has facilities for handling SGML/HTML/XML like tokens and
 * escape strings (like SGML entities). It has the facility for just
 * substituting the given tokens and escape strings to other strings and for
 * "manual" custom token handling.
 *
 * In this class the functions with arguments looking as <code>char
 * **buf</code> write a character sequnce at address specified by
 * <code>*buf</code> address and change <code>*buf</code> to point past
 * the last char of the written sequence.
 */
class SWDLLEXPORT SWBasicFilter : public SWFilter {

class Private;

	char *tokenStart;
	char *tokenEnd;
	char *escStart;
	char *escEnd;
	char escStartLen;
	char escEndLen;
	char tokenStartLen;
	char tokenEndLen;
	bool escStringCaseSensitive;
	bool tokenCaseSensitive;
	bool passThruUnknownToken;
	bool passThruUnknownEsc;
	bool passThruNumericEsc;
	char processStages;


	Private *p;
public:

	SWBasicFilter();
	virtual char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
	virtual ~SWBasicFilter();

protected:

	virtual BasicFilterUserData *createUserData(const SWModule *module, const SWKey *key) {
		return new BasicFilterUserData(module, key);
	}

	// STAGEs
	static const char INITIALIZE;	// flag for indicating processing before char loop
	static const char PRECHAR;	// flag for indicating processing at top in char loop
	static const char POSTCHAR;	// flag for indicating processing at bottom in char loop
	static const char FINALIZE;	// flag for indicating processing after char loop


	/** Sets the beginning of escape sequence (by default "&").*/
	void setEscapeStart(const char *escStart);

	/** Sets the end of escape sequence (by default ";").*/
	void setEscapeEnd(const char *escEnd);

	/** Sets the beginning of token start sequence (by default "<").*/
	void setTokenStart(const char *tokenStart);

	/** Sets the end of token start sequence (by default ">").*/
	void setTokenEnd(const char *tokenEnd);

	/** Sets whether to pass thru an unknown token unchanged
	 *	or just remove it.
	 * Default is false.*/
	void setPassThruUnknownToken(bool val);

	/** Sets whether to pass thru an unknown escape sequence unchanged
	 *	or just remove it.
	 *	Default is false.
	 */
	void setPassThruUnknownEscapeString(bool val);

	/** Sets whether to pass thru a numeric escape sequence unchanged
	 *	or allow it to be handled otherwise.
	 * Default is false.*/
	void setPassThruNumericEscapeString(bool val);

	/** Are escapeStrings case sensitive or not? Call this
	 *	function before addEscapeStingSubstitute()
	 */
	void setEscapeStringCaseSensitive(bool val);

	/** Registers an esc control sequence that can pass unchanged
	 */
	void addAllowedEscapeString(const char *findString);

	/** Unregisters an esc control sequence that can pass unchanged
	 */
	void removeAllowedEscapeString(const char *findString);

	/** Registers an esc control sequence
	 */
	void addEscapeStringSubstitute(const char *findString, const char *replaceString);

	/** Unregisters an esc control sequence
	 */
	void removeEscapeStringSubstitute(const char *findString);

	/** This function performs the substitution of escapeStrings */
	bool substituteEscapeString(SWBuf &buf, const char *escString);

	/** This passes allowed escapeStrings */
	bool passAllowedEscapeString(SWBuf &buf, const char *escString);

	/** This appends escString to buf as an entity */
	void appendEscapeString(SWBuf &buf, const char *escString);

	/** Are tokens case sensitive (like in GBF) or not? Call this
	 *	function before addTokenSubstitute()
	 */
	void setTokenCaseSensitive(bool val);

	/** Registers a simple token substitutions.  Usually called from the
	 *	c-tor of a subclass
	 */
	void addTokenSubstitute(const char *findString, const char *replaceString);

	/** Unregisters a simple token substitute
	 */
	void removeTokenSubstitute(const char *findString);

	/** This function performs the substitution of tokens */
	bool substituteToken(SWBuf &buf, const char *token);

	/** This function is called for every token encountered in the input text.
	 * @param buf the output buffer
	 * @param token the token (e.g. <code>"p align='left'"</code>
	 * @param userData user storage space for data transient to 1 full buffer parse
	 * @return subclasses should return true if they handled the token, or false if they did not.
	 */
	virtual bool handleToken(SWBuf &buf, const char *token, BasicFilterUserData *userData);

	virtual bool processStage(char /*stage*/, SWBuf &/*text*/, char *&/*from*/, BasicFilterUserData * /*userData*/) { return false; }
	virtual void setStageProcessing(char stages) { processStages = stages; }	// see STATICs up above

	/** This function is called for every escape sequence encountered in the input text.
	 * @param buf the output buffer 
	 * @param escString the escape sequence (e.g. <code>"amp"</code> for &amp;amp;)
	 * @param userData user storage space for data transient to 1 full buffer parse
	 * @return <code>false</code> if was not handled and should be handled in
	 * @return subclasses should return true if they handled the esc seq, or false if they did not.
	 */
	virtual bool handleEscapeString(SWBuf &buf, const char *escString, BasicFilterUserData *userData);

	/** This function is called for all numeric escape sequences. If passThrough
	 * @param buf the output buffer 
	 * @param escString the escape sequence (e.g. <code>"#235"</code> for &amp;235;)
	 * @return subclasses should return true if they handled the esc seq, or false if they did not.
         */
	virtual bool handleNumericEscapeString(SWBuf &buf, const char *escString);


};

SWORD_NAMESPACE_END
#endif
