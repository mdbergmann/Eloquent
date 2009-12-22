#!/bin/sh
#
# copyright in 2009/2010 Manfred Bergmann
#
# this script will create symlinks in /usr/local/bin to the SWORD utilities in Resources/bin

PWD=`pwd`
ln -s $PWD/imp2gbs /usr/local/bin/imp2gbs
ln -s $PWD/imp2ld /usr/local/bin/imp2ld
ln -s $PWD/imp2vs /usr/local/bin/imp2vs
ln -s $PWD/installmgr /usr/local/bin/installmgr
ln -s $PWD/mod2imp /usr/local/bin/mod2imp
ln -s $PWD/mod2osis /usr/local/bin/mod2osis
ln -s $PWD/mod2vpl /usr/local/bin/mod2vpl
ln -s $PWD/mod2zmod /usr/local/bin/mod2zmod
ln -s $PWD/osis2mod /usr/local/bin/osis2mod
ln -s $PWD/tei2mod /usr/local/bin/tei2mod
ln -s $PWD/vpl2mod /usr/local/bin/vpl2mod
ln -s $PWD/vs2osisref /usr/local/bin/vs2osisref
ln -s $PWD/vs2osisreftxt /usr/local/bin/vs2osisreftxt
ln -s $PWD/xml2gbs /usr/local/bin/xml2gbs
