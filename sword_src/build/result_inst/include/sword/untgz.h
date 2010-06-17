#ifndef UNTGZ_H
#define UNTGZ_H

#include "zlib.h"

int untargz(int fd, const char *dest);
int untar(gzFile in, const char *dest);

#endif

