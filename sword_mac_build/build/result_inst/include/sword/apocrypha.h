/******************************************************************************
 * apocrypha.h - Apocryphal text information to be included by VerseKey.cpp
 *
 * $Id: apocrypha.h 2180 2008-07-13 20:29:25Z scribe $
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

/******************************************************************************
 * [a]tbooks - initialize static instance for all canonical text names
 *		and chapmax
 */

#include <defs.h>
//SWORD_NAMESPACE_START

//Data based on NRSVA unless otherwise noted; this book ordering is not necessarily optimal.

struct VersificationBook
VerseKey::otbooks[] = {
  //Catholic Deuterocanon
  {"Tobit", "Tob", 14},                        //67
  {"Judith", "Jdt", 16},                       //68
  {"Wisdom", "Wis", 19},                       //69
  {"Sirach", "Sir", 51},                       //70   //51 or 52? count prologue as separate book or just chapter?
  {"Baruch", "Bar", 5},                        //71   //5 or 6?  (see next line)
  {"Letter of Jeremiah", "EpJer", 1},          //72   //1 or 6?  EpJer is ch6 of Baruch
  {"1 Esdras", "1Esd", 9},                     //73
  {"2 Esdras", "2Esd", 16},                    //74
  {"1 Maccabees", "1Macc", 16},                //75
  {"2 Maccabees", "2Macc", 15},                //76

  //LXX
  {"3 Maccabees", "3Macc", 7},                 //77
  {"4 Maccabees", "4Macc", 18},                //78
  {"Odes", "Odes", 14},                        //79   //based on LXX
  {"Psalms of Solomon", "PssSol", 18},         //80   //based on LXX

  //Protestant Apocrypha
  {"Additions to Esther", "AddEsth", 6},       //81   //based on Charles/NRSVA   //6 or F or 16?  If you're Catholic, you have a 16 chapter canonical book called Esther (ie Greek Esther); if you're Protestant you have a 10 chapter canonical book called Esther (ie Hebrew Esther) plus a 6 "chapter" set of "Additions" in an apocryphal book called Additions to Esther, which are "numbered" A through F or continue from chapter 10 through 16.
  {"Prayer of Azariah", "PrAzar", 1},          //82
  {"Susanna", "Sus", 1},                       //83
  {"Bel and the Dragon", "Bel", 1},            //84
  {"Prayer of Manasses", "PrMan", 1},          //85
  {"Psalm 151", "Ps151", 1},                   //86

  //Vulgate
  {"Epistle to the Laodiceans", "EpLao", 1},   //87   //based on Vulgate

  //Other books may follow at a later date (e.g. Jub, 1En)
};

/******************************************************************************
 *	Abbreviations - MUST be in alphabetical order & by PRIORITY
 *		RULE: first match of entire key
 *			(e.g. key: "1CH"; match: "1CHRONICLES")
 */

const struct abbrev
  VerseKey::builtin_abbrevs[] = {
  {"1 ESDRAS", 73},
  {"1 MACCABEES", 75},
  {"1ESDRAS", 73},
  {"1MACCABEES", 75},
  {"2 ESDRAS", 74},
  {"2 MACCABEES", 76},
  {"2ESDRAS", 74},
  {"2MACCABEES", 76},
  {"3 MACCABEES", 77},
  {"3MACCABEES", 77},
  {"4 MACCABEES", 78},
  {"4MACCABEES", 78},
  {"ADDESTHER", 81},
  {"ADDITIONS TO ESTHER", 81},
  {"BARUCH", 71},
  {"BEL AND THE DRAGON", 84},
  {"BEN SIRACH", 70},
  {"ECCLESIASTICUS", 70},
  {"EPISTLE OF JEREMIAH", 72},
  {"EPISTLE TO THE LAODICEANS", 87},
  {"EPJER", 72},
  {"EPLAO", 87},
  {"I ESDRAS", 73},
  {"I MACCABEES", 75},
  {"IESDRAS", 73},
  {"II ESDRAS", 74},
  {"II MACCABEES", 76},
  {"IIESDRAS", 74},
  {"III MACCABEES", 77},
  {"IIII MACCABEES", 78},
  {"IIIIMACCABEES", 78},
  {"IIIMACCABEES", 77},
  {"IIMACCABEES", 76},
  {"IMACCABEES", 75},
  {"IV MACCABEES", 78},
  {"IVMACCABEES", 78},
  {"JDT", 68},
  {"JESUS BEN SIRACH", 70},
  {"JUDITH", 68},
  {"LAODICEANS", 87},
  {"LETTER OF JEREMIAH", 72},
  {"MANASSEH", 85},
  {"MANASSES", 85},
  {"ODES", 79},
  {"PRAYER OF AZARIAH", 82},
  {"PRAYER OF MANASSEH", 85},
  {"PRAYER OF MANASSES", 85},
  {"PRAZAR", 82},
  {"PRMAN", 85},
  {"PS151", 86},
  {"PSALM151", 86},
  {"PSALMS OF SOLOMON", 80},
  {"PSSOL", 80},
  {"PSSSOL", 80},
  {"SIRACH", 70},
  {"SUSANNA", 83},
  {"TOBIT", 67},
  {"WISDOM OF JESUS BEN SIRACH", 70},
  {"WISDOM", 69},
  {"", -1}
};


/******************************************************************************
 *	Maximum verses per chapter
 */

int
VerseKey::vm[] = {
  //Catholic Deuterocanon
  //Tobit 14                        //67
  22, 14, 17, 21, 21, 17, 18, 21, 6, 12,
  19, 22, 18, 15,
  //Judith 16                       //68
  16, 28, 10, 15, 24, 21, 32, 36, 14, 23,
  23, 20, 20, 19, 13, 25,
  //Wisdom 19                       //69
  16, 24, 19, 20, 23, 25, 30, 21, 18, 21,
  26, 27, 19, 31, 19, 29, 21, 25, 22,
  //Sirach 51                       //70      //Prologue has 36 vv. in LXX, 1 v. in NRSVA
  30, 18, 31, 31, 15, 37, 36, 19, 18, 31,
  34, 18, 26, 27, 20, 30, 32, 33, 30, 32,
  28, 27, 27, 34, 26, 29, 30, 26, 28, 25,
  31, 24, 31, 26, 20, 26, 31, 34, 35, 30,
  23, 25, 33, 23, 26, 20, 25, 25, 16, 29,
  30,
  //Baruch 5                        //71
  21, 35, 37, 37, 9,
  //Letter of Jeremiah 1            //72
  73,
  //1 Esdras 9                      //73
  58, 30, 24, 63, 73, 34, 15, 96, 55,
  //2 Esdras 16                     //74
  40, 48, 36, 52, 56, 59, 140, 63, 47, 59,
  46, 51, 58, 48, 63, 78,
  //1 Maccabees 16                  //75
  64, 70, 60, 61, 68, 63, 50, 32, 73, 89,
  74, 53, 53, 49, 41, 24,
  //2 Maccabees 15                  //76
  36, 32, 40, 50, 27, 31, 42, 36, 29, 38,
  38, 45, 26, 46, 39,

  //LXX
  //3 Maccabees 7                   //77
  29, 33, 30, 21, 51, 41, 23,
  //4 Maccabees 18                  //78
  35, 24, 21, 26, 38, 35, 23, 29, 32, 21,
  27, 19, 27, 20, 32, 25, 24, 24,
  //Odes            14              //79
  19, 43, 10, 19, 20, 10, 45, 88, 79, 9,
  20, 15, 32, 46,
  //Psalms of Solomon 18            //80
  8, 37, 12, 25, 19, 6, 10, 34, 11, 8,
  9, 6, 12, 10, 13, 15, 46, 12,

  //Protestant Apocrypha
  //Additions to Esther 6           //81
  17, 7, 30, 16, 24, 11
  //Prayer of Azariah 1             //82
  68,
  //Susanna 1                       //83
  64,
  //Bel and the Dragon 1            //84
  42,
  //Prayer of Manasses 1            //85
  15,
  //Psalm 151 1                     //86
  7,

  //Vulgate
  //Epistle to the Laodiceans 1     //87
  20,
};


long
  VerseKey::atbks[] = {
0, 1, 16, 33, 53, 105, 111, 113, 123, 140, 157, 173, 181, 200, 215, 234, 241, 243, 245, 247, 249, 251
};

long
  VerseKey::atcps[] = {
0, 2, 3, 26, 41, 59, 81, 103, 121, 140, 162, 169, 183, 203, 226, 245, 262, 279, 308, 319, 335, 360, 382, 415, 452, 467, 492, 516, 537, 558, 578, 592, 619, 636, 661, 681, 702, 726, 752, 783, 805, 824, 847, 874, 902, 922, 954, 974, 1004, 1026, 1052, 1076, 1107, 1126, 1158, 1190, 1206, 1244, 1281, 1301, 1320, 1353, 1388, 1407, 1434, 1462, 1483, 1514, 1547, 1581, 1612, 1646, 1675, 1703, 1731, 1766, 1793, 1823, 1854, 1881, 1910, 1937, 1969, 1994, 2026, 2053, 2074, 2101, 2133, 2168, 2204, 2236, 2260, 2286, 2320, 2344, 2371, 2392, 2418, 2444, 2461, 2492, 2524, 2546, 2582, 2620, 2658, 2669, 2744, 2803, 2834, 2859, 2923, 2997, 3032, 3048, 3145, 3202, 3243, 3292, 3329, 3382, 3439, 3499, 3640, 3704, 3752, 3813, 3860, 3912, 3971, 4020, 4084, 4164, 4229, 4300, 4361, 4423, 4492, 4556, 4607, 4640, 4714, 4805, 4880, 4934, 4988, 5038, 5080, 5106, 5143, 5176, 5217, 5268, 5296, 5328, 5371, 5408, 5438, 5478, 5517, 5563, 5590, 5637, 5678, 5708, 5742, 5773, 5795, 5847, 5889, 5914, 5950, 5975, 5997, 6024, 6063, 6099, 6123, 6153, 6186, 6209, 6237, 6257, 6285, 6306, 6339, 6365, 6390, 6416, 6436, 6480, 6491, 6511, 6532, 6543, 6589, 6678, 6758, 6769, 6790, 6806, 6839, 6887, 6896, 6934, 6947, 6973, 6993, 7000, 7011, 7046, 7058, 7068, 7078, 7085, 7098, 7109, 7123, 7139, 7186, 7200, 7270, 7336, 7380, 7397, 7406
};

//SWORD_NAMESPACE_END
