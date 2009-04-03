/******************************************************************************
 *  rawverse.h   - code for class 'RawVerse'- a module that reads raw text
 *			files:  ot and nt using indexs ??.bks ??.cps ??.vss
 *			and provides lookup and parsing functions based on
 *			class VerseKey
 */

#ifndef RAWVERSE_H
#define RAWVERSE_H


#include <defs.h>

SWORD_NAMESPACE_START

class FileDesc;
class SWBuf;

class SWDLLEXPORT RawVerse {


	static int instance;		// number of instantiated RawVerse objects or derivitives
protected:
	FileDesc *idxfp[2];
	FileDesc *textfp[2];

	char *path;
	void doSetText(char testmt, long idxoff, const char *buf, long len = -1);
	void doLinkEntry(char testmt, long destidxoff, long srcidxoff);

public:
	static const char *nl;
	RawVerse(const char *ipath, int fileMode = -1);
	virtual ~RawVerse();
	void findOffset(char testmt, long idxoff, long *start,	unsigned short *end) const;
	void readText(char testmt, long start, unsigned short size, SWBuf &buf);
	static char createModule(const char *path, const char *v11n = "KJV");
};

SWORD_NAMESPACE_END
#endif
