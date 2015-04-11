/******************************************************************************
 *
 *  swcomprs.h -	definition of Class SWCompress used for data
 *			compression
 *
 * $Id: swcomprs.h 3122 2014-03-14 08:08:28Z chrislit $
 *
 * Copyright 1996-2014 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef SWCOMPRS_H
#define SWCOMPRS_H

#include <defs.h>

SWORD_NAMESPACE_START

class SWDLLEXPORT SWCompress
{
  void Init ();
  void cycleStream ();
protected:
  char *buf, *zbuf, direct;	// 0 - encode; 1 - decode
  unsigned long zlen, zpos, pos, slen;
  int level;
public:
  SWCompress ();
  virtual ~ SWCompress ();
  virtual char *Buf (const char *buf = 0, unsigned long *len = 0);
  virtual char *zBuf (unsigned long *len, char *buf = 0);
  virtual unsigned long GetChars (char *buf, unsigned long len);	// override for other than buffer compression
  virtual unsigned long SendChars (char *buf, unsigned long len);	// override for other than buffer compression
  virtual void Encode (void);	// override to provide compression algorythm
  virtual void Decode (void);	// override to provide compression algorythm
  virtual void setLevel(int l) {level = l;};
  virtual int getLevel() {return level;};
};

SWORD_NAMESPACE_END
#endif
