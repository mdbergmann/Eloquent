/******************************************************************************
 *  swlog.h	- definition of class SWLog used for logging messages
 *
 * $Id: swlog.h 2080 2007-09-17 06:21:29Z scribe $
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

//---------------------------------------------------------------------------
#ifndef swlogH
#define swlogH
//---------------------------------------------------------------------------

#include <defs.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT SWLog {
protected:
	char logLevel;
	static SWLog *systemLog;

public:

	static const int LOG_ERROR;
	static const int LOG_WARN;
	static const int LOG_INFO;
	static const int LOG_TIMEDINFO;
	static const int LOG_DEBUG;

	static SWLog *getSystemLog();
	static void setSystemLog(SWLog *newLogger);

	SWLog() { logLevel = 1;	/*default to show only errors*/}
	virtual ~SWLog() {};

	void setLogLevel(char level) { logLevel = level; }
	char getLogLevel() const { return logLevel; }
	void logWarning(const char *fmt, ...) const;
	void logError(const char *fmt, ...) const;
	void logInformation(const char *fmt, ...) const;
	virtual void logTimedInformation(const char *fmt, ...) const;
	void logDebug(const char *fmt, ...) const;

	// Override this method if you want to have a custom logger
	virtual void logMessage(const char *message, int level) const;
};

SWORD_NAMESPACE_END
#endif
