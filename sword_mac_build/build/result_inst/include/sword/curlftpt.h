#ifndef CURLFTPT_H
#define CURLFTPT_H

#include <defs.h>
#include <ftptrans.h>

SWORD_NAMESPACE_START

class CURL;

// initialize/cleanup SYSTEMWIDE library with life of this static.
class CURLFTPTransport_init {
public:
	CURLFTPTransport_init();
	~CURLFTPTransport_init();
};


class SWDLLEXPORT CURLFTPTransport : public FTPTransport {
	CURL *session;

public:
	CURLFTPTransport(const char *host, StatusReporter *statusReporter = 0);
	~CURLFTPTransport();
	
	virtual char getURL(const char *destPath, const char *sourceURL, SWBuf *destBuf = 0);
};


SWORD_NAMESPACE_END

#endif
