//*****************************************************************************
// Author      : William Dicks                                              ***
// Date Created: 10 February 1998                                           ***
// Purpose     : Enumeration for Greek to b-Greek conversion and vice       ***
//             : versa.                                                     ***
// File Name   : GreekChars.h                                               ***
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
 * $Id: GreekChars.h 1688 2005-01-01 04:42:26Z scribe $
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

#ifndef __GREEKCHARS_H
#define __GREEKCHARS_H

// This enum represents the values of the characters used for the 
// transliteration as used on the b-greek discussion list.

#include <defs.h>
SWORD_NAMESPACE_START

enum bGreekChars
{
  ALPHA = 65,			// A
  BETA,				// B
  CHI,				// C
  DELTA,			// D
  EPSILON,			// E
  PHI,				// F
  GAMMA,			// G
  ETA,				// H
  IOTA,				// I
  // No J
  KAPPA = 75,			// K
  LAMBDA,			// L
  MU,				// M
  NU,				// N
  OMICRON,			// O
  PI,				// P
  THETA,			// Q
  RHO,				// R
  SIGMA,			// S
  TAU,				// T
  UPSILON,			// U
  // No V
  OMEGA = 'W',			// W
  XI,				// X
  PSI,				// Y
  ZETA,				// Z
  ROUGH = 104,			// h
  IOTA_SUB			// i
};

// This enum represents the values of the characters ib the Greek.ttf font,
// and the comments on the right are the corresponding bGreek equivalents.

enum GreekFontChars
{
  gALPHA = 'a',			// A
  gBETA,			// B
  gCHI,				// C
  gDELTA,			// D
  gEPSILON,			// E
  gPHI,				// F
  gGAMMA,			// G
  gETA,				// H
  gIOTA,			// I
  gSIGMA_END,			// j
  gKAPPA,			// K
  gLAMBDA,			// L
  gMU,				// M
  gNU,				// N
  gOMICRON,			// O
  gPI,				// P
  gTHETA,			// Q
  gRHO,				// R
  gSIGMA,			// S
  gTAU,				// T
  gUPSILON,			// U
  // No V
  gOMEGA = 'w',			// W
  gXI,				// X
  gPSI,				// Y
  gZETA,			// Z
  gROUGH_ALPHA = 161,		// hA
  gROUGH_EPSILON = 152,		// hE
  gROUGH_ETA = 185,		// hH
  gROUGH_IOTA = 131,		// hH
  gROUGH_OMICRON = 208,		// hH
  gROUGH_RHO = 183,		// hR
  gROUGH_UPSILON = 216,		// hU
  gROUGH_OMEGA = 230,		// hW
  gIOTA_ALPHA = 'v',		// Ai
  gIOTA_ETA = 'V',		// Ei
  gIOTA_OMEGA = 'J',		// Wi
  gNON_ROUGH_ALPHA = 162,	// hA
  gNON_ROUGH_EPSILON = 153,	// hE
  gNON_ROUGH_ETA = 186,		// hH
  gNON_ROUGH_IOTA = 132,	// hH
  gNON_ROUGH_OMICRON = 209,	// hH
  gNON_ROUGH_RHO = 184,		// hR
  gNON_ROUGH_UPSILON = 217,	// hU
  gNON_ROUGH_OMEGA = 231	// hW
};

// English puntuation as used on bGreek

enum bGreekPunct
{
  COMMA = ',',
  STOP = '.',
  SEMI_COLON = ';',
  QUESTION = '?'
};

// English puntuation as used in the Greek font

enum GreekPunct
{
  gCOMMA = ',',
  gSTOP = '.',
  gSEMI_COLON = ':',
  gQUESTION = ';'
};

SWORD_NAMESPACE_END

#endif // __GREEKCHARS_H
