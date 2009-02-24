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
