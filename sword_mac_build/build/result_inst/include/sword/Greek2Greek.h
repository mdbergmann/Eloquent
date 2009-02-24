//*****************************************************************************
// Author      : William Dicks                                              ***
// Date Created: 10 February 1998                                           ***
// Purpose     : Interface for Greek to b-Greek conversion and vice versa   ***
// File Name   : Greek2Greek.h                                              ***
//                                                                          ***
// Author info : ---------------------------------------------------------- ***
//     Address : 23 Tieroogpark                                             ***
//             : Hoewe Str                                                  ***
//             : Elarduspark X3                                             ***
//             : 0181                                                       ***
//             : South Africa                                               ***
//     Home Tel: +27 (0)12 345 3166                                         ***
//     Cell No : +27 (0)82 577 4424                                         ***
//     e-mail  : wd@isis.co.za                                              ***
// Church WWW  : http://www.hatfield.co.za                                  ***
//*****************************************************************************
/*
 *
 * $Id: Greek2Greek.h 1688 2005-01-01 04:42:26Z scribe $
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

#ifndef __GREEK2GREEK
#define __GREEK2GREEK

#include <defs.h>
SWORD_NAMESPACE_START

//*****************************************************************************
// Used to convert a string created by using the Greek font supplied with the
// Sword Project to a string that conforms to the b-Greek discussion list 
// method of transliteration.
//*****************************************************************************
unsigned char Greek2bGreek (unsigned char *sResult, unsigned char *sGreekText,
			    int nMaxResultBuflen);

//*****************************************************************************
// Used to convert a string created by using the b-Greek method of 
// transliteration to a string that can be converted to a Greek-font readable 
// string.
//*****************************************************************************
unsigned char bGreek2Greek (unsigned char *sResult,
			    unsigned char *sGreekText, int nMaxResultBuflen);

//*****************************************************************************
// Parse a Greek font created string and return the b-Greek equivalent
//*****************************************************************************
int ParseGreek (unsigned char *sResult,
		unsigned char *sGreekText, int nMaxResultBuflen);

//*****************************************************************************
// Parse a b-Greek string and return the Greek font equivalent
//*****************************************************************************
int ParsebGreek (unsigned char *sResult,
		 unsigned char *sGreekText, int nMaxResultBuflen);

//*****************************************************************************
// Convert a unsigned character to a GREEK font unsigned character
//*****************************************************************************
unsigned char char2Font (unsigned char letter,	// bGreek letter to convert to Font letter
			 bool finalSigma,	// Is it a final SIGMA
			 bool iota,	// TRUE = IOTA subscript; FALSE = No IOTA
			 bool breathing,	// TRUE = add breathing; FALSE = no breathing
			 bool rough);	// TRUE = rough breathing; False = smooth

//*****************************************************************************
// Convert a GREEK font unsigned character to a unsigned character
//*****************************************************************************
unsigned char Font2char (unsigned char letter,	// bGreek letter to convert to Font letter
			 bool & iota,	// TRUE = IOTA subscript; FALSE = No IOTA
			 bool & breathing,	// TRUE = add breathing; FALSE = no breathing
			 bool & rough);	// TRUE = rough breathing; False = smooth


//*****************************************************************************
// Identify and return a bGreek letter from a special font char
//*****************************************************************************
bool getSpecialChar (unsigned char Font, unsigned char &letter);

//*****************************************************************************
// true if the font character is a special character; false it isn't
//*****************************************************************************
bool SpecialGreek (unsigned char Font);

//*****************************************************************************
// Return Greek font puntuation from bGreek punstuation
//*****************************************************************************
unsigned char getGreekPunct (unsigned char bGreek);

//*****************************************************************************
// Return bGreek puntuation from Greek font punstuation
//*****************************************************************************
unsigned char getbGreekPunct (unsigned char Greek);

//*****************************************************************************
// Is the character punctuation or a space: true it is, false it isn't
//*****************************************************************************
bool isPunctSpace (unsigned char c);

SWORD_NAMESPACE_END

#endif // __GREEK2GREEK
