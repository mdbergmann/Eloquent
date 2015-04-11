/******************************************************************************
 *
 *  canon_leningrad.h -	Versification data for the Leningrad system
 *
 * $Id: canon_leningrad.h 2915 2013-07-23 16:55:54Z chrislit $
 *
 * Copyright 2009-2013 CrossWire Bible Society (http://www.crosswire.org)
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
 */

#ifndef CANON_LENINGRAD_H
#define CANON_LENINGRAD_H

SWORD_NAMESPACE_START


// Versification system: Leningrad
// Book order: Gen Exod Lev Num Deut Josh Judg 1Sam 2Sam 1Kgs 2Kgs Isa Jer Ezek Hos Joel Amos Obad Jonah Mic Nah Hab Zeph Hag Zech Mal 1Chr 2Chr Ps Job Prov Ruth Song Eccl Lam Esth Dan Ezra Neh

/******************************************************************************
 * [on]tbooks_leningrad - initialize static instance for all canonical
 *		 text names and chapmax
 */
struct sbook otbooks_leningrad[] = {
  {"Genesis", "Gen", "Gen", 50},
  {"Exodus", "Exod", "Exod", 40},
  {"Leviticus", "Lev", "Lev", 27},
  {"Numbers", "Num", "Num", 36},
  {"Deuteronomy", "Deut", "Deut", 34},
  {"Joshua", "Josh", "Josh", 24},
  {"Judges", "Judg", "Judg", 21},
  {"I Samuel", "1Sam", "1Sam", 31},
  {"II Samuel", "2Sam", "2Sam", 24},
  {"I Kings", "1Kgs", "1Kgs", 22},
  {"II Kings", "2Kgs", "2Kgs", 25},
  {"Isaiah", "Isa", "Isa", 66},
  {"Jeremiah", "Jer", "Jer", 52},
  {"Ezekiel", "Ezek", "Ezek", 48},
  {"Hosea", "Hos", "Hos", 14},
  {"Joel", "Joel", "Joel", 4},
  {"Amos", "Amos", "Amos", 9},
  {"Obadiah", "Obad", "Obad", 1},
  {"Jonah", "Jonah", "Jonah", 4},
  {"Micah", "Mic", "Mic", 7},
  {"Nahum", "Nah", "Nah", 3},
  {"Habakkuk", "Hab", "Hab", 3},
  {"Zephaniah", "Zeph", "Zeph", 3},
  {"Haggai", "Hag", "Hag", 2},
  {"Zechariah", "Zech", "Zech", 14},
  {"Malachi", "Mal", "Mal", 3},
  {"I Chronicles", "1Chr", "1Chr", 29},
  {"II Chronicles", "2Chr", "2Chr", 36},
  {"Psalms", "Ps", "Ps", 150},
  {"Job", "Job", "Job", 42},
  {"Proverbs", "Prov", "Prov", 31},
  {"Ruth", "Ruth", "Ruth", 4},
  {"Song of Solomon", "Song", "Song", 8},
  {"Ecclesiastes", "Eccl", "Eccl", 12},
  {"Lamentations", "Lam", "Lam", 5},
  {"Esther", "Esth", "Esth", 10},
  {"Daniel", "Dan", "Dan", 12},
  {"Ezra", "Ezra", "Ezra", 10},
  {"Nehemiah", "Neh", "Neh", 13},
  {"", "", "", 0}
};

// for ntbooks_mt, use ntbooks_null

/******************************************************************************
 *	Maximum verses per chapter
 */

int vm_leningrad[] = {
  // Genesis
  31, 25, 24, 26, 32, 22, 24, 22, 29, 32,
  32, 20, 18, 24, 21, 16, 27, 33, 38, 18,
  34, 24, 20, 67, 34, 35, 46, 22, 35, 43,
  54, 33, 20, 31, 29, 43, 36, 30, 23, 23,
  57, 38, 34, 34, 28, 34, 31, 22, 33, 26,
  // Exodus
  22, 25, 22, 31, 23, 30, 29, 28, 35, 29,
  10, 51, 22, 31, 27, 36, 16, 27, 25, 26,
  37, 30, 33, 18, 40, 37, 21, 43, 46, 38,
  18, 35, 23, 35, 35, 38, 29, 31, 43, 38,
  // Leviticus
  17, 16, 17, 35, 26, 23, 38, 36, 24, 20,
  47, 8, 59, 57, 33, 34, 16, 30, 37, 27,
  24, 33, 44, 23, 55, 46, 34,
  // Numbers
  54, 34, 51, 49, 31, 27, 89, 26, 23, 36,
  35, 16, 33, 45, 41, 35, 28, 32, 22, 29,
  35, 41, 30, 25, 19, 65, 23, 31, 39, 17,
  54, 42, 56, 29, 34, 13,
  // Deuteronomy
  46, 37, 29, 49, 33, 25, 26, 20, 29, 22,
  32, 31, 19, 29, 23, 22, 20, 22, 21, 20,
  23, 29, 26, 22, 19, 19, 26, 69, 28, 20,
  30, 52, 29, 12,
  // Joshua
  18, 24, 17, 24, 15, 27, 26, 35, 27, 43,
  23, 24, 33, 15, 63, 10, 18, 28, 51, 9,
  45, 34, 16, 33,
  // Judges
  36, 23, 31, 24, 31, 40, 25, 35, 57, 18,
  40, 15, 25, 20, 20, 31, 13, 31, 30, 48,
  25,
  // I Samuel
  28, 36, 21, 22, 12, 21, 17, 22, 27, 27,
  15, 25, 23, 52, 35, 23, 58, 30, 24, 42,
  16, 23, 28, 23, 44, 25, 12, 25, 11, 31,
  13,
  // II Samuel
  27, 32, 39, 12, 25, 23, 29, 18, 13, 19,
  27, 31, 39, 33, 37, 23, 29, 32, 44, 26,
  22, 51, 39, 25,
  // I Kings
  53, 46, 28, 20, 32, 38, 51, 66, 28, 29,
  43, 33, 34, 31, 34, 34, 24, 46, 21, 43,
  29, 54,
  // II Kings
  18, 25, 27, 44, 27, 33, 20, 29, 37, 36,
  20, 22, 25, 29, 38, 20, 41, 37, 37, 21,
  26, 20, 37, 20, 30,
  // Isaiah
  31, 22, 26, 6, 30, 13, 25, 23, 20, 34,
  16, 6, 22, 32, 9, 14, 14, 7, 25, 6,
  17, 25, 18, 23, 12, 21, 13, 29, 24, 33,
  9, 20, 24, 17, 10, 22, 38, 22, 8, 31,
  29, 25, 28, 28, 25, 13, 15, 22, 26, 11,
  23, 15, 12, 17, 13, 12, 21, 14, 21, 22,
  11, 12, 19, 11, 25, 24,
  // Jeremiah
  19, 37, 25, 31, 31, 30, 34, 23, 25, 25,
  23, 17, 27, 22, 21, 21, 27, 23, 15, 18,
  14, 30, 40, 10, 38, 24, 22, 17, 32, 24,
  40, 44, 26, 22, 19, 32, 21, 28, 18, 16,
  18, 22, 13, 30, 5, 28, 7, 47, 39, 46,
  64, 34,
  // Ezekiel
  28, 10, 27, 17, 17, 14, 27, 18, 11, 22,
  25, 28, 23, 23, 8, 63, 24, 32, 14, 44,
  37, 31, 49, 27, 17, 21, 36, 26, 21, 26,
  18, 32, 33, 31, 15, 38, 28, 23, 29, 49,
  26, 20, 27, 31, 25, 24, 23, 35,
  // Hosea
  9, 25, 5, 19, 15, 11, 16, 14, 17, 15,
  11, 15, 15, 10,
  // Joel
  20, 27, 5, 21,
  // Amos
  15, 16, 15, 13, 27, 14, 17, 14, 15,
  // Obadiah
  21,
  // Jonah
  16, 11, 10, 11,
  // Micah
  16, 13, 12, 14, 14, 16, 20,
  // Nahum
  14, 14, 19,
  // Habakkuk
  17, 20, 19,
  // Zephaniah
  18, 15, 20,
  // Haggai
  15, 23,
  // Zechariah
  17, 17, 10, 14, 11, 15, 14, 23, 17, 12,
  17, 14, 9, 21,
  // Malachi
  14, 17, 24,
  // I Chronicles
  54, 55, 24, 43, 41, 66, 40, 40, 44, 14,
  47, 41, 14, 17, 29, 43, 27, 17, 19, 8,
  30, 19, 32, 31, 31, 32, 34, 21, 30,
  // II Chronicles
  18, 17, 17, 22, 14, 42, 22, 18, 31, 19,
  23, 16, 23, 14, 19, 14, 19, 34, 11, 37,
  20, 12, 21, 27, 28, 23, 9, 27, 36, 27,
  21, 33, 25, 33, 27, 23,
  // Psalms
  6, 12, 9, 9, 13, 11, 18, 10, 21, 18,
  7, 9, 6, 7, 5, 11, 15, 51, 15, 10,
  14, 32, 6, 10, 22, 12, 14, 9, 11, 13,
  25, 11, 22, 23, 28, 13, 40, 23, 14, 18,
  14, 12, 5, 27, 18, 12, 10, 15, 21, 23,
  21, 11, 7, 9, 24, 14, 12, 12, 18, 14,
  9, 13, 12, 11, 14, 20, 8, 36, 37, 6,
  24, 20, 28, 23, 11, 13, 21, 72, 13, 20,
  17, 8, 19, 13, 14, 17, 7, 19, 53, 17,
  16, 16, 5, 23, 11, 13, 12, 9, 9, 5,
  8, 29, 22, 35, 45, 48, 43, 14, 31, 7,
  10, 10, 9, 8, 18, 19, 2, 29, 176, 7,
  8, 9, 4, 8, 5, 6, 5, 6, 8, 8,
  3, 18, 3, 3, 21, 26, 9, 8, 24, 14,
  10, 8, 12, 15, 21, 10, 20, 14, 9, 6,
  // Job
  22, 13, 26, 21, 27, 30, 21, 22, 35, 22,
  20, 25, 28, 22, 35, 22, 16, 21, 29, 29,
  34, 30, 17, 25, 6, 14, 23, 28, 25, 31,
  40, 22, 33, 37, 16, 33, 24, 41, 30, 32,
  26, 17,
  // Proverbs
  33, 22, 35, 27, 23, 35, 27, 36, 18, 32,
  31, 28, 25, 35, 33, 33, 28, 24, 29, 30,
  31, 29, 35, 34, 28, 28, 27, 28, 27, 33,
  31,
  // Ruth
  22, 23, 18, 22,
  // Song of Solomon
  17, 17, 11, 16, 16, 12, 14, 14,
  // Ecclesiastes
  18, 26, 22, 17, 19, 12, 29, 17, 18, 20,
  10, 14,
  // Lamentations
  22, 22, 66, 22, 22,
  // Esther
  22, 23, 15, 17, 14, 14, 10, 17, 32, 3,
  // Daniel
  21, 49, 33, 34, 30, 29, 28, 27, 27, 21,
  45, 13,
  // Ezra
  11, 70, 13, 24, 17, 22, 28, 36, 15, 44,
  // Nehemiah
  11, 20, 38, 17, 19, 19, 72, 18, 37, 40,
  36, 47, 31
};


SWORD_NAMESPACE_END


#endif
