/***************************************************************************
 *
 * $Id: gbfosis.h 1864 2005-11-20 06:06:40Z scribe $
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

#ifndef GBFOSIS_H
#define GBFOSIS_H

#include <swfilter.h>
#include <stack>
#include <swbuf.h>

SWORD_NAMESPACE_START


class SWDLLEXPORT QuoteStack {
private:
	class QuoteInstance {
	public:
		char startChar;
		char level;
		SWBuf uniqueID;
		char continueCount;
		QuoteInstance(char startChar = '\"', char level = 1, SWBuf uniqueID = "", char continueCount = 0) {
			this->startChar     = startChar;
			this->level         = level;
			this->uniqueID      = uniqueID;
			this->continueCount = continueCount;
		}
		void pushStartStream(SWBuf &text);
	};

	typedef std::stack<QuoteInstance> QuoteInstanceStack;
	QuoteInstanceStack quotes;
public:
	QuoteStack();
	virtual ~QuoteStack();
	void handleQuote(char *buf, char *quotePos, SWBuf &text);
	void clear();
	bool empty() { return quotes.empty(); }
};

/** this filter converts GBF text to OSIS text
 */
class SWDLLEXPORT GBFOSIS : public SWFilter {
public:
	GBFOSIS();
	virtual ~GBFOSIS();
	char processText(SWBuf &text, const SWKey *key = 0, const SWModule *module = 0);
};

SWORD_NAMESPACE_END
#endif /* THMLOSIS_H */
