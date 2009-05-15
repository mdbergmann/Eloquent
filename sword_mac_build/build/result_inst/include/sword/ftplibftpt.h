/******************************************************************************
*  ftplibftpt.h  - code for ftplib impl of FTP Transport
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
#ifndef FTPLIBFTPT_H
#define FTPLIBFTPT_H

#include <defs.h>
#include <ftptrans.h>

typedef struct NetBuf netbuf;

SWORD_NAMESPACE_START


// initialize/cleanup SYSTEMWIDE library with life of this static.
class FTPLibFTPTransport_init {
public:
	FTPLibFTPTransport_init();
	~FTPLibFTPTransport_init();
};


class SWDLLEXPORT FTPLibFTPTransport : public FTPTransport {
	netbuf *ftpConnection;

	char assureLoggedIn();

public:
	FTPLibFTPTransport(const char *host, StatusReporter *statusReporter = 0);
	~FTPLibFTPTransport();
	char getURL(const char *destPath, const char *sourceURL, SWBuf *destBuf = 0);
};


SWORD_NAMESPACE_END

#endif
