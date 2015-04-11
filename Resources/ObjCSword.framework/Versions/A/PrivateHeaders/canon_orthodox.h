/******************************************************************************
 *
 *  canon_orthodox.h -	Versification data for the Orthodox system
 *
 * $Id: canon_orthodox.h 2936 2013-08-02 18:00:19Z chrislit $
 *
 * Copyright 2013 CrossWire Bible Society (http://www.crosswire.org)
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

#ifndef CANON_ORTHODOX_H
#define CANON_ORTHODOX_H

SWORD_NAMESPACE_START


// Versification system: Orthodox
// Book order: Gen Exod Lev Num Deut Josh Judg Ruth 1Sam 2Sam 1Kgs 2Kgs 1Chr 2Chr 1Esd Ezra Neh Tob Jdt Esth 1Macc 2Macc 3Macc Ps PrMan Job Prov Eccl Song Wis Sir Hos Amos Mic Joel Obad Jonah Nah Hab Zeph Hag Zech Mal Isa Jer Bar Lam EpJer Ezek Sus Dan Bel 4Macc Matt Mark Luke John Acts Rom 1Cor 2Cor Gal Eph Phil Col 1Thess 2Thess 1Tim 2Tim Titus Phlm Heb Jas 1Pet 2Pet 1John 2John 3John Jude Rev

// This versification system is based on the LXX versification system, q.v. for more information on the method of its compilation.
// However, this versification system differs from the LXX system in that the book order follows that seen in modern Orthodox Bibles and books seen in some editions of the LXX but absent from modern Orthodox Bibles have been omitted.


/******************************************************************************
 * [on]tbooks_orthodox - initialize static instance for all canonical
 *		 text names and chapmax
 */
struct sbook otbooks_orthodox[] = {
  {"Genesis", "Gen", "Gen", 50},
  {"Exodus", "Exod", "Exod", 40},
  {"Leviticus", "Lev", "Lev", 27},
  {"Numbers", "Num", "Num", 36},
  {"Deuteronomy", "Deut", "Deut", 34},
  {"Joshua", "Josh", "Josh", 24},
  {"Judges", "Judg", "Judg", 21},
  {"Ruth", "Ruth", "Ruth", 4},
  {"I Samuel", "1Sam", "1Sam", 31},
  {"II Samuel", "2Sam", "2Sam", 24},
  {"I Kings", "1Kgs", "1Kgs", 22},
  {"II Kings", "2Kgs", "2Kgs", 25},
  {"I Chronicles", "1Chr", "1Chr", 29},
  {"II Chronicles", "2Chr", "2Chr", 36},
  {"I Esdras", "1Esd", "1Esd", 9},
  {"Ezra", "Ezra", "Ezra", 10},
  {"Nehemiah", "Neh", "Neh", 13},
  {"Tobit", "Tob", "Tob", 14},
  {"Judith", "Jdt", "Jdt", 16},
  {"Esther", "Esth", "Esth", 16},
  {"I Maccabees", "1Macc", "1Macc", 16},
  {"II Maccabees", "2Macc", "2Macc", 15},
  {"III Maccabees", "3Macc", "3Macc", 7},
  {"Psalms", "Ps", "Ps", 151},
  {"Prayer of Manasses", "PrMan", "PrMan", 1},
  {"Job", "Job", "Job", 42},
  {"Proverbs", "Prov", "Prov", 31},
  {"Ecclesiastes", "Eccl", "Eccl", 12},
  {"Song of Solomon", "Song", "Song", 8},
  {"Wisdom", "Wis", "Wis", 19},
  {"Sirach", "Sir", "Sir", 51},
  {"Hosea", "Hos", "Hos", 14},
  {"Amos", "Amos", "Amos", 9},
  {"Micah", "Mic", "Mic", 7},
  {"Joel", "Joel", "Joel", 4},
  {"Obadiah", "Obad", "Obad", 1},
  {"Jonah", "Jonah", "Jonah", 4},
  {"Nahum", "Nah", "Nah", 3},
  {"Habakkuk", "Hab", "Hab", 3},
  {"Zephaniah", "Zeph", "Zeph", 3},
  {"Haggai", "Hag", "Hag", 2},
  {"Zechariah", "Zech", "Zech", 14},
  {"Malachi", "Mal", "Mal", 4},
  {"Isaiah", "Isa", "Isa", 66},
  {"Jeremiah", "Jer", "Jer", 52},
  {"Baruch", "Bar", "Bar", 5},
  {"Lamentations", "Lam", "Lam", 5},
  {"Epistle of Jeremiah", "EpJer", "EpJer", 1},
  {"Ezekiel", "Ezek", "Ezek", 48},
  {"Susanna", "Sus", "Sus", 1},
  {"Daniel", "Dan", "Dan", 12},
  {"Bel and the Dragon", "Bel", "Bel", 1},
  {"IV Maccabees", "4Macc", "4Macc", 18},
  {"", "", "", 0}
};

// for ntbooks_orthodox, use ntbooks

/******************************************************************************
 *	Maximum verses per chapter
 */
int vm_orthodox[] = {
  // Genesis
  31, 25, 25, 26, 32, 23, 24, 22, 29, 32,
  32, 20, 18, 24, 21, 16, 27, 33, 39, 18,
  34, 24, 20, 67, 34, 35, 46, 22, 35, 43,
  55, 33, 20, 31, 29, 44, 36, 30, 23, 23,
  57, 39, 34, 34, 28, 34, 31, 22, 33, 26,
  // Exodus
  22, 25, 22, 31, 23, 30, 29, 32, 35, 29,
  10, 51, 22, 31, 27, 36, 16, 27, 25, 26,
  37, 31, 33, 18, 40, 37, 21, 43, 46, 38,
  18, 35, 23, 35, 35, 40, 21, 29, 23, 38,
  // Leviticus
  17, 16, 17, 35, 26, 40, 38, 36, 24, 20,
  47, 8, 59, 57, 33, 34, 16, 30, 37, 27,
  24, 33, 44, 23, 55, 46, 34,
  // Numbers
  54, 34, 51, 49, 31, 27, 89, 26, 23, 36,
  35, 16, 34, 45, 41, 50, 28, 32, 22, 29,
  35, 41, 30, 25, 18, 65, 23, 31, 40, 17,
  54, 42, 56, 29, 34, 13,
  // Deuteronomy
  46, 37, 29, 49, 33, 25, 26, 20, 29, 22,
  32, 32, 19, 29, 23, 22, 20, 22, 21, 20,
  23, 30, 26, 24, 19, 19, 27, 69, 29, 20,
  30, 52, 29, 12,
  // Joshua
  18, 24, 17, 24, 16, 27, 26, 35, 33, 43,
  23, 24, 33, 15, 64, 10, 18, 28, 54, 9,
  49, 34, 16, 36,
  // Judges
  36, 23, 31, 24, 32, 40, 25, 35, 57, 18,
  40, 15, 25, 20, 20, 31, 13, 32, 30, 48,
  25,
  // Ruth
  22, 23, 18, 22,
  // I Samuel
  28, 36, 21, 22, 12, 21, 17, 22, 27, 27,
  15, 25, 23, 52, 35, 23, 58, 30, 24, 43,
  16, 23, 29, 23, 44, 25, 12, 25, 11, 32,
  13,
  // II Samuel
  27, 32, 39, 12, 26, 23, 29, 18, 13, 19,
  27, 31, 39, 33, 37, 23, 29, 33, 44, 26,
  22, 51, 41, 25,
  // I Kings
  53, 71, 39, 34, 32, 38, 51, 66, 28, 33,
  44, 54, 34, 31, 34, 42, 24, 46, 21, 43,
  43, 54,
  // II Kings
  22, 25, 27, 44, 27, 35, 20, 29, 37, 36,
  21, 22, 25, 29, 38, 20, 41, 37, 37, 21,
  26, 20, 37, 20, 30,
  // I Chronicles
  54, 55, 24, 43, 41, 81, 40, 40, 44, 14,
  47, 41, 14, 17, 29, 43, 27, 17, 19, 8,
  30, 19, 32, 31, 31, 32, 34, 21, 30,
  // II Chronicles
  18, 18, 17, 23, 14, 42, 22, 18, 31, 19,
  23, 16, 23, 15, 19, 14, 19, 34, 11, 37,
  20, 12, 21, 27, 28, 23, 9, 27, 36, 27,
  21, 33, 25, 33, 31, 31,
  // I Esdras
  58, 30, 24, 63, 73, 34, 15, 96, 55,
  // Ezra
  11, 70, 13, 24, 17, 22, 28, 36, 15, 44,
  // Nehemiah
  11, 20, 37, 23, 19, 19, 73, 18, 38, 40,
  36, 47, 31,
  // Tobit
  22, 14, 17, 21, 23, 19, 18, 21, 6, 14,
  19, 22, 19, 15,
  // Judith
  16, 28, 10, 15, 24, 21, 32, 36, 14, 23,
  23, 20, 20, 19, 14, 25,
  // Esther
  22, 23, 15, 17, 22, 14, 10, 17, 35, 13,
  17, 7, 30, 19, 24, 24,
  // I Maccabees
  64, 70, 60, 61, 68, 63, 50, 32, 73, 89,
  74, 53, 54, 49, 41, 24,
  // II Maccabees
  36, 32, 40, 50, 27, 31, 42, 36, 29, 38,
  38, 46, 26, 46, 39,
  // III Maccabees
  29, 33, 30, 21, 51, 41, 23,
  // Psalms
  6, 13, 9, 9, 13, 11, 18, 10, 40, 8,
  9, 6, 7, 6, 11, 15, 51, 15, 10, 14,
  32, 6, 10, 22, 12, 14, 9, 11, 13, 25,
  11, 22, 23, 28, 13, 40, 23, 14, 18, 14,
  12, 6, 27, 18, 12, 10, 15, 21, 23, 21,
  11, 7, 9, 24, 14, 12, 12, 19, 14, 9,
  13, 12, 11, 14, 20, 8, 36, 37, 7, 24,
  20, 28, 23, 11, 13, 21, 72, 13, 20, 17,
  8, 19, 13, 14, 17, 7, 19, 53, 17, 16,
  16, 5, 23, 11, 13, 12, 9, 9, 5, 8,
  29, 22, 36, 45, 48, 43, 14, 31, 7, 10,
  10, 9, 26, 18, 19, 2, 29, 176, 7, 8,
  9, 4, 8, 5, 7, 5, 6, 8, 8, 3,
  18, 3, 3, 21, 26, 9, 8, 24, 15, 10,
  8, 12, 15, 22, 10, 11, 20, 14, 9, 6,
  7,
  // Prayer of Manasses
  15,
  // Job
  22, 18, 26, 21, 27, 30, 22, 22, 35, 22,
  20, 25, 28, 22, 35, 23, 16, 21, 29, 29,
  34, 30, 17, 25, 6, 14, 23, 28, 25, 31,
  40, 22, 33, 37, 16, 34, 24, 41, 35, 32,
  34, 22,
  // Proverbs
  35, 23, 38, 28, 23, 40, 28, 37, 25, 33,
  31, 31, 27, 36, 38, 33, 30, 24, 29, 30,
  31, 31, 36, 77, 31, 29, 29, 30, 49, 35,
  31,
  // Ecclesiastes
  18, 26, 22, 17, 20, 12, 30, 17, 18, 20,
  10, 14,
  // Song of Solomon
  17, 17, 11, 16, 17, 13, 14, 15,
  // Wisdom
  16, 25, 19, 20, 24, 27, 30, 21, 19, 21,
  27, 27, 19, 31, 19, 29, 21, 25, 22,
  // Sirach
  30, 18, 31, 31, 15, 37, 36, 19, 18, 31,
  34, 18, 26, 27, 20, 30, 32, 33, 31, 32,
  28, 27, 28, 34, 26, 29, 30, 26, 28, 40,
  31, 26, 33, 31, 26, 31, 31, 35, 35, 30,
  27, 27, 33, 24, 26, 20, 25, 25, 16, 29,
  30,
  // Hosea
  11, 25, 5, 19, 15, 12, 16, 14, 17, 15,
  12, 15, 16, 10,
  // Amos
  15, 16, 15, 13, 27, 15, 17, 14, 15,
  // Micah
  16, 13, 12, 14, 15, 16, 20,
  // Joel
  20, 32, 21, 21,
  // Obadiah
  21,
  // Jonah
  17, 11, 10, 11,
  // Nahum
  15, 14, 19,
  // Habakkuk
  17, 20, 19,
  // Zephaniah
  18, 15, 21,
  // Haggai
  15, 24,
  // Zechariah
  21, 17, 11, 14, 11, 15, 14, 23, 17, 12,
  17, 14, 9, 21,
  // Malachi
  14, 17, 24, 6,
  // Isaiah
  31, 22, 26, 6, 30, 13, 25, 23, 21, 34,
  16, 6, 22, 32, 9, 14, 14, 7, 25, 6,
  17, 25, 18, 23, 12, 21, 13, 29, 24, 33,
  9, 20, 24, 17, 10, 22, 38, 22, 8, 31,
  29, 25, 28, 28, 26, 13, 15, 22, 26, 11,
  23, 15, 12, 17, 13, 12, 21, 14, 21, 22,
  11, 12, 20, 12, 25, 24,
  // Jeremiah
  19, 37, 25, 31, 31, 30, 34, 23, 26, 25,
  23, 17, 27, 22, 21, 21, 27, 23, 15, 18,
  14, 30, 42, 10, 39, 28, 46, 64, 31, 33,
  47, 44, 24, 22, 19, 32, 24, 40, 44, 26,
  22, 22, 32, 30, 28, 28, 16, 44, 38, 46,
  63, 34,
  // Baruch
  22, 35, 38, 37, 9,
  // Lamentations
  22, 22, 66, 22, 22,
  // Epistle of Jeremiah
  73,
  // Ezekiel
  28, 13, 27, 17, 17, 14, 27, 18, 11, 22,
  25, 28, 23, 23, 8, 63, 24, 32, 14, 49,
  37, 31, 49, 27, 17, 21, 36, 26, 21, 26,
  18, 32, 33, 31, 15, 38, 28, 23, 29, 49,
  26, 20, 27, 31, 25, 24, 23, 35,
  // Susanna
  64,
  // Daniel
  21, 49, 100, 37, 31, 29, 28, 27, 27, 21,
  45, 13,
  // Bel and the Dragon
  42,
  // IV Maccabees
  35, 24, 21, 26, 38, 35, 25, 29, 32, 21,
  27, 20, 27, 20, 32, 25, 24, 24,
  // Matthew
  25, 23, 17, 25, 48, 34, 29, 34, 38, 42,
  30, 50, 58, 36, 39, 28, 27, 35, 30, 34,
  46, 46, 39, 51, 46, 75, 66, 20,
  // Mark
  45, 28, 35, 41, 43, 56, 37, 38, 50, 52,
  33, 44, 37, 72, 47, 20,
  // Luke
  80, 52, 38, 44, 39, 49, 50, 56, 62, 42,
  54, 59, 35, 35, 32, 31, 37, 43, 48, 47,
  38, 71, 56, 53,
  // John
  52, 25, 36, 54, 47, 71, 53, 59, 41, 42,
  57, 50, 38, 31, 27, 33, 26, 40, 42, 31,
  25,
  // Acts
  26, 47, 26, 37, 42, 15, 60, 40, 43, 48,
  30, 25, 52, 28, 41, 40, 34, 28, 41, 38,
  40, 30, 35, 27, 27, 32, 44, 31,
  // Romans
  32, 29, 31, 25, 21, 23, 25, 39, 33, 21,
  36, 21, 14, 26, 33, 27,
  // I Corinthians
  31, 16, 23, 21, 13, 20, 40, 13, 27, 33,
  34, 31, 13, 40, 58, 24,
  // II Corinthians
  24, 17, 18, 18, 21, 18, 16, 24, 15, 18,
  33, 21, 14,
  // Galatians
  24, 21, 29, 31, 26, 18,
  // Ephesians
  23, 22, 21, 32, 33, 24,
  // Philippians
  30, 30, 21, 23,
  // Colossians
  29, 23, 25, 18,
  // I Thessalonians
  10, 20, 13, 18, 28,
  // II Thessalonians
  12, 17, 18,
  // I Timothy
  20, 15, 16, 16, 25, 21,
  // II Timothy
  18, 26, 17, 22,
  // Titus
  16, 15, 15,
  // Philemon
  25,
  // Hebrews
  14, 18, 19, 16, 14, 20, 28, 13, 28, 39,
  40, 29, 25,
  // James
  27, 26, 18, 17, 20,
  // I Peter
  25, 25, 22, 19, 14,
  // II Peter
  21, 22, 18,
  // I John
  10, 29, 24, 21, 21,
  // II John
  13,
  // III John
  15,
  // Jude
  25,
  // Revelation of John
  20, 29, 22, 11, 14, 17, 17, 13, 21, 11,
  19, 18, 18, 20, 9, 21, 18, 24, 21, 15,
  27, 21
};


SWORD_NAMESPACE_END


#endif
