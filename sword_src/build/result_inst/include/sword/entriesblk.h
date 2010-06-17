#ifndef ENTRIESBLK_H
#define ENTRIESBLK_H

#include <sysdata.h>
#include <defs.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT EntriesBlock {
	static const int METAHEADERSIZE;
	static const int METAENTRYSIZE;

private:
	char *block;
	void setCount(int count);
	void getMetaEntry(int index, unsigned long *offset, unsigned long *size);
	void setMetaEntry(int index, unsigned long offset, unsigned long size);

public:
	EntriesBlock(const char *iBlock, unsigned long size);
	EntriesBlock();
	~EntriesBlock();

	int getCount();
	int addEntry(const char *entry);
	const char *getEntry(int entryIndex);
	unsigned long getEntrySize(int entryIndex);
	void removeEntry(int entryIndex);
	const char *getRawData(unsigned long *size);
};


SWORD_NAMESPACE_END
#endif
