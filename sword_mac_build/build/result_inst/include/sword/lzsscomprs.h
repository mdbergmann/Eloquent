/******************************************************************************
 *  lzsscomprs.h   - definition of Class SWCompress used for data compression
 *
 * $Id: lzsscomprs.h 1688 2005-01-01 04:42:26Z scribe $
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

#ifndef LZSSCOMPRS_H
#define LZSSCOMPRS_H

#include <swcomprs.h>

#include <defs.h>

SWORD_NAMESPACE_START

// The following are constant sizes used by the compression algorithm.
//
//  N         - This is the size of the ring buffer.  It is set
//              to 4K.  It is important to note that a position
//              within the ring buffer requires 12 bits.  
//
//  F         - This is the maximum length of a character sequence
//              that can be taken from the ring buffer.  It is set
//              to 18.  Note that a length must be 3 before it is
//              worthwhile to store a position/length pair, so the
//              length can be encoded in only 4 bits.  Or, put yet
//              another way, it is not necessary to encode a length
//              of 0-18, it is necessary to encode a length of
//              3-18, which requires 4 bits.
//              
//  THRESHOLD - It takes 2 bytes to store an offset and
//              a length.  If a character sequence only
//              requires 1 or 2 characters to store 
//              uncompressed, then it is better to store
//              it uncompressed than as an offset into
//              the ring buffer.
//
// Note that the 12 bits used to store the position and the 4 bits
// used to store the length equal a total of 16 bits, or 2 bytes.

#define N		4096
#define F		18
#define THRESHOLD	3
#define NOT_USED	N



class SWDLLEXPORT LZSSCompress:public SWCompress
{
  static unsigned char m_ring_buffer[N + F - 1];
  static short int m_match_position;
  static short int m_match_length;
  static short int m_lson[N + 1];
  static short int m_rson[N + 257];
  static short int m_dad[N + 1];
  void InitTree ();
  void InsertNode (short int Pos);
  void DeleteNode (short int Node);
public:
    LZSSCompress ();
    virtual ~ LZSSCompress ();
  virtual void Encode (void);
  virtual void Decode (void);
};

SWORD_NAMESPACE_END
#endif
