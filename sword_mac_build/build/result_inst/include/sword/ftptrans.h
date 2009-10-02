/******************************************************************************
*  ftptrans.h  - code for FTP Transport
*
* $Id: swbuf.h 2218 2008-12-23 09:33:38Z scribe $
*
* Copyright 2009 CrossWire Bible Society (http://www.crosswire.org)
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

// TODO: Rename this to RemoteTransport in 1.7.x

#ifndef FTPTRANS_H
#define FTPTRANS_H

#include <vector>
#include <defs.h>
#include <swbuf.h>


SWORD_NAMESPACE_START

/** Class for reporting status
*/
class SWDLLEXPORT StatusReporter {
public:
	virtual ~StatusReporter() {};
	/** Messages before stages of a batch download */
	virtual void preStatus(long totalBytes, long completedBytes, const char *message);

	/** frequently called throughout a download, to report status */
	virtual void statusUpdate(double dtTotal, double dlNow);
};


/** TODO: document
* A base class to be used for reimplementation of network services.
*/
class SWDLLEXPORT FTPTransport {	// TODO: rename to more generic RemoteTransport

protected:
	StatusReporter *statusReporter;
	bool passive;
	bool term;
	SWBuf host;
	SWBuf u;
	SWBuf p;

public:
	FTPTransport(const char *host, StatusReporter *statusReporter = 0);
	virtual ~FTPTransport();

	/***********
	 * override this method in your real impl
	 *
	 * if destBuf then write to buffer instead of file
	 */
	virtual char getURL(const char *destPath, const char *sourceURL, SWBuf *destBuf = 0);


	int copyDirectory(const char *urlPrefix, const char *dir, const char *dest, const char *suffix);

	virtual std::vector<struct DirEntry> getDirList(const char *dirURL);
	void setPassive(bool passive) { this->passive = passive; }
	void setUser(const char *user) { u = user; }
	void setPasswd(const char *passwd) { p = passwd; }
	void terminate() { term = true; }
};


SWORD_NAMESPACE_END

#endif
