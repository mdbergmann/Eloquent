/******************************************************************************
 * osisbook.h - Canonical text information to be included by VerseKey2.cpp
 *
 * $Id: osisbook.h 1688 2005-01-01 04:42:26Z scribe $
 *
 * Copyright 2004 CrossWire Bible Society (http://www.crosswire.org)
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
 * [on]tbooks - initialize static instance for all canonical text names
 *		and chapmax
 *	taken from http://whi.wts.edu/OSIS/Projects/Markup/specs/BibleBookNames.html
 */

#define TESTAMENT_HEADING 255
//#define NTOFFSET 24115  //24115 is offset to start of NT
#if 0
#define OSISBMAX 68
#endif
#define BUILTINABBREVCNT 195
 
struct sbook2 VerseKey2::osisbooks[] = {
//Module Heading
{"Module Heading", "ZZZ"},//0
//Old Testament
{"Old Testament", "OT"},//1
{"Genesis", "Gen"},
{"Exodus", "Exod"},
{"Leviticus", "Lev"},
{"Numbers", "Num"},
{"Deuteronomy", "Deut"},
{"Joshua", "Josh"},
{"Judges", "Judg"},
{"Ruth", "Ruth"},
{"1 Samuel", "1Sam"},//10
{"2 Samuel", "2Sam"},
{"1 Kings", "1Kgs"},
{"2 Kings", "2Kgs"},
{"1 Chronicles", "1Chr"},
{"2 Chronicles", "2Chr"},
{"Ezra", "Ezra"},
{"Nehemiah", "Neh"},
{"Esther", "Esth"},
{"Job", "Job"},
{"Psalms", "Ps"},//20
{"Proverbs", "Prov"},
{"Ecclesiastes", "Eccl"},		// 	Qohelot
{"Song of Solomon", "Song"}, 	// 	Canticle of Canticles
{"Isaiah", "Isa"},
{"Jeremiah", "Jer"},
{"Lamentations", "Lam"},
{"Ezekiel", "Ezek"},
{"Daniel", "Dan"},
{"Hosea", "Hos"},
{"Joel", "Joel"},//30
{"Amos", "Amos"},
{"Obadiah", "Obad"},
{"Jonah", "Jonah"},
{"Micah", "Mic"},
{"Nahum", "Nah"},
{"Habakkuk", "Hab"},
{"Zephaniah", "Zeph"},
{"Haggai", "Hag"},
{"Zechariah", "Zech"},
{"Malachi", "Mal"},//40

//Roman Catholic Deuterocanon
{"Deuterocanon", "DC"},//41
{"Tobit", "Tob"},//(70)
{"Judith", "Jdt"},
{"Wisdom", "Wis"},			// 		Wisdom of Solomon
{"Sirach", "Sir"},			//  	Ecclesiasticus
{"Baruch", "Bar"},			//  	1 Baruch
{"Letter of Jeremiah", "EpJer"},//(75)
{"1 Esdras", "1Esd"},		//  	3Ezra 	Esdras A
{"2 Esdras", "2Esd"},		// 		4Ezra 	Esdras B
{"1 Maccabees", "1Macc"},//(78)50
{"2 Maccabees", "2Macc"},//51
 
 
//Septuagint
{"3 Maccabees", "3Macc"},//(80)52
{"4 Maccabees", "4Macc"},
{"Odes of Solomon", "OdesSol"},
{"Psalms of Solomon", "PssSol"},//55
 
 
//Vulgate
{"Epistle to the Laodiceans", "EpLao"},//(84)56
 
 
//Orthodox Canon
{"1 Enoch", "1En"},//(85)57		// 	Ethiopic Apocalypse of Enoch
{"Jubilees", "Jub"},//(86)58
 
 
//Protestant Apocrypha
{"Apocrypha", "Apoc"},//(87)59
{"Additions to Esther", "AddEsth"},
{"Prayer of Azariah", "PrAzar"},	// 	Song of the Three Children
{"Susanna", "Sus"},//(90)
{"Bel and the Dragon", "Bel"},
{"Prayer of Manasses", "PrMan"},
{"Psalm 151", "Ps151"},//(93)65
 
 
//New Testament
{"New Testament", "NT"},//66
{"Matthew", "Matt"},
{"Mark", "Mark"},
{"Luke", "Luke"},
{"John", "John"},//70
{"Acts", "Acts"},
{"Romans", "Rom"},
{"1 Corinthians", "1Cor"},
{"2 Corinthians", "2Cor"},
{"Galatians", "Gal"},//(50)
{"Ephesians", "Eph"},
{"Philippians", "Phil"},
{"Colossians", "Col"},
{"1 Thessalonians", "1Thess"},
{"2 Thessalonians", "2Thess"},//80
{"1 Timothy", "1Tim"},
{"2 Timothy", "2Tim"},
{"Titus", "Titus"},
{"Philemon", "Phlm"},
{"Hebrews", "Heb"},//(60)
{"James", "Jas"},
{"1 Peter", "1Pet"},
{"2 Peter", "2Pet"},
{"1 John", "1John"},
{"2 John", "2John"},//90
{"3 John", "3John"},
{"Jude", "Jude"},
{"Revelation", "Rev"}//(68)93
 

};

/* the en abbrevs will be in a conf file as well
*/

/*
const struct abbrev2
  VerseKey2::builtin_abbrevs[] = {
  {"1 C", 48},			//   1 Corinthians
  {"1 CHRONICLES", 14},		//   1 Chronicles
  {"1 CORINTHIANS", 48},	//   1 Corinthians
  {"1 JN", 64},			//    1 John
  {"1 JOHN", 64},		//    1 John
  {"1 KGS", 12},		//    1 Kings
  {"1 KINGS", 12},		//    1 Kings
  {"1 PETER", 62},		//    1 Peter
  {"1 PTR", 62},		//    1 Peter
  {"1 SAMUEL", 10},		//    1 Samuel
  {"1 THESSALONIANS", 54},	//   1 Thessalonians
  {"1 TIMOTHY", 56},		//   1 Timothy
  {"1C", 48},			//   1 Corinthians
  {"1CHRONICLES", 14},		//   1 Chronicles
  {"1CORINTHIANS", 48},		//   1 Corinthians
  {"1JN", 64},			//    1 John       
  {"1JOHN", 64},		//    1 John
  {"1KGS", 12},			// 1 Kings
  {"1KINGS", 12},		//    1 Kings
  {"1PETER", 62},		//    1 Peter
  {"1PTR", 62},			//    1 Peter
  {"1SAMUEL", 10},		//    1 Samuel
  {"1THESSALONIANS", 54},	//   1 Thessalonians
  {"1TIMOTHY", 56},		//   1 Timothy
  {"2 C", 49},			//   2 Corinthians
  {"2 CHRONICLES", 15},		//   2 Chronicles
  {"2 CORINTHIANS", 49},	//   2 Corinthians
  {"2 JN", 65},			//    2 John
  {"2 JOHN", 65},		//    2 John
  {"2 KGS", 13},		//    2 Kings
  {"2 KINGS", 13},		//    2 Kings
  {"2 PETER", 63},		//    2 Peter
  {"2 PTR", 63},		//    2 Peter
  {"2 SAMUEL", 11},		//    2 Samuel
  {"2 THESSALONIANS", 55},	//   2 Thessalonians
  {"2 TIMOTHY", 57},		//   2 Timothy
  {"2C", 49},			//   2 Corinthians
  {"2CHRONICLES", 15},		//   2 Chronicles
  {"2CORINTHIANS", 49},		//   2 Corinthians
  {"2JN", 65},			//    2 John    
  {"2JOHN", 65},		//    2 John
  {"2KGS", 13},			// 2 Kings
  {"2KINGS", 13},		//    2 Kings
  {"2PETER", 63},		//    2 Peter
  {"2PTR", 63},			//    2 Peter
  {"2SAMUEL", 11},		//    2 Samuel
  {"2THESSALONIANS", 55},	//   2 Thessalonians
  {"2TIMOTHY", 57},		//   2 Timothy
  {"3 JN", 66},			//    3 John
  {"3 JOHN", 66},		//    3 John
  {"3JN", 66},			//    3 John
  {"3JOHN", 66},		//    3 John
  {"ACTS", 46},			//     Acts
  {"AMOS", 31},			//    Amos
  {"APOCALYPSE OF ST. JOHN", 68},	//    Apocalypse of St. John (Rev.)
  {"C", 53},			//    Colossians
  {"CANTICLE OF CANTICLES", 23},	//    Canticle of Canticles (Song of S.)
  {"COLOSSIANS", 53},		//    Colossians
  {"D", 6},			//     Deuteronomy
  {"DANIEL", 28},		//    Daniel
  {"DEUTERONOMY", 6},		//    Deuteronomy
  {"E", 51},			//     Ephesians
  {"ECCLESIASTES", 22},		//    Ecclesiastes
  {"EPHESIANS", 51},		//    Ephesians
  {"ESTER", 18},		//    Esther
  {"ESTHER", 18},		//    Esther
  {"EXODUS", 3},		//    Exodus
  {"EZEKIEL", 27},		//   Ezekiel
  {"EZK", 27},		//   Ezekiel
  {"EZRA", 16},			//   Ezra
  {"G", 2},			//     Genesis
  {"GALATIANS", 50},		//    Galatians
  {"GENESIS", 2},		//    Genesis
  {"H", 60},			//     Hebrews
  {"HABAKKUK", 36},		//    Habakkuk
  {"HAGGAI", 38},		//   Haggai
  {"HEBREWS", 60},		//    Hebrews
  {"HOSEA", 29},		//    Hosea
  {"I C", 48},			//   1 Corinthians
  {"I CHRONICLES", 14},		//   1 Chronicles
  {"I CORINTHIANS", 48},	//   1 Corinthians
  {"I JN", 64},			//    1 John
  {"I JOHN", 64},		//    1 John
  {"I KGS", 12},		// 1 Kings
  {"I KINGS", 12},		//    1 Kings
  {"I PETER", 62},		//    1 Peter
  {"I PTR", 62},		//    1 Peter
  {"I SAMUEL", 10},		//    1 Samuel
  {"I THESSALONIANS", 54},	//   1 Thessalonians
  {"I TIMOTHY", 56},		//   1 Timothy
  {"IC", 48},			//   1 Corinthians
  {"ICHRONICLES", 14},		//   1 Chronicles
  {"ICORINTHIANS", 48},		//   1 Corinthians
  {"II C", 49},			//   2 Corinthians
  {"II CHRONICLES", 15},	//   2 Chronicles
  {"II CORINTHIANS", 49},	//   2 Corinthians
  {"II JN", 65},		//    2 John  
  {"II JOHN", 65},		//    2 John
  {"II KGS", 13},		// 2 Kings
  {"II KINGS", 13},		//    2 Kings
  {"II PETER", 63},		//    2 Peter
  {"II PTR", 63},		//    2 Peter
  {"II SAMUEL", 11},		//    2 Samuel
  {"II THESSALONIANS", 55},	//   2 Thessalonians
  {"II TIMOTHY", 57},		//   2 Timothy
  {"IIC", 49},			//   2 Corinthians
  {"IICHRONICLES", 15},		//   2 Chronicles
  {"IICORINTHIANS", 49},	//   2 Corinthians
  {"III JN", 66},		//    3 John 
  {"III JOHN", 66},		//    3 John
  {"IIIJN", 66},		//    3 John
  {"IIIJOHN", 66},		//    3 John
  {"IIJN", 65},			//    2 John
  {"IIJOHN", 65},		//    2 John
  {"IIKGS", 13},		// 2 Kings
  {"IIKINGS", 13},		//    2 Kings
  {"IIPETER", 63},		//    2 Peter
  {"IIPTR", 63},		//    2 Peter
  {"IISAMUEL", 11},		//    2 Samuel
  {"IITHESSALONIANS", 55},	//   2 Thessalonians
  {"IITIMOTHY", 55},		//   2 Timothy
  {"IJN", 64},			//    1 John
  {"IJOHN", 64},		//    1 John
  {"IKGS", 12},			// 1 Kings
  {"IKINGS", 12},		//    1 Kings
  {"IPETER", 62},		//    1 Peter
  {"IPTR", 62},			//    1 Peter
  {"ISA", 24},			//     Isaiah
  {"ISAIAH", 24},		//     Isaiah
  {"ISAMUEL", 10},		//    1 Samuel
  {"ITHESSALONIANS", 54},	//   1 Thessalonians
  {"ITIMOTHY", 56},		//   1 Timothy
  {"J", 45},			//     John
  {"JAMES", 61},		//    James
  {"JAS", 61},			//    James
  {"JDGS", 8},		//  Judges
  {"JEREMIAH", 25},		//    Jeremiah
  {"JHN", 45},			//    John
  {"JN", 45},			//    John
  {"JO", 45},			//    John
  {"JOB", 19},			//   Job
  {"JOEL", 30},			//   Joel
  {"JOHN", 45},			//   John
  {"JOL", 30},			//   Joel
  {"JONAH", 33},		//   Jonah
  {"JOSHUA", 7},		//   Joshua
  {"JUDE", 67},			//  Jude
  {"JUDGES", 8},		//  Judges
  {"L", 44},			//     Luke
  {"LAMENTATIONS", 26},		//    Lamentations
  {"LEVITICUS", 4},		//    Leviticus
  {"LK", 44},			//    Luke
  {"LUKE", 44},			//    Luke
  {"MA", 42},			//    Matthew
  {"MALACHI", 40},		//   Malachi
  {"MARK", 43},			//   Mark
  {"MATTHEW", 42},		//   Matthew
  {"MICAH", 34},		//    Micah
  {"MODULE HEADING", 0},		//   Module Heading
  {"MK", 43},			//    Mark
  {"MRK", 43},			//    Mark
  {"MT", 42},			//    Matthew
  {"N", 5},			//     Numbers
  {"NAHUM", 35},		//    Nahum
  {"NAM", 35},		//    Nahum
  {"NEHEMIAH", 17},		//    Nehemiah
  {"NEW TESTAMENT", 41},		//     New Testament
  {"NUMBERS", 5},		//    Numbers
  {"OBADIAH", 32},		//     Obadiah
  {"OLD TESTAMENT", 1},		//     Old Testament
  {"P", 20},			//     Psalms
  {"PHIL", 52},			//    Philippians
  {"PHILEMON", 59},		// Philemon
  {"PHILIPPIANS", 52},		// Philippians
  {"PHLM", 59},		// Philemon
  {"PHM", 59},			//   Philemon
  {"PHP", 52},			//   Philippians
  {"PR", 21},		//    Proverbs
  {"PROVERBS", 21},		//    Proverbs
  {"PSA", 20},		//    Psalms
  {"PSALMS", 20},		//    Psalms
  {"PSM", 20},			// Psalms
  {"PSS", 20},			// Psalms
  {"QOHELETH", 22},              // Qohelet (Ecclesiastes)
  {"REVELATION OF JOHN", 68},	//     Revelation
  {"ROMANS", 47},		//    Romans
  {"RUTH", 9},			//    Ruth
  {"SNG", 23},	//     Song of Solomon
  {"SOLOMON", 23},	//     Song of Solomon
  {"SONG OF SOLOMON", 23},	//     Song of Solomon
  {"SONG OF SONGS", 23},	//     Song of Solomon
  {"SOS", 23},			//     Song of Solomon
  {"TITUS", 58},		//     Titus
  {"ZECHARIAH", 39},		//   Zechariah
  {"ZEPHANIAH", 37},		//   Zephaniah
  {"", -1}
};
*/

/* includes all osis books - use the locale osis.conf instead
const struct abbrev
  VerseKey2::builtin_abbrevs[] = {
  {"1 C", 46},			//   1 Corinthians
  {"1 CHRONICLES", 13},		//   1 Chronicles
  {"1 CORINTHIANS", 47},	//   1 Corinthians
  {"1 ENOCH", 84},
  {"1 ESDRAS", 75},
  {"1 JN", 63},			//    1 John
  {"1 JOHN", 63},		//    1 John
  {"1 KGS", 11},		//    1 Kings
  {"1 KINGS", 11},		//    1 Kings
  {"1 MACCABEES", 77},
  {"1 PETER", 61},		//    1 Peter
  {"1 PTR", 61},		//    1 Peter
  {"1 SAMUEL", 9},		//    1 Samuel
  {"1 THESSALONIANS", 53},	//   1 Thessalonians
  {"1 TIMOTHY", 55},		//   1 Timothy
  {"1C", 47},			//   1 Corinthians
  {"1CHRONICLES", 13},		//   1 Chronicles
  {"1CORINTHIANS", 47},		//   1 Corinthians
  {"1ENOCH", 84},
  {"1ESDRAS", 75},
  {"1JN", 63},			//    1 John       
  {"1JOHN", 63},		//    1 John
  {"1KGS", 11},			// 1 Kings
  {"1KINGS", 11},		//    1 Kings
  {"1MACCABEES", 77},
  {"1PETER", 61},		//    1 Peter
  {"1PTR", 61},			//    1 Peter
  {"1SAMUEL", 9},		//    1 Samuel
  {"1THESSALONIANS", 53},	//   1 Thessalonians
  {"1TIMOTHY", 55},		//   1 Timothy
  {"2 C", 48},			//   2 Corinthians
  {"2 CHRONICLES", 14},		//   2 Chronicles
  {"2 CORINTHIANS", 48},	//   2 Corinthians
  {"2 ESDRAS", 76},
  {"2 JN", 64},			//    2 John
  {"2 JOHN", 64},		//    2 John
  {"2 KGS", 12},		//    2 Kings
  {"2 KINGS", 12},		//    2 Kings
  {"2 MACCABEES", 78},
  {"2 PETER", 62},		//    2 Peter
  {"2 PTR", 62},		//    2 Peter
  {"2 SAMUEL", 10},		//    2 Samuel
  {"2 THESSALONIANS", 54},	//   2 Thessalonians
  {"2 TIMOTHY", 56},		//   2 Timothy
  {"2C", 48},			//   2 Corinthians
  {"2CHRONICLES", 14},		//   2 Chronicles
  {"2CORINTHIANS", 48},		//   2 Corinthians
  {"2ESDRAS", 76},
  {"2JN", 64},			//    2 John    
  {"2JOHN", 64},		//    2 John
  {"2KGS", 12},			// 2 Kings
  {"2KINGS", 12},		//    2 Kings
  {"2MACCABEES", 78},
  {"2PETER", 62},		//    2 Peter
  {"2PTR", 62},			//    2 Peter
  {"2SAMUEL", 10},		//    2 Samuel
  {"2THESSALONIANS", 54},	//   2 Thessalonians
  {"2TIMOTHY", 56},		//   2 Timothy
  {"3 JN", 65},			//    3 John
  {"3 JOHN", 65},		//    3 John
  {"3JN", 65},			//    3 John
  {"3JOHN", 65},		//    3 John
  {"3 MACCABEES", 79},
  {"3MACCABEES", 79},
  {"4 MACCABEES", 80},
  {"4MACCABEES", 80},
  {"ACTS", 45},			//     Acts
  {"ADDESTHER", 87},
  {"ADDITIONS TO ESTHER", 87},
  {"AMOS", 30},			//    Amos
  {"APOCALYPSE OF ST. JOHN", 67},	//    Apocalypse of St. John (Rev.)
  {"APOCRYPHA", 86},
  {"BARUCH", 73},
  {"BEL AND THE DRAGON",90},
  {"BEN SIRACH", 72},
  {"C", 52},			//    Colossians
  {"CANTICLE OF CANTICLES", 22},	//    Canticle of Canticles (Song of S.)
  {"COLOSSIANS", 52},		//    Colossians
  {"D", 5},			//     Deuteronomy
  {"DANIEL", 27},		//    Daniel
  {"DEUTERO", 5},		//    Deuteronomy
  {"DEUTEROCANON", 68},		//    Deuteronomy
  {"DEUTERONOMY", 5},		//    Deuteronomy
  {"E", 50},			//     Ephesians
  {"ECCLESIASTES", 21},		//    Ecclesiastes
  {"ECCLESIASTICUS", 73},
  {"EPHESIANS", 50},		//    Ephesians
  {"EPISTLE OF JEREMIAH", 74},
  {"EPISTLE TO THE LAODICEANS", 83},
  {"EPJER", 74},
  {"EPLAO", 83},
  {"ESTER", 17},		//    Esther
  {"ESTHER", 17},		//    Esther
  {"EXODUS", 2},		//    Exodus
  {"EZEKIEL", 26},		//   Ezekiel
  {"EZK", 26},		//   Ezekiel
  {"EZRA", 15},			//   Ezra
  {"G", 1},			//     Genesis
  {"GALATIANS", 49},		//    Galatians
  {"GENESIS", 1},		//    Genesis
  {"H", 59},			//     Hebrews
  {"HABAKKUK", 35},		//    Habakkuk
  {"HAGGAI", 37},		//   Haggai
  {"HEBREWS", 59},		//    Hebrews
  {"HOSEA", 28},		//    Hosea
  {"I C", 47},			//   1 Corinthians
  {"I CHRONICLES", 13},		//   1 Chronicles
  {"I CORINTHIANS", 47},	//   1 Corinthians
  {"I ENOCH", 84},
  {"I ESDRAS", 76},
  {"I JN", 63},			//    1 John
  {"I JOHN", 63},		//    1 John
  {"I KGS", 11},		// 1 Kings
  {"I KINGS", 11},		//    1 Kings
  {"I MACCABEES", 78},
  {"I PETER", 61},		//    1 Peter
  {"I PTR", 61},		//    1 Peter
  {"I SAMUEL", 9},		//    1 Samuel
  {"I THESSALONIANS", 53},	//   1 Thessalonians
  {"I TIMOTHY", 55},		//   1 Timothy
  {"IC", 47},			//   1 Corinthians
  {"ICHRONICLES", 13},		//   1 Chronicles
  {"ICORINTHIANS", 47},		//   1 Corinthians
  {"IENOCH", 84},
  {"IESDRAS", 76},
  {"II C", 48},			//   2 Corinthians
  {"II CHRONICLES", 14},	//   2 Chronicles
  {"II CORINTHIANS", 48},	//   2 Corinthians
  {"II ESDRAS", 77},
  {"II JN", 64},		//    2 John  
  {"II JOHN", 64},		//    2 John
  {"II KGS", 12},		// 2 Kings
  {"II KINGS", 12},		//    2 Kings
  {"II MACCABEES", 79},
  {"II PETER", 62},		//    2 Peter
  {"II PTR", 62},		//    2 Peter
  {"II SAMUEL", 10},		//    2 Samuel
  {"II THESSALONIANS", 54},	//   2 Thessalonians
  {"II TIMOTHY", 56},		//   2 Timothy
  {"IIC", 48},			//   2 Corinthians
  {"IICHRONICLES", 14},		//   2 Chronicles
  {"IICORINTHIANS", 48},	//   2 Corinthians
  {"IIESDRAS", 77},
  {"III JN", 65},		//    3 John 
  {"III JOHN", 65},		//    3 John
  {"IIIJN", 65},		//    3 John
  {"IIIJOHN", 65},		//    3 John
  {"III MACCABEES", 80},
  {"IIII MACCABEES", 81},
  {"IIIIMACCABEES", 81},
  {"IIIMACCABEES", 80},
  {"IIJN", 64},			//    2 John
  {"IIJOHN", 64},		//    2 John
  {"IIKGS", 12},		// 2 Kings
  {"IIKINGS", 12},		//    2 Kings
  {"IIMACCABEES", 79},
  {"IIPETER", 62},		//    2 Peter
  {"IIPTR", 62},		//    2 Peter
  {"IISAMUEL", 10},		//    2 Samuel
  {"IITHESSALONIANS", 54},	//   2 Thessalonians
  {"IITIMOTHY", 56},		//   2 Timothy
  {"IJN", 63},			//    1 John
  {"IJOHN", 63},		//    1 John
  {"IKGS", 11},			// 1 Kings
  {"IKINGS", 11},		//    1 Kings
  {"IMACCABEES", 78},
  {"IPETER", 61},		//    1 Peter
  {"IPTR", 61},			//    1 Peter
  {"ISA", 23},			//     Isaiah
  {"ISAIAH", 23},		//     Isaiah
  {"ISAMUEL", 9},		//    1 Samuel
  {"ITHESSALONIANS", 53},	//   1 Thessalonians
  {"ITIMOTHY", 55},		//   1 Timothy
  {"IV MACCABEES", 81},
  {"IVMACCABEES", 81},
  {"J", 44},			//     John
  {"JAMES", 60},		//    James
  {"JAS", 60},			//    James
  {"JDGS", 7},		//  Judges
  {"JDT", 70},
  {"JEREMIAH", 24},		//    Jeremiah
  {"JESUS BEN SIRACH", 73},
  {"JHN", 44},			//    John
  {"JN", 44},			//    John
  {"JO", 44},			//    John
  {"JOB", 18},			//   Job
  {"JOEL", 29},			//   Joel
  {"JOHN", 44},			//   John
  {"JOL", 29},			//   Joel
  {"JONAH", 32},		//   Jonah
  {"JOSHUA", 6},		//   Joshua
  {"JUBILEES", 85},
  {"JUDE", 66},			//  Jude
  {"JUDGES", 7},		//  Judges
  {"JUDITH", 70},
  {"L", 43},			//     Luke
  {"LAMENTATIONS", 25},		//    Lamentations
  {"LAODICEANS", 83},
  {"LETTER OF JEREMIAH", 74},
  {"LEVITICUS", 3},		//    Leviticus
  {"LK", 43},			//    Luke
  {"LUKE", 43},			//    Luke
  {"MA", 41},			//    Matthew
  {"MALACHI", 39},		//   Malachi
  {"MANASSEH", 91},
  {"MANASSES", 91},
  {"MARK", 42},			//   Mark
  {"MATTHEW", 41},		//   Matthew
  {"MICAH", 33},		//    Micah
  {"MK", 42},			//    Mark
  {"MRK", 42},			//    Mark
  {"MT", 41},			//    Matthew
  {"N", 4},			//     Numbers
  {"NAHUM", 34},		//    Nahum
  {"NAM", 34},		//    Nahum
  {"NEHEMIAH", 16},		//    Nehemiah
  {"NEW TESTAMENT", 40},		//     New Testament
  {"NUMBERS", 4},		//    Numbers
  {"OBADIAH", 31},		//     Obadiah
  {"ODES OF SOLOMON", 81},
  {"OLD TESTAMENT", 0},		//     Old Testament
  {"P", 19},			//     Psalms
  {"PHIL", 51},			//    Philippians
  {"PHILEMON", 58},		// Philemon
  {"PHILIPPIANS", 51},		// Philippians
  {"PHLM", 58},		// Philemon
  {"PHM", 58},			//   Philemon
  {"PHP", 51},			//   Philippians
  {"PR", 20},		//    Proverbs
  {"PRAYER OF AZARIAH", 88},
  {"PRAYER OF MANASSEH", 91},
  {"PRAYER OF MANASSES", 91},
  {"PRAZAR", 88},
  {"PRMAN", 91},
  {"PROVERBS", 20},		//    Proverbs
  {"PS151", 92},
  {"PSA", 19},		//    Psalms
  {"PSALM ", 19},
  {"PSALM 151", 92},
  {"PSALM151", 92},
  {"PSALMS", 19},		//    Psalms
  {"PSALMS OF SOLOMON", 82},
  {"PSM", 19},			// Psalms
  {"PSS", 19},			// Psalms
  {"PSSOL", 82},
  {"PSSSOL", 82},
  {"QOHELETH", 21},              // Qohelet (Ecclesiastes)
  {"REVELATION OF JOHN", 67},	//     Revelation
  {"ROMANS", 46},		//    Romans
  {"RUTH", 8},			//    Ruth
  {"SIRACH", 72},
  {"SNG", 22},	//     Song of Solomon
  {"SOLOMON", 22},	//     Song of Solomon
  {"SONG OF SOLOMON", 22},	//     Song of Solomon
  {"SONG OF SONGS", 22},	//     Song of Solomon
  {"SOS", 22},			//     Song of Solomon
  {"SUSANNA", 89},
  {"TITUS", 57},		//     Titus
  {"TOBIT", 69},
  {"WISDOM", 71},//250
  {"WISDOM OF JESUS BEN SIRACH", 72},
  {"ZECHARIAH", 38},		//   Zechariah
  {"ZEPHANIAH", 36},		//   Zephaniah
  {"", -1}
};
*/

/* The default versification scheme is KJV */
/*
  0, 1, 52, 93, 121, 158,
  193, 218, 240, 245, 277, 302, 325,
  351, 381, 418, 429, 443, 454, 497,
  648, 680, 693, 702, 769, 822, 828,
  877, 890, 905, 909, 919, 921, 926,
  934, 938, 942, 946, 949, 964
*/




