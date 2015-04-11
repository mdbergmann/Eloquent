/******************************************************************************
 *
 *  canon_synodal.h -	Versification data for the Synodal system
 *
 * $Id: canon_synodal.h 3240 2014-07-12 16:27:35Z scribe $
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

#ifndef CANON_SYNODAL_H
#define CANON_SYNODAL_H

SWORD_NAMESPACE_START

// Versification system: Synodal
// Book order: Gen Exod Lev Num Deut Josh Judg Ruth 1Sam 2Sam 1Kgs 2Kgs 1Chr 2Chr PrMan Ezra Neh 1Esd Tob Jdt Esth Job Ps Prov Eccl Song Wis Sir Isa Jer Lam EpJer Bar Ezek Dan Hos Joel Amos Obad Jonah Mic Nah Hab Zeph Hag Zech Mal 1Macc 2Macc 3Macc 2Esd Matt Mark Luke John Acts Jas 1Pet 2Pet 1John 2John 3John Jude Rom 1Cor 2Cor Gal Eph Phil Col 1Thess 2Thess 1Tim 2Tim Titus Phlm Heb Rev

// This versification data is based on the Synodal and Slavonic translations from rusbible.ru (of early 2009) and the BFBS Synodal database, as supplied by Konstantin Maslyuk. The three data sets were compared. The two Synodal sets were in agreement on all substantive matters. The Slavonic data set had numerous deviations from the Synodal sets, so all points of disagreement were verified against a printed Synodal translation (from the Judson Press, printed 1900) and demonstrated that the two Synodal data sets were in all cases correct (and also showed that the printed edition itself has some errors in verse numbers). In select instances, printed editions of a Polish translation and an OCS Bible, which employ very similar versifications, were also consulted.

// Some details that may not be immediately obvious:
// The Prologue to Sirach is neither a separate book nor a separate chapter of Sirach. It should be placed within the introduction of Sirach (Sir.0.0).
// The Prayer of Manasseh (PrMan) is a separate book, following 2Chr. This is primarily for referencing purposes, but also because PrMan is explicitly NOT the final chapter of 2Chr, though it is often printed as an appendix to that book.
// The first, second, and third books of Ezra or Esdras (so named according to Slavonic Orthodox tradition)  have the OSIS names Ezra, 1Esd, and 2Esd, respectively. This is due to the strange history of the books of Ezra/Esdras in the eastern & western Churches and the standard naming conventions proscribed by the SBL (which BTG & OSIS follow).
// The Epistle of Jeremiah and Baruch are two separate books.

/******************************************************************************
 * [on]tbooks_synodal - initialize static instance for all canonical
 *		 text names and chapmax
 */
struct sbook otbooks_synodal[] = {
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
  {"Prayer of Manasses", "PrMan", "PrMan", 1},
  {"Ezra", "Ezra", "Ezra", 10},
  {"Nehemiah", "Neh", "Neh", 13},
  {"I Esdras", "1Esd", "1Esd", 9},
  {"Tobit", "Tob", "Tob", 14},
  {"Judith", "Jdt", "Jdt", 16},
  {"Esther", "Esth", "Esth", 10},
  {"Job", "Job", "Job", 42},
  {"Psalms", "Ps", "Ps", 151},
  {"Proverbs", "Prov", "Prov", 31},
  {"Ecclesiastes", "Eccl", "Eccl", 12},
  {"Song of Solomon", "Song", "Song", 8},
  {"Wisdom", "Wis", "Wis", 19},
  {"Sirach", "Sir", "Sir", 51},
  {"Isaiah", "Isa", "Isa", 66},
  {"Jeremiah", "Jer", "Jer", 52},
  {"Lamentations", "Lam", "Lam", 5},
  {"Epistle of Jeremiah", "EpJer", "EpJer", 1},
  {"Baruch", "Bar", "Bar", 5},
  {"Ezekiel", "Ezek", "Ezek", 48},
  {"Daniel", "Dan", "Dan", 14},
  {"Hosea", "Hos", "Hos", 14},
  {"Joel", "Joel", "Joel", 3},
  {"Amos", "Amos", "Amos", 9},
  {"Obadiah", "Obad", "Obad", 1},
  {"Jonah", "Jonah", "Jonah", 4},
  {"Micah", "Mic", "Mic", 7},
  {"Nahum", "Nah", "Nah", 3},
  {"Habakkuk", "Hab", "Hab", 3},
  {"Zephaniah", "Zeph", "Zeph", 3},
  {"Haggai", "Hag", "Hag", 2},
  {"Zechariah", "Zech", "Zech", 14},
  {"Malachi", "Mal", "Mal", 4},
  {"I Maccabees", "1Macc", "1Macc", 16},
  {"II Maccabees", "2Macc", "2Macc", 15},
  {"III Maccabees", "3Macc", "3Macc", 7},
  {"II Esdras", "2Esd", "2Esd", 16},
  {"", "", "", 0}
};

struct sbook ntbooks_synodal[] = {
  {"Matthew", "Matt", "Matt", 28},
  {"Mark", "Mark", "Mark", 16},
  {"Luke", "Luke", "Luke", 24},
  {"John", "John", "John", 21},
  {"Acts", "Acts", "Acts", 28},
  {"James", "Jas", "Jas", 5},
  {"I Peter", "1Pet", "1Pet", 5},
  {"II Peter", "2Pet", "2Pet", 3},
  {"I John", "1John", "1John", 5},
  {"II John", "2John", "2John", 1},
  {"III John", "3John", "3John", 1},
  {"Jude", "Jude", "Jude", 1},
  {"Romans", "Rom", "Rom", 16},
  {"I Corinthians", "1Cor", "1Cor", 16},
  {"II Corinthians", "2Cor", "2Cor", 13},
  {"Galatians", "Gal", "Gal", 6},
  {"Ephesians", "Eph", "Eph", 6},
  {"Philippians", "Phil", "Phil", 4},
  {"Colossians", "Col", "Col", 4},
  {"I Thessalonians", "1Thess", "1Thess", 5},
  {"II Thessalonians", "2Thess", "2Thess", 3},
  {"I Timothy", "1Tim", "1Tim", 6},
  {"II Timothy", "2Tim", "2Tim", 4},
  {"Titus", "Titus", "Titus", 3},
  {"Philemon", "Phlm", "Phlm", 1},
  {"Hebrews", "Heb", "Heb", 13},
  {"Revelation of John", "Rev", "Rev", 22},
  {"", "", "", 0}
};

/******************************************************************************
 *	Maximum verses per chapter
 */

int vm_synodal[] = {
  // Genesis
  31, 25, 24, 26, 32, 22, 24, 22, 29, 32,
  32, 20, 18, 24, 21, 16, 27, 33, 38, 18,
  34, 24, 20, 67, 34, 35, 46, 22, 35, 43,
  55, 32, 20, 31, 29, 43, 36, 30, 23, 23,
  57, 38, 34, 34, 28, 34, 31, 22, 33, 26,
  
  // Exodus
  22, 25, 22, 31, 23, 30, 25, 32, 35, 29,
  10, 51, 22, 31, 27, 36, 16, 27, 25, 26,
  36, 31, 33, 18, 40, 37, 21, 43, 46, 38,
  18, 35, 23, 35, 35, 38, 29, 31, 43, 38,
  
  // Leviticus
  17, 16, 17, 35, 19, 30, 38, 36, 24, 20,
  47, 8, 59, 56, 33, 34, 16, 30, 37, 27,
  24, 33, 44, 23, 55, 46, 34, 
  // Numbers
  54, 34, 51, 49, 31, 27, 89, 26, 23, 36,
  35, 15, 34, 45, 41, 50, 13, 32, 22, 29,
  35, 41, 30, 25, 18, 65, 23, 31, 39, 17,
  54, 42, 56, 29, 34, 13, 
  // Deuteronomy
  46, 37, 29, 49, 33, 25, 26, 20, 29, 22,
  32, 32, 18, 29, 23, 22, 20, 22, 21, 20,
  23, 30, 25, 22, 19, 19, 26, 68, 29, 20,
  30, 52, 29, 12, 
  // Joshua
  18, 24, 17, 24, 16, 26, 26, 35, 27, 43,
  23, 24, 33, 15, 63, 10, 18, 28, 51, 9,
  45, 34, 16, 36, 
  // Judges
  36, 23, 31, 24, 31, 40, 25, 35, 57, 18,
  40, 15, 25, 20, 20, 31, 13, 31, 30, 48,
  25, 
  // Ruth
  22, 23, 18, 22, 
  // I Samuel
  28, 36, 21, 22, 12, 21, 17, 22, 27, 27,
  15, 25, 23, 52, 35, 23, 58, 30, 24, 43,
  15, 23, 28, 23, 44, 25, 12, 25, 11, 31,
  13, 
  // II Samuel
  27, 32, 39, 12, 25, 23, 29, 18, 13, 19,
  27, 31, 39, 33, 37, 23, 29, 33, 43, 26,
  22, 51, 39, 25, 
  // I Kings
  53, 46, 28, 34, 18, 38, 51, 66, 28, 29,
  43, 33, 34, 31, 34, 34, 24, 46, 21, 43,
  29, 53, 
  // II Kings
  18, 25, 27, 44, 27, 33, 20, 29, 37, 36,
  21, 21, 25, 29, 38, 20, 41, 37, 37, 21,
  26, 20, 37, 20, 30, 
  // I Chronicles
  54, 55, 24, 43, 26, 81, 40, 40, 44, 14,
  47, 40, 14, 17, 29, 43, 27, 17, 19, 8,
  30, 19, 32, 31, 31, 32, 34, 21, 30, 
  // II Chronicles
  17, 18, 17, 22, 14, 42, 22, 18, 31, 19,
  23, 16, 22, 15, 19, 14, 19, 34, 11, 37,
  20, 12, 21, 27, 28, 23, 9, 27, 36, 27,
  21, 33, 25, 33, 27, 23, 
  // Prayer of Manasses
  12, 
  // Ezra
  11, 70, 13, 24, 17, 22, 28, 36, 15, 44,
  
  // Nehemiah
  11, 20, 32, 23, 19, 19, 73, 18, 38, 39,
  36, 47, 31, 
  // I Esdras
  58, 31, 24, 63, 70, 34, 15, 92, 55, 
  // Tobit
  22, 14, 17, 21, 22, 18, 17, 21, 6, 13,
  18, 22, 18, 15, 
  // Judith
  16, 28, 10, 15, 24, 21, 32, 36, 14, 23,
  23, 20, 20, 19, 14, 25, 
  // Esther
  22, 23, 15, 17, 14, 14, 10, 17, 32, 3,
  
  // Job
  22, 13, 26, 21, 27, 30, 21, 22, 35, 22,
  20, 25, 28, 22, 35, 22, 16, 21, 29, 29,
  34, 30, 17, 25, 6, 14, 23, 28, 25, 31,
  40, 22, 33, 37, 16, 33, 24, 41, 35, 27,
  26, 17, 
  // Psalms
  6, 12, 9, 9, 13, 11, 18, 10, 39, 7,
  9, 6, 7, 5, 11, 15, 51, 15, 10, 14,
  32, 6, 10, 22, 12, 14, 9, 11, 13, 25,
  11, 22, 23, 28, 13, 40, 23, 14, 18, 14,
  12, 5, 27, 18, 12, 10, 15, 21, 23, 21,
  11, 7, 9, 24, 14, 12, 12, 18, 14, 9,
  13, 12, 11, 14, 20, 8, 36, 37, 6, 24,
  20, 28, 23, 11, 13, 21, 72, 13, 20, 17,
  8, 19, 13, 14, 17, 7, 19, 53, 17, 16,
  16, 5, 23, 11, 13, 12, 9, 9, 5, 8,
  29, 22, 35, 45, 48, 43, 14, 31, 7, 10,
  10, 9, 26, 9, 10, 2, 29, 176, 7, 8,
  9, 4, 8, 5, 6, 5, 6, 8, 8, 3,
  18, 3, 3, 21, 26, 9, 8, 24, 14, 10,
  7, 12, 15, 21, 10, 11, 9, 14, 9, 6,
  7, 
  // Proverbs
  33, 22, 35, 29, 23, 35, 27, 36, 18, 32,
  31, 28, 26, 35, 33, 33, 28, 25, 29, 30,
  31, 29, 35, 34, 28, 28, 27, 28, 27, 33,
  31, 
  // Ecclesiastes
  18, 26, 22, 17, 19, 12, 29, 17, 18, 20,
  10, 14, 
  // Song of Solomon
  16, 17, 11, 16, 16, 12, 14, 14, 
  // Wisdom
  16, 24, 19, 20, 24, 27, 30, 21, 19, 21,
  27, 28, 19, 31, 19, 29, 20, 25, 21, 
  // Sirach
  30, 18, 31, 35, 18, 37, 39, 22, 23, 34,
  34, 18, 32, 27, 20, 31, 31, 33, 28, 31,
  31, 31, 37, 37, 29, 27, 33, 30, 31, 27,
  37, 25, 33, 26, 23, 29, 34, 39, 42, 32,
  29, 26, 36, 27, 31, 23, 31, 28, 18, 31,
  38, 
  // Isaiah
  31, 22, 25, 6, 30, 13, 25, 22, 21, 34,
  16, 6, 22, 32, 9, 14, 14, 7, 25, 6,
  17, 25, 18, 23, 12, 21, 13, 29, 24, 33,
  9, 20, 24, 17, 10, 22, 38, 22, 8, 31,
  29, 25, 28, 28, 25, 13, 15, 22, 26, 11,
  23, 15, 12, 17, 13, 12, 21, 14, 21, 22,
  11, 12, 19, 12, 25, 24, 
  // Jeremiah
  19, 37, 25, 31, 31, 30, 34, 22, 26, 25,
  23, 17, 27, 22, 21, 21, 27, 23, 15, 18,
  14, 30, 40, 10, 38, 24, 22, 17, 32, 24,
  40, 44, 26, 22, 19, 32, 21, 28, 18, 16,
  18, 22, 13, 30, 5, 28, 7, 47, 39, 46,
  64, 34, 
  // Lamentations
  22, 22, 66, 22, 22, 
  // Epistle of Jeremiah
  72, 
  // Baruch
  22, 35, 38, 37, 9, 
  // Ezekiel
  28, 10, 27, 17, 17, 14, 27, 18, 11, 22,
  25, 28, 23, 23, 8, 63, 24, 32, 14, 49,
  32, 31, 49, 27, 17, 21, 36, 26, 21, 26,
  18, 32, 33, 31, 15, 38, 28, 23, 29, 49,
  26, 20, 27, 31, 25, 24, 23, 35, 
  // Daniel
  21, 49, 100, 34, 31, 28, 28, 27, 27, 21,
  45, 13, 64, 42, 
  // Hosea
  11, 23, 5, 19, 15, 11, 16, 14, 17, 15,
  12, 14, 15, 10, 
  // Joel
  20, 32, 21, 
  // Amos
  15, 16, 15, 13, 27, 14, 17, 14, 15, 
  // Obadiah
  21, 
  // Jonah
  16, 11, 10, 11, 
  // Micah
  16, 13, 12, 13, 15, 16, 20, 
  // Nahum
  15, 13, 19, 
  // Habakkuk
  17, 20, 19, 
  // Zephaniah
  18, 15, 20, 
  // Haggai
  15, 23, 
  // Zechariah
  21, 13, 10, 14, 11, 15, 14, 23, 17, 12,
  17, 14, 9, 21, 
  // Malachi
  14, 17, 18, 6, 
  // I Maccabees
  64, 70, 60, 61, 68, 63, 50, 32, 73, 89,
  74, 53, 53, 49, 41, 24, 
  // II Maccabees
  36, 33, 40, 50, 27, 31, 42, 36, 29, 38,
  38, 45, 26, 46, 39, 
  // III Maccabees
  25, 24, 22, 16, 36, 37, 20, 
  // II Esdras
  40, 48, 36, 52, 56, 59, 70, 63, 47, 60,
  46, 51, 58, 48, 63, 78, 
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
  51, 25, 36, 54, 47, 71, 53, 59, 41, 42,
  57, 50, 38, 31, 27, 33, 26, 40, 42, 31,
  25, 
  // Acts
  26, 47, 26, 37, 42, 15, 60, 40, 43, 48,
  30, 25, 52, 28, 41, 40, 34, 28, 40, 38,
  40, 30, 35, 27, 27, 32, 44, 31, 
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
  // Romans
  32, 29, 31, 25, 21, 23, 25, 39, 33, 21,
  36, 21, 14, 26, 33, 24, 
  // I Corinthians
  31, 16, 23, 21, 13, 20, 40, 13, 27, 33,
  34, 31, 13, 40, 58, 24, 
  // II Corinthians
  24, 17, 18, 18, 21, 18, 16, 24, 15, 18,
  32, 21, 13, 
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
  // Revelation of John
  20, 29, 22, 11, 14, 17, 17, 13, 21, 11,
  19, 17, 18, 20, 8, 21, 18, 24, 21, 15,
  27, 21
};

unsigned char mappings_synodal[] = {
    'P', 'r', 'A', 'z', 'a', 'r', 0,
    'S', 'u', 's', 0,
    'B', 'e', 'l', 0,
    0,
    3,   14,  55,  0,   14,  55,  56,
    4,   13,  1,   0,   12,  16,  0,
    4,   13,  2,   0,   13,  1,   0,
    4,   30,  1,   0,   29,  40,  0,
    4,   30,  2,   0,   30,  1,   0,
    6,   5,   16,  0,   6,   1,   0,
    6,   6,   1,   0,   6,   2,   0,
    9,   24,  1,   0,   23,  29,  0,
    9,   24,  2,   0,   24,  1,   0,
    22,  39,  31,  0,   40,  1,   0,
    22,  40,  1,   0,   40,  6,   0,
    22,  40,  20,  0,   41,  1,   0,
    22,  41,  1,   0,   41,  9,   0,
    23,  3,   1,   0,   3,   0,   0,
    23,  4,   1,   0,   4,   0,   0,
    23,  5,   1,   0,   5,   0,   0,
    23,  6,   1,   0,   6,   0,   0,
    23,  7,   1,   0,   7,   0,   0,
    23,  8,   1,   0,   8,   0,   0,
    23,  9,   1,   0,   9,   0,   0,
    23,  9,   22,  0,   10,  1,   0,
    23,  10,  1,   0,   11,  0,   1,
    23,  11,  1,   0,   12,  0,   0,
    23,  12,  1,   0,   13,  0,   0,
    23,  12,  6,   0,   13,  5,   6,
    23,  13,  1,   0,   14,  0,   1,
    23,  14,  1,   0,   15,  0,   1,
    23,  15,  1,   0,   16,  0,   1,
    23,  16,  1,   0,   17,  0,   1,
    23,  17,  1,   0,   18,  0,   0,
    23,  18,  1,   0,   19,  0,   0,
    23,  19,  1,   0,   20,  0,   0,
    23,  20,  1,   0,   21,  0,   0,
    23,  21,  1,   0,   22,  0,   0,
    23,  22,  1,   0,   23,  0,   1,
    23,  23,  1,   0,   24,  0,   1,
    23,  24,  1,   0,   25,  0,   1,
    23,  25,  1,   0,   26,  0,   1,
    23,  26,  1,   0,   27,  0,   1,
    23,  27,  1,   0,   28,  0,   1,
    23,  28,  1,   0,   29,  0,   1,
    23,  29,  1,   0,   30,  0,   0,
    23,  30,  1,   0,   31,  0,   0,
    23,  31,  1,   0,   32,  0,   1,
    23,  32,  1,   0,   33,  0,   1,
    23,  33,  1,   0,   34,  0,   0,
    23,  34,  1,   0,   35,  0,   1,
    23,  35,  1,   0,   36,  0,   0,
    23,  36,  1,   0,   37,  0,   1,
    23,  37,  1,   0,   38,  0,   0,
    23,  38,  1,   0,   39,  0,   0,
    23,  39,  1,   0,   40,  0,   0,
    23,  40,  1,   0,   41,  0,   0,
    23,  41,  1,   0,   42,  0,   0,
    23,  42,  0,   0,   43,  0,   0,
    23,  43,  1,   0,   44,  0,   0,
    23,  44,  1,   0,   45,  0,   0,
    23,  45,  1,   0,   46,  0,   0,
    23,  46,  1,   0,   47,  0,   0,
    23,  47,  1,   0,   48,  0,   0,
    23,  48,  1,   0,   49,  0,   0,
    23,  49,  0,   0,   50,  0,   0,
    23,  50,  1,   2,   51,  0,   0,
    23,  51,  1,   2,   52,  0,   0,
    23,  52,  1,   0,   53,  0,   0,
    23,  53,  1,   2,   54,  0,   0,
    23,  54,  1,   0,   55,  0,   0,
    23,  55,  1,   0,   56,  0,   0,
    23,  56,  1,   0,   57,  0,   0,
    23,  57,  1,   0,   58,  0,   0,
    23,  58,  1,   0,   59,  0,   0,
    23,  59,  1,   2,   60,  0,   0,
    23,  60,  1,   0,   61,  0,   0,
    23,  61,  1,   0,   62,  0,   0,
    23,  62,  1,   0,   63,  0,   0,
    23,  63,  1,   0,   64,  0,   0,
    23,  64,  1,   0,   65,  0,   0,
    23,  65,  1,   0,   66,  0,   1,
    23,  66,  1,   0,   67,  0,   0,
    23,  67,  1,   0,   68,  0,   0,
    23,  68,  1,   0,   69,  0,   0,
    23,  69,  1,   0,   70,  0,   0,
    23,  70,  0,   0,   71,  0,   0,
    23,  71,  0,   0,   72,  0,   0,
    23,  72,  0,   0,   73,  0,   0,
    23,  73,  0,   0,   74,  0,   0,
    23,  74,  1,   0,   75,  0,   0,
    23,  75,  1,   0,   76,  0,   0,
    23,  76,  1,   0,   77,  0,   0,
    23,  77,  0,   0,   78,  0,   0,
    23,  78,  0,   0,   79,  0,   0,
    23,  79,  1,   0,   80,  0,   0,
    23,  80,  1,   0,   81,  0,   0,
    23,  81,  0,   0,   82,  0,   0,
    23,  82,  1,   0,   83,  0,   0,
    23,  83,  1,   0,   84,  0,   0,
    23,  84,  1,   0,   85,  0,   0,
    23,  85,  0,   0,   86,  0,   0,
    23,  86,  1,   0,   87,  0,   0,
    23,  86,  2,   0,   87,  1,   2,
    23,  87,  1,   0,   88,  0,   0,
    23,  88,  1,   0,   89,  0,   0,
    23,  89,  1,   0,   90,  0,   0,
    23,  89,  6,   0,   90,  5,   6,
    23,  90,  0,   0,   91,  0,   0,
    23,  91,  1,   0,   92,  0,   0,
    23,  92,  0,   0,   93,  0,   0,
    23,  93,  0,   0,   94,  0,   0,
    23,  94,  0,   0,   95,  0,   0,
    23,  95,  0,   0,   96,  0,   0,
    23,  96,  0,   0,   97,  0,   0,
    23,  97,  0,   0,   98,  0,   0,
    23,  98,  0,   0,   99,  0,   0,
    23,  99,  0,   0,   100, 0,   0,
    23,  100, 0,   0,   101, 0,   0,
    23,  101, 1,   0,   102, 0,   0,
    23,  102, 0,   0,   103, 0,   0,
    23,  103, 0,   0,   104, 0,   0,
    23,  104, 0,   0,   105, 0,   0,
    23,  105, 0,   0,   106, 0,   0,
    23,  106, 0,   0,   107, 0,   0,
    23,  107, 1,   0,   108, 0,   0,
    23,  108, 0,   0,   109, 0,   0,
    23,  109, 0,   0,   110, 0,   0,
    23,  110, 0,   0,   111, 0,   0,
    23,  111, 0,   1,   112, 1,   0,
    23,  112, 0,   1,   113, 1,   0,
    23,  113, 0,   0,   114, 0,   0,
    23,  113, 9,   0,   115, 1,   0,
    23,  114, 0,   0,   116, 0,   0,
    23,  115, 1,   0,   116, 10,  0,
    23,  116, 0,   0,   117, 0,   0,
    23,  117, 0,   0,   118, 0,   0,
    23,  118, 0,   0,   119, 0,   0,
    23,  119, 0,   0,   120, 0,   0,
    23,  120, 0,   0,   121, 0,   0,
    23,  121, 0,   0,   122, 0,   0,
    23,  122, 0,   0,   123, 0,   0,
    23,  123, 0,   0,   124, 0,   0,
    23,  124, 0,   0,   125, 0,   0,
    23,  125, 0,   0,   126, 0,   0,
    23,  126, 0,   0,   127, 0,   0,
    23,  127, 0,   0,   128, 0,   0,
    23,  128, 0,   0,   129, 0,   0,
    23,  129, 0,   0,   130, 0,   0,
    23,  130, 0,   0,   131, 0,   0,
    23,  131, 0,   0,   132, 0,   0,
    23,  132, 0,   0,   133, 0,   0,
    23,  133, 0,   0,   134, 0,   0,
    23,  134, 0,   1,   135, 1,   0,
    23,  135, 0,   0,   136, 0,   0,
    23,  136, 0,   0,   137, 0,   0,
    23,  137, 0,   0,   138, 0,   0,
    23,  138, 0,   0,   139, 0,   0,
    23,  139, 1,   0,   140, 0,   0,
    23,  140, 0,   0,   141, 0,   0,
    23,  141, 0,   0,   142, 0,   0,
    23,  142, 0,   0,   143, 0,   0,
    23,  143, 0,   0,   144, 0,   0,
    23,  144, 0,   0,   145, 0,   0,
    23,  145, 0,   1,   146, 1,   0,
    23,  146, 0,   1,   147, 1,   0,
    23,  147, 1,   0,   147, 12,  0,
    23,  148, 0,   1,   148, 1,   0,
    23,  149, 0,   1,   149, 1,   0,
    23,  150, 0,   1,   150, 1,   0,
    25,  4,   17,  0,   5,   1,   0,
    25,  5,   1,   0,   5,   2,   0,
    26,  1,   0,   0,   1,   1,   0,
    26,  7,   1,   0,   6,   13,  0,
    26,  7,   2,   0,   7,   1,   0,
    79,  3,   24,  0,   1,   1,   0,   35,
    79,  3,   52,  0,   1,   29,  30,  35,
    35,  3,   91,  0,   3,   24,  0,
    35,  3,   98,  0,   4,   1,   0,
    35,  4,   1,   0,   4,   4,   0,
    80,  13,  1,   0,   1,   1,   0,   35,
    81,  14,  1,   0,   1,   1,   0,   35,
    36,  14,  1,   0,   13,  16,  0,
    36,  14,  2,   0,   14,  1,   0,
    40,  2,   1,   0,   1,   17,  0,
    40,  2,   2,   0,   2,   1,   0,
    56,  19,  40,  0,   19,  40,  41,
    64,  14,  24,  0,   16,  25,  0,
    66,  13,  12,  0,   13,  12,  13,
    62,  1,   14,  15,  1,   14,  0,
    0
};

SWORD_NAMESPACE_END


#endif
