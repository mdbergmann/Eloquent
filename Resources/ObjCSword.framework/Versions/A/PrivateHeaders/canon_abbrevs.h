/******************************************************************************
 *
 *  canon_abbrevs.h -	Canonical text information to be included by
 *			 VerseKey.cpp
 *
 * $Id: canon_abbrevs.h 2970 2013-08-22 07:03:11Z chrislit $
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
 *
 */

#ifndef CANON_ABBREVS_H
#define CANON_ABBREVS_H

SWORD_NAMESPACE_START


/******************************************************************************
 *	Abbreviations - MUST be in alphabetical order & by PRIORITY
 *		RULE: first match of entire key
 *			(e.g. key: "1CH"; match: "1CHRONICLES")
 */

const struct abbrev builtin_abbrevs[] = {
  {"1 BARUCH", "Bar"},		// Baruch
  {"1 C", "1Cor"},		// I Corinthians
  {"1 CHRONICLES", "1Chr"},		// I Chronicles
  {"1 CORINTHIANS", "1Cor"},		// I Corinthians
  {"1 E", "1Esd"},		// I Esdras
  {"1 ENOCH", "1En"},		// I Enoch
  {"1 ESDRAS", "1Esd"},		// I Esdras
  {"1 JN", "1John"},		// I John
  {"1 JOHN", "1John"},		// I John
  {"1 K", "1Kgs"},		// I Kings
  {"1 KGDMS", "1Sam"},		// I Samuel
  {"1 KGS", "1Kgs"},		// I Kings
  {"1 KING", "1Kgs"},		// I Kings
  {"1 KINGDOMS", "1Sam"},		// I Samuel
  {"1 KINGS", "1Kgs"},		// I Kings
  {"1 MACCABEES", "1Macc"},		// I Maccabees
  {"1 MAKABIAN", "1Meq"},		// I Meqabyan
  {"1 MEQABYAN", "1Meq"},		// I Meqabyan
  {"1 P", "1Pet"},		// I Peter
  {"1 PARALIPOMENON", "1Chr"},		// I Chronicles
  {"1 PETER", "1Pet"},		// I Peter
  {"1 PTR", "1Pet"},		// I Peter
  {"1 SAMUEL", "1Sam"},		// I Samuel
  {"1 THESSALONIANS", "1Thess"},		// I Thessalonians
  {"1 TIMOTHY", "1Tim"},		// I Timothy
  {"1BARUCH", "Bar"},		// Baruch
  {"1C", "1Cor"},		// I Corinthians
  {"1CHR", "1Chr"},		// I Chronicles
  {"1CHRONICLES", "1Chr"},		// I Chronicles
  {"1COR", "1Cor"},		// I Corinthians
  {"1CORINTHIANS", "1Cor"},		// I Corinthians
  {"1E", "1Esd"},		// I Esdras
  {"1EN", "1En"},		// I Enoch
  {"1ENOCH", "1En"},		// I Enoch
  {"1ESD", "1Esd"},		// I Esdras
  {"1ESDRAS", "1Esd"},		// I Esdras
  {"1JN", "1John"},		// I John
  {"1JOHN", "1John"},		// I John
  {"1K", "1Kgs"},		// I Kings
  {"1KGDMS", "1Sam"},		// I Samuel
  {"1KGS", "1Kgs"},		// I Kings
  {"1KING", "1Kgs"},		// I Kings
  {"1KINGDOMS", "1Sam"},		// I Samuel
  {"1KINGS", "1Kgs"},		// I Kings
  {"1MACC", "1Macc"},		// I Maccabees
  {"1MACCABEES", "1Macc"},		// I Maccabees
  {"1MAKABIAN", "1Meq"},		// I Meqabyan
  {"1MEQ", "1Meq"},		// I Meqabyan
  {"1MEQABYAN", "1Meq"},		// I Meqabyan
  {"1P", "1Pet"},		// I Peter
  {"1PARALIPOMENON", "1Chr"},		// I Chronicles
  {"1PET", "1Pet"},		// I Peter
  {"1PETER", "1Pet"},		// I Peter
  {"1PTR", "1Pet"},		// I Peter
  {"1SAM", "1Sam"},		// I Samuel
  {"1SAMUEL", "1Sam"},		// I Samuel
  {"1THESS", "1Thess"},		// I Thessalonians
  {"1THESSALONIANS", "1Thess"},		// I Thessalonians
  {"1TIM", "1Tim"},		// I Timothy
  {"1TIMOTHY", "1Tim"},		// I Timothy
  {"2 BARUCH", "2Bar"},		// 2Baruch
  {"2 C", "2Cor"},		// II Corinthians
  {"2 CHRONICLES", "2Chr"},		// II Chronicles
  {"2 CORINTHIANS", "2Cor"},		// II Corinthians
  {"2 E", "2Esd"},		// II Esdras
  {"2 ESDRAS", "2Esd"},		// II Esdras
  {"2 JN", "2John"},		// II John
  {"2 JOHN", "2John"},		// II John
  {"2 K", "2Kgs"},		// II Kings
  {"2 KGDMS", "2Sam"},		// II Samuel
  {"2 KGS", "2Kgs"},		// II Kings
  {"2 KING", "2Kgs"},		// II Kings
  {"2 KINGDOMS", "2Sam"},		// II Samuel
  {"2 KINGS", "2Kgs"},		// II Kings
  {"2 MACCABEES", "2Macc"},		// II Maccabees
  {"2 MAKABIAN", "2Meq"},		// II Meqabyan
  {"2 MEQABYAN", "2Meq"},		// II Meqabyan
  {"2 P", "2Pet"},		// II Peter
  {"2 PARALIPOMENON", "2Chr"},		// II Chronicles
  {"2 PETER", "2Pet"},		// II Peter
  {"2 PTR", "2Pet"},		// II Peter
  {"2 SAMUEL", "2Sam"},		// II Samuel
  {"2 THESSALONIANS", "2Thess"},		// II Thessalonians
  {"2 TIMOTHY", "2Tim"},		// II Timothy
  {"2BAR", "2Bar"},		// 2Baruch
  {"2BARUCH", "2Bar"},		// 2Baruch
  {"2C", "2Cor"},		// II Corinthians
  {"2CHR", "2Chr"},		// II Chronicles
  {"2CHRONICLES", "2Chr"},		// II Chronicles
  {"2COR", "2Cor"},		// II Corinthians
  {"2CORINTHIANS", "2Cor"},		// II Corinthians
  {"2E", "2Esd"},		// II Esdras
  {"2ESD", "2Esd"},		// II Esdras
  {"2ESDRAS", "2Esd"},		// II Esdras
  {"2JN", "2John"},		// II John
  {"2JOHN", "2John"},		// II John
  {"2K", "2Kgs"},		// II Kings
  {"2KGDMS", "2Sam"},		// II Samuel
  {"2KGS", "2Kgs"},		// II Kings
  {"2KING", "2Kgs"},		// II Kings
  {"2KINGDOMS", "2Sam"},		// II Samuel
  {"2KINGS", "2Kgs"},		// II Kings
  {"2MACC", "2Macc"},		// II Maccabees
  {"2MACCABEES", "2Macc"},		// II Maccabees
  {"2MAKABIAN", "2Meq"},		// II Meqabyan
  {"2MEQ", "2Meq"},		// II Meqabyan
  {"2MEQABYAN", "2Meq"},		// II Meqabyan
  {"2P", "2Pet"},		// II Peter
  {"2PARALIPOMENON", "2Chr"},		// II Chronicles
  {"2PET", "2Pet"},		// II Peter
  {"2PETER", "2Pet"},		// II Peter
  {"2PTR", "2Pet"},		// II Peter
  {"2SAM", "2Sam"},		// II Samuel
  {"2SAMUEL", "2Sam"},		// II Samuel
  {"2THESS", "2Thess"},		// II Thessalonians
  {"2THESSALONIANS", "2Thess"},		// II Thessalonians
  {"2TIM", "2Tim"},		// II Timothy
  {"2TIMOTHY", "2Tim"},		// II Timothy
  {"3 EZRA", "1Esd"},		// I Esdras
  {"3 JN", "3John"},		// III John
  {"3 JOHN", "3John"},		// III John
  {"3 KGDMS", "1Kgs"},		// I Kings
  {"3 KGS", "1Kgs"},		// I Kings
  {"3 KINGDOMS", "1Kgs"},		// I Kings
  {"3 KINGS", "1Kgs"},		// I Kings
  {"3 MACCABEES", "3Macc"},		// III Maccabees
  {"3 MAKABIAN", "3Meq"},		// III Meqabyan
  {"3 MEQABYAN", "3Meq"},		// III Meqabyan
  {"3EZRA", "1Esd"},		// I Esdras
  {"3JN", "3John"},		// III John
  {"3JOHN", "3John"},		// III John
  {"3KGDMS", "1Kgs"},		// I Kings
  {"3KGS", "1Kgs"},		// I Kings
  {"3KINGDOMS", "1Kgs"},		// I Kings
  {"3KINGS", "1Kgs"},		// I Kings
  {"3MACC", "3Macc"},		// III Maccabees
  {"3MACCABEES", "3Macc"},		// III Maccabees
  {"3MAKABIAN", "3Meq"},		// III Meqabyan
  {"3MEQ", "3Meq"},		// III Meqabyan
  {"3MEQABYAN", "3Meq"},		// III Meqabyan
  {"4 BARUCH", "4Bar"},		// IV Baruch
  {"4 KGDMS", "2Kgs"},		// II Kings
  {"4 KGS", "2Kgs"},		// II Kings
  {"4 KINGDOMS", "2Kgs"},		// II Kings
  {"4 KINGS", "2Kgs"},		// II Kings
  {"4 MACCABEES", "4Macc"},		// IV Maccabees
  {"4BAR", "4Bar"},		// IV Baruch
  {"4BARUCH", "4Bar"},		// IV Baruch
  {"4KGDMS", "2Kgs"},		// II Kings
  {"4KGS", "2Kgs"},		// II Kings
  {"4KINGDOMS", "2Kgs"},		// II Kings
  {"4KINGS", "2Kgs"},		// II Kings
  {"4MACC", "4Macc"},		// IV Maccabees
  {"4MACCABEES", "4Macc"},		// IV Maccabees
  {"5APOCSYRPSS", "AddPs"},		// Additional Psalm
  {"ACTS", "Acts"},		// Acts
  {"ADDDAN", "AddDan"},		// Additions to Daniel
  {"ADDESTH", "AddEsth"},		// Additions to Esther
  {"ADDITIONAL PSALM", "AddPs"},		// Additional Psalm
  {"ADDITIONS TO DANIEL", "AddDan"},		// Additions to Daniel
  {"ADDITIONS TO ESTHER", "AddEsth"},		// Additions to Esther
  {"ADDPS", "AddPs"},		// Additional Psalm
  {"AMOS", "Amos"},		// Amos
  {"APOCALYPSE OF JOHN", "Rev"},		// Revelation of John
  {"AZA", "PrAzar"},		// Prayer of Azariah
  {"AZAR", "PrAzar"},		// Prayer of Azariah
  {"AZARIAH", "PrAzar"},		// Prayer of Azariah
  {"BAR", "Bar"},		// Baruch
  {"BARUCH", "Bar"},		// Baruch
  {"BEL", "Bel"},		// Bel and the Dragon
  {"BEL AND THE DRAGON", "Bel"},		// Bel and the Dragon
  {"C", "Col"},		// Colossians
  {"CANTICLE OF CANTICLES", "Song"},		// Song of Solomon
  {"COL", "Col"},		// Colossians
  {"COLOSSIANS", "Col"},		// Colossians
  {"D", "Deut"},		// Deuteronomy
  {"DAN", "Dan"},		// Daniel
  {"DANGR", "DanGr"},		// Daniel (Greek)
  {"DANIEL", "Dan"},		// Daniel
  {"DANIEL (ADDITIONS)", "AddDan"},		// Additions to Daniel
  {"DANIEL (GREEK)", "DanGr"},		// Daniel (Greek)
  {"DEUT", "Deut"},		// Deuteronomy
  {"DEUTERONOMY", "Deut"},		// Deuteronomy
  {"DT", "Deut"},		// Deuteronomy
  {"E", "Exod"},		// Exodus
  {"ECCL", "Eccl"},		// Ecclesiastes
  {"ECCLESIASTES", "Eccl"},		// Ecclesiastes
  {"ECCLESIASTICUS", "Sir"},		// Sirach
  {"ECCLUS", "Sir"},		// Sirach
  {"EK", "Ezek"},		// Ezekiel
  {"ENOCH", "1En"},		// I Enoch
  {"EPH", "Eph"},		// Ephesians
  {"EPHESIANS", "Eph"},		// Ephesians
  {"EPISTLE OF JEREMIAH", "EpJer"},		// Epistle of Jeremiah
  {"EPJ", "EpJer"},		// Epistle of Jeremiah
  {"EPJER", "EpJer"},		// Epistle of Jeremiah
  {"EPLAO", "EpLao"},		// Laodiceans
  {"ES", "Esth"},		// Esther
  {"ESDRAS A", "1Esd"},		// I Esdras
  {"ESDRAS B", "Ezra"},		// II Esdras
  {"ESDRASA", "1Esd"},		// I Esdras
  {"ESDRASB", "Ezra"},		// II Esdras
  {"ESG", "EsthGr"},		// Esther (Greek)
  {"ESTER", "Esth"},		// Esther
  {"ESTH", "Esth"},		// Esther
  {"ESTHER", "Esth"},		// Esther
  {"ESTHER (ADDITIONS)", "AddEsth"},		// Additions to Esther
  {"ESTHER (GREEK)", "EsthGr"},		// Esther (Greek)
  {"ESTHGR", "EsthGr"},		// Esther (Greek)
  {"ETHIOPIC APOCALYPSE OF ENOCH", "1En"},		// I Enoch
  {"EXOD", "Exod"},		// Exodus
  {"EXODUS", "Exod"},		// Exodus
  {"EZEK", "Ezek"},		// Ezekiel
  {"EZEKIEL", "Ezek"},		// Ezekiel
  {"EZK", "Ezek"},		// Ezekiel
  {"EZRA", "Ezra"},		// Ezra
  {"FIVE APOCRYPHAL SYRIAC PSALMS", "AddPs"},		// Additional Psalm
  {"G", "Gen"},		// Genesis
  {"GAL", "Gal"},		// Galatians
  {"GALATIANS", "Gal"},		// Galatians
  {"GEN", "Gen"},		// Genesis
  {"GENESIS", "Gen"},		// Genesis
  {"GN", "Gen"},		// Genesis
  {"GRDAN", "DanGr"},		// Daniel (Greek)
  {"GREEK DANIEL", "DanGr"},		// Daniel (Greek)
  {"GREEK ESTHER", "EsthGr"},		// Esther (Greek)
  {"GRESTH", "EsthGr"},		// Esther (Greek)
  {"H", "Heb"},		// Hebrews
  {"HAB", "Hab"},		// Habakkuk
  {"HABAKKUK", "Hab"},		// Habakkuk
  {"HAG", "Hag"},		// Haggai
  {"HAGGAI", "Hag"},		// Haggai
  {"HEB", "Heb"},		// Hebrews
  {"HEBREWS", "Heb"},		// Hebrews
  {"HOS", "Hos"},		// Hosea
  {"HOSEA", "Hos"},		// Hosea
  {"I", "Isa"},		// Isaiah
  {"I BARUCH", "Bar"},		// Baruch
  {"I C", "1Cor"},		// I Corinthians
  {"I CHRONICLES", "1Chr"},		// I Chronicles
  {"I CORINTHIANS", "1Cor"},		// I Corinthians
  {"I E", "1Esd"},		// I Esdras
  {"I ENOCH", "1En"},		// I Enoch
  {"I ESDRAS", "1Esd"},		// I Esdras
  {"I JN", "1John"},		// I John
  {"I JOHN", "1John"},		// I John
  {"I K", "1Kgs"},		// I Kings
  {"I KGDMS", "1Sam"},		// I Samuel
  {"I KGS", "1Kgs"},		// I Kings
  {"I KING", "1Kgs"},		// I Kings
  {"I KINGDOMS", "1Sam"},		// I Samuel
  {"I KINGS", "1Kgs"},		// I Kings
  {"I MACCABEES", "1Macc"},		// I Maccabees
  {"I MAKABIAN", "1Meq"},		// I Meqabyan
  {"I MEQABYAN", "1Meq"},		// I Meqabyan
  {"I P", "1Pet"},		// I Peter
  {"I PARALIPOMENON", "1Chr"},		// I Chronicles
  {"I PETER", "1Pet"},		// I Peter
  {"I PTR", "1Pet"},		// I Peter
  {"I SAMUEL", "1Sam"},		// I Samuel
  {"I THESSALONIANS", "1Thess"},		// I Thessalonians
  {"I TIMOTHY", "1Tim"},		// I Timothy
  {"IBARUCH", "Bar"},		// Baruch
  {"IC", "1Cor"},		// I Corinthians
  {"ICHRONICLES", "1Chr"},		// I Chronicles
  {"ICORINTHIANS", "1Cor"},		// I Corinthians
  {"IE", "1Esd"},		// I Esdras
  {"IENOCH", "1En"},		// I Enoch
  {"IESDRAS", "1Esd"},		// I Esdras
  {"II BARUCH", "2Bar"},		// 2Baruch
  {"II C", "2Cor"},		// II Corinthians
  {"II CHRONICLES", "2Chr"},		// II Chronicles
  {"II CORINTHIANS", "2Cor"},		// II Corinthians
  {"II E", "2Esd"},		// II Esdras
  {"II ESDRAS", "2Esd"},		// II Esdras
  {"II JN", "2John"},		// II John
  {"II JOHN", "2John"},		// II John
  {"II K", "2Kgs"},		// II Kings
  {"II KGDMS", "2Sam"},		// II Samuel
  {"II KGS", "2Kgs"},		// II Kings
  {"II KING", "2Kgs"},		// II Kings
  {"II KINGDOMS", "2Sam"},		// II Samuel
  {"II KINGS", "2Kgs"},		// II Kings
  {"II MACCABEES", "2Macc"},		// II Maccabees
  {"II MAKABIAN", "2Meq"},		// II Meqabyan
  {"II MEQABYAN", "2Meq"},		// II Meqabyan
  {"II P", "2Pet"},		// II Peter
  {"II PARALIPOMENON", "2Chr"},		// II Chronicles
  {"II PETER", "2Pet"},		// II Peter
  {"II PTR", "2Pet"},		// II Peter
  {"II SAMUEL", "2Sam"},		// II Samuel
  {"II THESSALONIANS", "2Thess"},		// II Thessalonians
  {"II TIMOTHY", "2Tim"},		// II Timothy
  {"IIBARUCH", "2Bar"},		// 2Baruch
  {"IIC", "2Cor"},		// II Corinthians
  {"IICHRONICLES", "2Chr"},		// II Chronicles
  {"IICORINTHIANS", "2Cor"},		// II Corinthians
  {"IIE", "2Esd"},		// II Esdras
  {"IIESDRAS", "2Esd"},		// II Esdras
  {"III EZRA", "1Esd"},		// I Esdras
  {"III JN", "3John"},		// III John
  {"III JOHN", "3John"},		// III John
  {"III KGDMS", "1Kgs"},		// I Kings
  {"III KGS", "1Kgs"},		// I Kings
  {"III KINGDOMS", "1Kgs"},		// I Kings
  {"III KINGS", "1Kgs"},		// I Kings
  {"III MACCABEES", "3Macc"},		// III Maccabees
  {"III MAKABIAN", "3Meq"},		// III Meqabyan
  {"III MEQABYAN", "3Meq"},		// III Meqabyan
  {"IIIEZRA", "1Esd"},		// I Esdras
  {"IIIJN", "3John"},		// III John
  {"IIIJOHN", "3John"},		// III John
  {"IIIKGDMS", "1Kgs"},		// I Kings
  {"IIIKGS", "1Kgs"},		// I Kings
  {"IIIKINGDOMS", "1Kgs"},		// I Kings
  {"IIIKINGS", "1Kgs"},		// I Kings
  {"IIIMACCABEES", "3Macc"},		// III Maccabees
  {"IIIMAKABIAN", "3Meq"},		// III Meqabyan
  {"IIIMEQABYAN", "3Meq"},		// III Meqabyan
  {"IIJN", "2John"},		// II John
  {"IIJOHN", "2John"},		// II John
  {"IIK", "2Kgs"},		// II Kings
  {"IIKGDMS", "2Sam"},		// II Samuel
  {"IIKGS", "2Kgs"},		// II Kings
  {"IIKING", "2Kgs"},		// II Kings
  {"IIKINGDOMS", "2Sam"},		// II Samuel
  {"IIKINGS", "2Kgs"},		// II Kings
  {"IIMACCABEES", "2Macc"},		// II Maccabees
  {"IIMAKABIAN", "2Meq"},		// II Meqabyan
  {"IIMEQABYAN", "2Meq"},		// II Meqabyan
  {"IIP", "2Pet"},		// II Peter
  {"IIPARALIPOMENON", "2Chr"},		// II Chronicles
  {"IIPETER", "2Pet"},		// II Peter
  {"IIPTR", "2Pet"},		// II Peter
  {"IISAMUEL", "2Sam"},		// II Samuel
  {"IITHESSALONIANS", "2Thess"},		// II Thessalonians
  {"IITIMOTHY", "2Tim"},		// II Timothy
  {"IJN", "1John"},		// I John
  {"IJOHN", "1John"},		// I John
  {"IK", "1Kgs"},		// I Kings
  {"IKGDMS", "1Sam"},		// I Samuel
  {"IKGS", "1Kgs"},		// I Kings
  {"IKING", "1Kgs"},		// I Kings
  {"IKINGDOMS", "1Sam"},		// I Samuel
  {"IKINGS", "1Kgs"},		// I Kings
  {"IMACCABEES", "1Macc"},		// I Maccabees
  {"IMAKABIAN", "1Meq"},		// I Meqabyan
  {"IMEQABYAN", "1Meq"},		// I Meqabyan
  {"IP", "1Pet"},		// I Peter
  {"IPARALIPOMENON", "1Chr"},		// I Chronicles
  {"IPETER", "1Pet"},		// I Peter
  {"IPTR", "1Pet"},		// I Peter
  {"ISA", "Isa"},		// Isaiah
  {"ISAIAH", "Isa"},		// Isaiah
  {"ISAMUEL", "1Sam"},		// I Samuel
  {"ITHESSALONIANS", "1Thess"},		// I Thessalonians
  {"ITIMOTHY", "1Tim"},		// I Timothy
  {"IV BARUCH", "4Bar"},		// IV Baruch
  {"IV KGDMS", "2Kgs"},		// II Kings
  {"IV KGS", "2Kgs"},		// II Kings
  {"IV KINGDOMS", "2Kgs"},		// II Kings
  {"IV KINGS", "2Kgs"},		// II Kings
  {"IV MACCABEES", "4Macc"},		// IV Maccabees
  {"IVBARUCH", "4Bar"},		// IV Baruch
  {"IVKGDMS", "2Kgs"},		// II Kings
  {"IVKGS", "2Kgs"},		// II Kings
  {"IVKINGDOMS", "2Kgs"},		// II Kings
  {"IVKINGS", "2Kgs"},		// II Kings
  {"IVMACCABEES", "4Macc"},		// IV Maccabees
  {"J", "Josh"},		// Joshua
  {"JAMES", "Jas"},		// James
  {"JAS", "Jas"},		// James
  {"JB", "Job"},		// Job
  {"JD", "Judg"},		// Judges
  {"JDGS", "Judg"},		// Judges
  {"JDT", "Jdt"},		// Judith
  {"JER", "Jer"},		// Jeremiah
  {"JEREMIAH", "Jer"},		// Jeremiah
  {"JHN", "John"},		// John
  {"JN", "John"},		// John
  {"JO", "John"},		// John
  {"JOB", "Job"},		// Job
  {"JOEL", "Joel"},		// Joel
  {"JOHN", "John"},		// John
  {"JOL", "Joel"},		// Joel
  {"JONAH", "Jonah"},		// Jonah
  {"JOSH", "Josh"},		// Joshua
  {"JOSHUA", "Josh"},		// Joshua
  {"JS", "Josh"},		// Joshua
  {"JU", "Jude"},		// Jude
  {"JUB", "Jub"},		// Jubilees
  {"JUBILEES", "Jub"},		// Jubilees
  {"JUDE", "Jude"},		// Jude
  {"JUDG", "Judg"},		// Judges
  {"JUDGES", "Judg"},		// Judges
  {"JUDITH", "Jdt"},		// Judith
  {"L", "Luke"},		// Luke
  {"LAM", "Lam"},		// Lamentations
  {"LAMENTATIONS", "Lam"},		// Lamentations
  {"LAO", "EpLao"},		// Laodiceans
  {"LAODICEANS", "EpLao"},		// Laodiceans
  {"LE", "Lev"},		// Leviticus
  {"LETJER", "EpJer"},		// Epistle of Jeremiah
  {"LETTER OF JEREMIAH", "EpJer"},		// Epistle of Jeremiah
  {"LEV", "Lev"},		// Leviticus
  {"LEVITICUS", "Lev"},		// Leviticus
  {"LK", "Luke"},		// Luke
  {"LUKE", "Luke"},		// Luke
  {"LV", "Lev"},		// Leviticus
  {"MA", "Matt"},		// Matthew
  {"MAL", "Mal"},		// Malachi
  {"MALACHI", "Mal"},		// Malachi
  {"MAN", "PrMan"},		// Prayer of Manasses
  {"MANASSEH", "PrMan"},		// Prayer of Manasses
  {"MANASSES", "PrMan"},		// Prayer of Manasses
  {"MARK", "Mark"},		// Mark
  {"MATT", "Matt"},		// Matthew
  {"MATTHEW", "Matt"},		// Matthew
  {"MIC", "Mic"},		// Micah
  {"MICAH", "Mic"},		// Micah
  {"MK", "Mark"},		// Mark
  {"MRK", "Mark"},		// Mark
  {"MT", "Matt"},		// Matthew
  {"N", "Num"},		// Numbers
  {"NAH", "Nah"},		// Nahum
  {"NAHUM", "Nah"},		// Nahum
  {"NAM", "Nah"},		// Nahum
  {"NEH", "Neh"},		// Nehemiah
  {"NEHEMIAH", "Neh"},		// Nehemiah
  {"NM", "Num"},		// Numbers
  {"NUM", "Num"},		// Numbers
  {"NUMBERS", "Num"},		// Numbers
  {"OBAD", "Obad"},		// Obadiah
  {"OBADIAH", "Obad"},		// Obadiah
  {"ODES", "Odes"},		// Odes
  {"P", "Ps"},		// Psalms
  {"PARALEIPOMENA JEREMIOU", "4Bar"},		// IV Baruch
  {"PARALIPOMENA OF JEREMIAH", "4Bar"},		// IV Baruch
  {"PHIL", "Phil"},		// Philippians
  {"PHILEMON", "Phlm"},		// Philemon
  {"PHILIPPIANS", "Phil"},		// Philippians
  {"PHLM", "Phlm"},		// Philemon
  {"PHLP", "Phil"},		// Philippians
  {"PHM", "Phlm"},		// Philemon
  {"PHP", "Phil"},		// Philippians
  {"PR", "Prov"},		// Proverbs
  {"PRA", "PrAzar"},		// Prayer of Azariah
  {"PRAYER OF AZARIAH", "PrAzar"},		// Prayer of Azariah
  {"PRAYER OF MANASSEH", "PrMan"},		// Prayer of Manasses
  {"PRAYER OF MANASSES", "PrMan"},		// Prayer of Manasses
  {"PRAZAR", "PrAzar"},		// Prayer of Azariah
  {"PRM", "PrMan"},		// Prayer of Manasses
  {"PRMAN", "PrMan"},		// Prayer of Manasses
  {"PROV", "Prov"},		// Proverbs
  {"PROVERBS", "Prov"},		// Proverbs
  {"PS", "Ps"},		// Psalms
//  {"PS 151", "AddPs"},		// Additional Psalm
//  {"PS151", "AddPs"},		// Additional Psalm
  {"PSALM", "Ps"},		// Psalms
//  {"PSALM 151", "AddPs"},		// Additional Psalm
//  {"PSALM151", "AddPs"},		// Additional Psalm
  {"PSALMS", "Ps"},		// Psalms
  {"PSALMS OF SOLOMON", "PssSol"},		// Psalms of Solomon
  {"PSM", "Ps"},		// Psalms
  {"PSS", "Ps"},		// Psalms
  {"PSSSOL", "PssSol"},		// Psalms of Solomon
  {"QOHELET", "Eccl"},		// Ecclesiastes
  {"QOHELETH", "Eccl"},		// Ecclesiastes
  {"REV", "Rev"},		// Revelation of John
  {"REVELATION OF JOHN", "Rev"},		// Revelation of John
  {"ROM", "Rom"},		// Romans
  {"ROMANS", "Rom"},		// Romans
  {"RUTH", "Ruth"},		// Ruth
  {"S", "Song"},		// Song of Solomon
//  {"S3Y", "PrAzar"},		// Prayer of Azariah
  {"SI", "Sir"},		// Sirach
  {"SIP", "SirP"},		// Sirach (Prologue)
  {"SIR", "Sir"},		// Sirach
  {"SIRACH", "Sir"},		// Sirach
  {"SIRACH (PROLOGUE)", "SirP"},		// Sirach (Prologue)
  {"SIRP", "SirP"},		// Sirach (Prologue)
  {"SNG", "Song"},		// Song of Solomon
  {"SOLOMON", "Song"},		// Song of Solomon
  {"SONG", "Song"},		// Song of Solomon
  {"SONG OF SOLOMON", "Song"},		// Song of Solomon
  {"SONG OF SONGS", "Song"},		// Song of Solomon
  {"SONG OF THE THREE CHILDREN", "PrAzar"},		// Prayer of Azariah
  {"SUS", "Sus"},		// Susanna
  {"SUSANNA", "Sus"},		// Susanna
  {"SYRIAC APOCALYPSE OF BARUCH", "2Bar"},		// 2Baruch
  {"T", "Titus"},		// Titus
  {"TB", "Tob"},		// Tobit
  {"TBT", "Tob"},		// Tobit
  {"TITUS", "Titus"},		// Titus
  {"TOB", "Tob"},		// Tobit
  {"TOBIT", "Tob"},		// Tobit
  {"WIS", "Wis"},		// Wisdom
  {"WISDOM", "Wis"},		// Wisdom
  {"WISDOM OF BEN SIRA", "Sir"},		// Sirach
  {"WISDOM OF JESUS SON OF SIRACH", "Sir"},		// Sirach
  {"WISDOM OF SIRACH", "Sir"},		// Sirach
  {"WISDOM OF SOLOMON", "Wis"},		// Wisdom
  {"ZECH", "Zech"},		// Zechariah
  {"ZECHARIAH", "Zech"},		// Zechariah
  {"ZEPH", "Zeph"},		// Zephaniah
  {"ZEPHANIAH", "Zeph"},		// Zephaniah
  {"", ""}
};


SWORD_NAMESPACE_END


#endif
