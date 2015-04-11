/******************************************************************************
 *
 *  sapphire.h -	the Saphire II stream cipher class
 *
 * $Id: sapphire.h 2833 2013-06-29 06:40:28Z chrislit $
 * 
 * Copyright 1999-2013 CrossWire Bible Society (http://www.crosswire.org)
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

/******************************************************************************
 *
 * Original license notice & credits:
 * Dedicated to the Public Domain the author and inventor
 * (Michael Paul Johnson).  This code comes with no warranty.
 * Use it at your own risk.
 * Ported from the Pascal implementation of the Sapphire Stream
 * Cipher 9 December 1994.
 * Added hash-specific functions 27 December 1994.
 * Made index variable initialization key-dependent,
 * made the output function more resistant to cryptanalysis,
 * and renamed to Sapphire II Stream Cipher 2 January 1995.
 *
 * unsigned char is assumed to be 8 bits.  If it is not, the
 * results of assignments need to be reduced to 8 bits with
 * & 0xFF or % 0x100, whichever is faster.
 */  
  
#ifndef NULL
#define NULL 0
#endif	/*  */

#include <defs.h>

SWORD_NAMESPACE_START

  class sapphire 
{
  
    // These variables comprise the state of the state machine.
  unsigned char cards[256];	// A permutation of 0-255.
  unsigned char rotor,		// Index that rotates smoothly
    ratchet,			// Index that moves erratically
    avalanche,			// Index heavily data dependent
    last_plain,			// Last plain text byte
    last_cipher;		// Last cipher text byte
  
    // This function is used by initialize(), which is called by the
    // constructor.
  unsigned char keyrand (int limit, unsigned char *user_key,
			  unsigned char keysize, unsigned char *rsum,
unsigned *keypos); public:sapphire (unsigned char
				      *key = NULL,	// Calls initialize if a real
				      unsigned char keysize = 0);	// key is provided.  If none
  // is provided, call initialize
  // before encrypt or decrypt.
  ~sapphire ();			// Destroy cipher state information.
  void initialize (unsigned char *key,	// User key is used to set
		   unsigned char keysize);	// up state information.
  void hash_init (void);	// Set up default hash.
  unsigned char encrypt (unsigned char b = 0);	// Encrypt byte
  // or get a random byte.
  unsigned char decrypt (unsigned char b);	// Decrypt byte.
  void hash_final (unsigned char *hash,	// Copy hash value to hash
		   unsigned char hashlength = 20);	// Hash length (16-32)
  void burn (void);		// Destroy cipher state information.
};


SWORD_NAMESPACE_END
