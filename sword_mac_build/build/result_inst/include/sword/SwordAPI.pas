{*
 *
 * $Id: SwordAPI.pas 1688 2005-01-01 04:42:26Z scribe $
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
 *}
unit SwordAPI;

interface
const
	DLLNAME = 'sword32.dll';

type
    paramt = record
           path, name, disc: pchar;
    end;
    pparamt = ^paramt;

function  NewModule(modtype: PChar; params: pparamt): integer; stdcall; external DLLNAME;
procedure DeleteModule(hmod: integer); stdcall; external DLLNAME;
function  ModGetTextLen(hmod: integer): integer; stdcall; external DLLNAME;
procedure ModGetText(hmod: integer; buf: PChar; size: integer); stdcall; external DLLNAME;
procedure ModGetKeyText(hmod: integer; buf: PChar; size: integer); stdcall; external DLLNAME;
function  ModGetKey(hmod: integer):integer; stdcall; external DLLNAME;
function  ModSetKeyText(hmod: integer; keytext: PChar):char; stdcall; external DLLNAME;
function  ModSetKeyKey(hmod: integer; hkey: integer):char; stdcall; external DLLNAME;
function  ModSearch(hmod: integer; stext: PChar):integer; stdcall; external DLLNAME;
procedure YoYo(x:integer; y:integer); stdcall; external DLLNAME;
procedure ModInc(hmod: integer); stdcall; external DLLNAME;
procedure ModDec(hmod: integer); stdcall; external DLLNAME;
function  ModError(hmod:integer): integer; stdcall; external DLLNAME;
function  NewKey(keytype:PChar):integer;stdcall; external DLLNAME;
procedure DeleteKey(hkey: integer); stdcall; external DLLNAME;
function  KeyGetPersist(hkey: integer): integer; stdcall; external DLLNAME;
procedure KeySetPersist(hkey: integer; value: integer); stdcall; external DLLNAME;
function  KeyError(hkey:integer): integer; stdcall; external DLLNAME;
procedure KeyGetText(hkey: integer; buf: PChar; size: integer); stdcall; external DLLNAME;
procedure KeySetText(hkey: integer; keytext: PChar); stdcall; external DLLNAME;
procedure KeySetKey(hkey: integer; hkey: integer); stdcall; external DLLNAME;
procedure KeyInc(hkey: integer); stdcall; external DLLNAME;
procedure KeyDec(hkey: integer); stdcall; external DLLNAME;
function  VerseKeyGetTestament(hkey: integer): integer; stdcall; external DLLNAME;
function  VerseKeyGetBook(hkey: integer): integer; stdcall; external DLLNAME;
function  VerseKeyGetChapter(hkey: integer): integer; stdcall; external DLLNAME;
function  VerseKeyGetVerse(hkey: integer): integer; stdcall; external DLLNAME;
procedure VerseKeySetTestament(hkey: integer; value: integer); stdcall; external DLLNAME;
procedure VerseKeySetBook(hkey: integer; value: integer); stdcall; external DLLNAME;
procedure VerseKeySetChapter(hkey: integer; value: integer); stdcall; external DLLNAME;
procedure VerseKeySetVerse(hkey: integer; value: integer); stdcall; external DLLNAME;
function  VerseKeyGetAutoNormalize(hkey: integer): integer; stdcall; external DLLNAME;
procedure VerseKeySetAutoNormalize(hkey: integer; value: integer); stdcall; external DLLNAME;
procedure VerseKeyNormalize(hkey: integer); stdcall; external DLLNAME;

implementation

end.
